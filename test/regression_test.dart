import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';

/// باجات اتلقت في مراجعة شغل الأسابيع ١–٣.
///
/// كل اختبار هنا **وقع فعلاً** قبل ما يتصلّح. الغرض إنهم مايرجعوش.
void main() {
  setUp(() => MockConfig.delay = Duration.zero);
  tearDown(() {
    MockConfig.scenario = MockScenario.happyPath;
    MockConfig.delay = const Duration(milliseconds: 600);
  });

  group('byUuid بيحترم السيناريو', () {
    test('«وصل الفرع» بيفتح التفاصيل على «وصل» مش «مؤكد»', () {
      MockConfig.scenario = MockScenario.arrivedInBranch;
      final row = MockBookings.upcoming.single;

      // `_inBranch` بيستخدم نفس الـ uuid بتاع الحجز العادي بحالة مختلفة.
      // البحث في الليستة الكاملة كان بيرجّع النسخة العادية ويبوّظ بالظبط
      // الحالة اللي السيناريو معمول عشانها.
      expect(MockBookings.byUuid(row.uuid).status, BookingStatus.arrived);
    });

    test('كل حالات الفرع بتتفتح صح', () {
      for (final entry in <MockScenario, BookingStatus>{
        MockScenario.arrivedInBranch: BookingStatus.arrived,
        MockScenario.waitingInBranch: BookingStatus.waiting,
        MockScenario.inService: BookingStatus.inProgress,
      }.entries) {
        MockConfig.scenario = entry.key;
        final row = MockBookings.upcoming.single;
        expect(MockBookings.byUuid(row.uuid).status, entry.value);
      }
    });

    test('أي صف في الـ٤٠ حجز بيفتح على نفسه', () {
      MockConfig.scenario = MockScenario.manyBookings;
      final rows = MockBookings.upcoming;

      // الأربعين مش في `_allUpcoming`، فالبحث القديم كان بيقع على أول
      // حجز في القايمة مهما دوست على أنهي صف.
      for (final row in <BookingUiModel>[rows.first, rows[20], rows.last]) {
        expect(MockBookings.byUuid(row.uuid).uuid, row.uuid);
      }
    });
  });

  group('تغيير الفرع بيعيد تحميل الكارت المفتوح', () {
    test('الكارت مابيفضلش فاضي بعد التغيير', () async {
      final cubit = CreateBookingCubit(
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();

      // نستنى أول تحميل يخلص. الافتراضي بعد Phase 4 هو الاقتراحات.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.items.single.proposals, isNotEmpty);

      final other = MockProviders.branchesOf('prv-1')[1];
      cubit.selectBranch(other);

      // `_clearScheduling` بيفضّي التواريخ، و`enterDateTimeStep` بيرجع
      // من غير ما يعمل حاجة لو فيه كارت مفتوح — فالكارت كان بيفضل مفتوح
      // على تقويم من غير أيام.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(cubit.selectedBranch?.uuid, other.uuid);
      expect(cubit.items.single.proposals, isNotEmpty);

      await cubit.close();
    });

    test('اختيار نفس الفرع مابيرميش الشغل', () async {
      final cubit = CreateBookingCubit(
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();

      await Future<void>.delayed(const Duration(milliseconds: 20));
      final item = cubit.items.single;
      item.selectedSlot = item.proposals.first;

      cubit.selectBranch(cubit.selectedBranch!);

      expect(item.selectedSlot, isNotNull);
      await cubit.close();
    });
  });

  group('سيناريو «الميعاد راح» ليه مخرج', () {
    test('بيوقّع أول محاولة بس — التانية بتعدّي', () async {
      MockConfig.scenario = MockScenario.slotLostAtConfirm;

      final cubit = CreateBookingCubit(
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();

      await Future<void>.delayed(const Duration(milliseconds: 20));
      final item = cubit.items.single;
      item.selectedSlot = item.proposals.first;

      final seen = <CreateBookingState>[];
      final sub = cubit.stream.listen(seen.add);

      await cubit.confirmBooking();
      // الـ emit الأخير بيحصل قبل الـ return على طول، والـ stream
      // بيوصّل على microtask — فمحتاجين نسيب الحدث يوصل قبل ما نقرا.
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<SlotTakenState>(), isNotEmpty);

      // العميل بيختار بديل ويأكّد تاني — لازم يعدّي المرة دي.
      // من غير الإصلاح كانت حلقة مقفولة مالهاش مخرج.
      item.selectedSlot = item.proposals.last;
      seen.clear();
      await cubit.confirmBooking();
      await Future<void>.delayed(Duration.zero);

      expect(seen.whereType<SlotTakenState>(), isEmpty);
      expect(seen.whereType<CreateBookingSuccessState>(), isNotEmpty);

      await sub.cancel();
      await cubit.close();
    });
  });

  group('الفرع بيتنقل بالـ uuid كمان', () {
    test('«احجز تاني» بيفتح على فرع الحجز القديم', () {
      final cubit = CreateBookingCubit(
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        // فرع مدينة نصر — مش الأول في القايمة.
        initialBranchUuid: 'brn-2',
      );

      expect(cubit.selectedBranch?.uuid, 'brn-2');
      cubit.close();
    });

    test('uuid مش موجود بيقع على أول فرع', () {
      final cubit = CreateBookingCubit(
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialBranchUuid: 'brn-does-not-exist',
      );

      expect(cubit.selectedBranch?.uuid, 'brn-1');
      cubit.close();
    });
  });

  group('كل سيناريو ليه بصمة مختلفة', () {
    /// بصمة السيناريو = **اللي التستر بيشوفه أول ما يدوس عليه**.
    ///
    /// الرئيسية بتعرض `upcoming.first` كبطل والمواعيد بتعرض الليستة، فلو
    /// سيناريوهين ليهم نفس البصمة يبقى المبدّل بيغيّر الشارة بس. ده
    /// بالظبط اللي حصل: خمس سيناريوهات كانوا واقعين على نفس الليستة
    /// الكاملة، و«عميل عليه خصم» كان بيشارك «تلات خدمات» نفس الحجز
    /// بالحرف. المبدّل كان شغال — بس مفيش حاجة تتغيّر.
    ///
    /// البصمة بتاخد **كل الأسطح الأربعة** اللي التستر بيقع عليها:
    /// القادمة (بحالتها) · السابقة · الإشعارات · قائمة الانتظار.
    ///
    /// أول نسخة كانت بتقيس القادمة بس، فطلعت تلات تصادمات كلهم كذب:
    /// حالات الفرع نفس الحجز بحالة مختلفة (والشارة هي اللي بتتغيّر)،
    /// والنهايات الأربعة فرقهم في تبويب السابقة، وسيناريوهات الانتظار
    /// فرقهم في الكارت. لو البصمة مابتشوفش السطح، بتبلّغ عن تصادم مش
    /// موجود — أسوأ من إنها مابتبلّغش.
    String fingerprintOf(MockScenario scenario) {
      MockConfig.scenario = scenario;

      String describe(List<BookingUiModel> list) => list
          .map((b) =>
              '${b.status.name}:${b.branchUuid}:${b.items.map((i) => '${i.serviceUuid}@${i.startAt}=${i.price}/${i.ratingStatus.name}').join(',')}')
          .join(' , ');

      final waitlist = MockWaitlist.forUser(DateTime.now())
          .map((e) => '${e.status.name}:${e.serviceName}')
          .join(' , ');

      return 'قادمة[${describe(MockBookings.upcoming)}] '
          'سابقة[${describe(MockBookings.past)}] '
          'إشعارات[${describe(MockBookings.notices)}] '
          'انتظار[$waitlist]';
    }

    /// دول بيتحكموا من `MockConfig` (تأخير · خطأ · فاضي) مش من الـ
    /// fixtures، فتطابق الداتا بينهم مقصود ومش عيب.
    const systemStates = <MockScenario>{
      MockScenario.networkError,
      MockScenario.emptyState,
      MockScenario.slowNetwork,
    };

    test('مفيش سيناريوهين بيعرضوا نفس المواعيد', () {
      final byFingerprint = <String, List<MockScenario>>{};

      for (final scenario in MockScenario.values) {
        if (systemStates.contains(scenario)) continue;
        byFingerprint.putIfAbsent(fingerprintOf(scenario), () => []).add(scenario);
      }

      final clashes = byFingerprint.entries.where((e) => e.value.length > 1);

      expect(
        clashes,
        isEmpty,
        reason: 'سيناريوهات بتعرض نفس الحجوزات بالحرف: '
            '${clashes.map((e) => e.value.map((s) => s.title).join(' = ')).join(' · ')}',
      );
    });

    test('الإشعارات مابتقعدش فوق كل سيناريو', () {
      // الملغي واللي ما حضرش بيطلعوا كارت أحمر فوق تبويب القادمة. لو
      // ظهروا في كل سيناريو، الشاشة تبان زي بعضها مهما اتغيّرت الداتا.
      MockConfig.scenario = MockScenario.happyPath;
      expect(MockBookings.notices, isEmpty);

      MockConfig.scenario = MockScenario.cancelledBooking;
      expect(MockBookings.notices, hasLength(1));
    });

    test('السيناريوهات اللي عايشة في فلو الحجز بتفضي القايمة', () {
      // فاضي = التستر بيروح على طول للفلو اللي السيناريو معمول عشانه،
      // بدل ما يقعد يدوّر وسط حجوزات مالهاش علاقة.
      for (final scenario in <MockScenario>[
        MockScenario.slotLostAtConfirm,
        MockScenario.waitlistOffered,
        MockScenario.waitlistExpired,
      ]) {
        MockConfig.scenario = scenario;
        expect(MockBookings.upcoming, isEmpty, reason: scenario.title);
      }
    });
  });

  group('عرض قائمة الانتظار على الرئيسية', () {
    test('العروض الشغّالة بس هي اللي بتوصل الرئيسية', () {
      // القسم اللي فوق البؤرة بيفلتر على `isHoldActive`. إدخال `pending`
      // مالوش وقت بيجري، فلو ظهر فوق الرئيسية بيتحوّل لقسم دايم قاعد
      // على الشاشة ومحدش بيبص له — وساعتها العرض الحقيقي لما ييجي
      // مايبانش عن اللي قبله.
      MockConfig.scenario = MockScenario.waitlistOffered;
      final now = DateTime.now();
      final entries = MockWaitlist.forUser(now);

      expect(entries.where((e) => e.isHoldActive(now)), hasLength(1));

      // العرض اللي عدّى مابيوصلش — الوقت خلص وخلاص.
      MockConfig.scenario = MockScenario.waitlistExpired;
      final expired = MockWaitlist.forUser(now);

      expect(expired, isNotEmpty);
      expect(expired.where((e) => e.isHoldActive(now)), isEmpty);
    });

    test('العدّاد بينزل مع الوقت مش ثابت', () {
      // الرئيسية وتبويب الحجوزات بيقروا من **نفس** الـ cubit عشان
      // مايطلعوش رقمين مختلفين. الاختبار ده بيثبّت إن الرقم مشتق من
      // الوقت أصلاً — لو بقى قيمة مخزّنة، مصدرين هيفترقوا حتمًا.
      MockConfig.scenario = MockScenario.waitlistOffered;
      final now = DateTime.now();
      final entry = MockWaitlist.forUser(now).first;

      expect(entry.countdownLabel(now), '5:00');
      expect(
        entry.countdownLabel(now.add(const Duration(minutes: 1, seconds: 8))),
        '3:52',
      );
      expect(entry.isHoldActive(now.add(const Duration(minutes: 6))), isFalse);
    });
  });

  group('التقييم المستني بيبان في الصف', () {
    test('«من غير تقييم» فيه تلات خدمات مستنية', () {
      // الصف بيعرض العدد. لو الرقم غلط، الجملة بتوعد بحاجة الشاشة
      // اللي بعدها مابتديهاش.
      MockConfig.scenario = MockScenario.completedUnrated;
      final booking = MockBookings.past.single;

      expect(booking.hasPendingRatings, isTrue);
      expect(booking.rateableItems, hasLength(3));
    });

    test('«تقييم جزئي» مالوش تقييم مستني — الاتنين اتقيّموا', () {
      // واحدة منشورة وواحدة **تحت المراجعة**، والاتنين مش قابلين
      // للتقييم تاني. `pending` معناها «قيّمتها والفرع بيراجع»، مش
      // «لسه ما قيّمتهاش» — فلو الصف عدّها، بيطلب من العميل يقيّم حاجة
      // هو قيّمها خلاص.
      MockConfig.scenario = MockScenario.completedPartiallyRated;
      final booking = MockBookings.past.single;

      expect(booking.rateableItems, isEmpty);
      expect(booking.hasPendingRatings, isFalse);
    });

    test('الملغي واللي ما حضرش مالهمش تقييم', () {
      for (final scenario in <MockScenario>[
        MockScenario.cancelledBooking,
        MockScenario.noShow,
      ]) {
        MockConfig.scenario = scenario;
        final booking = MockBookings.notices.single;
        expect(booking.hasPendingRatings, isFalse, reason: scenario.title);
      }
    });
  });
}
