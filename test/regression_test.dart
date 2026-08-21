import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_mock_service.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_mock_service.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_mock_service.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/repo/create_booking_repo.dart';

/// باجات اتلقت في مراجعة شغل الأسابيع ١–٣.
///
/// كل اختبار هنا **وقع فعلاً** قبل ما يتصلّح. الغرض إنهم مايرجعوش.
/// بيستنى لحد ما [condition] تبقى صح، أو يطلع وقته.
///
/// بديل `Future.delayed` بمدة مخمّنة: المدة الثابتة بتبقى معايرة لعدد
/// نداءات معيّن، فأول ما العدد يتغيّر الاختبار يبقى هش من غير ما السلوك
/// يتكسر.
Future<void> _until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  setUp(() {
    MockConfig.delay = Duration.zero;
    // ⚠ **حالة ساكنة لازم تتصفّر.** محاكاة «الميعاد راح» بتوقّع
    // مرة واحدة في الجلسة (عشان العميل يقدر يكمّل بعدها)، فمن غير
    // التصفير أول اختبار بيحرقها واللي بعده مايشوفهاش.
    CreateBookingMockService.resetScenario();
  });
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

  /// **«احجز تاني» من التفاصيل كان بيوقّع العميل على مختار الخدمات.**
  ///
  /// المدخل التاني لنفس الـ sheet (بطاقة الإشعار في «مواعيدي») كان بيبعت
  /// `serviceUuid` من الأول، فنفس الزرار بالظبط كان بيدّي نتيجتين مختلفتين
  /// على حسب العميل دخل منين. والتعليق اللي في الشاشة كان بيقول إن ده
  /// مستحيل لأن `serviceUuid` مش موجود — وهو حقل **مطلوب** من الأصل.
  group('«احجز تاني» بيتخطى اختيار الخدمة', () {
    test('الخدمة بتتحط في السلة والخطوة بتبقى الميعاد', () async {
      final booking = MockBookings.upcoming.first;

      // نفس النداء اللي `_rebook` بيعمله بالظبط.
      final cubit = CreateBookingCubit(
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: booking.providerUuid,
        providerName: booking.providerName,
        initialBranchUuid: booking.branchUuid,
        initialServiceUuid: booking.items.first.serviceUuid,
      );
      await cubit.bootstrap();

      expect(cubit.currentStep, BookingStep.dateTime);
      expect(cubit.items.single.service.uuid, booking.items.first.serviceUuid);
      addTearDown(cubit.close);
    });

    /// الحقل اللي التعليق القديم كان بيقول إنه مش موجود.
    test('كل بند في كل حجز عنده serviceUuid', () {
      for (final booking in <BookingUiModel>[
        ...MockBookings.upcoming,
        ...MockBookings.past,
      ]) {
        for (final item in booking.items) {
          expect(
            item.serviceUuid,
            isNotEmpty,
            reason: '«${item.serviceName}» في ${booking.uuid} من غير uuid',
          );
        }
      }
    });
  });

  /// **العميل كان بيكتب رأيه والأبلكيشن بيرميه.**
  ///
  /// نفس الباج اللي `cancelBooking` اتصلّح منه — واتصلّح في نصه بس.
  group('تعليق التقييم بيوصل', () {
    test('اللي اتكتب بيتخزّن على الخدمة', () async {
      MockConfig.scenario = MockScenario.completedUnrated;
      final booking = MockBookings.past.first;
      final item = booking.rateableItems.first;

      final cubit = BookingDetailsCubit(BookingDetailsRepo(
        const BookingDetailsMockService(),
        const BookingDetailsMockService(),
      ), bookingUuid: booking.uuid)
        ..startRating(item)
        ..changeRating(4);
      cubit.rateCommentController.text = '  الحلاقة كانت ممتازة  ';

      await cubit.submitRating();

      expect(item.rating, 4);
      // مقصوص من الجناب — نفس اللي `cancelBooking` بيعمله بالظبط.
      expect(item.ratingComment, 'الحلاقة كانت ممتازة');
      // والحقل بيتفضّى بعد الإرسال عشان التقييم اللي بعده يبدأ نضيف.
      expect(cubit.rateCommentController.text, isEmpty);

      await cubit.close();
    });

    test('من غير تعليق مافيش حاجة تتعرض', () async {
      MockConfig.scenario = MockScenario.completedUnrated;
      final booking = MockBookings.past.first;
      final item = booking.rateableItems.first;

      final cubit = BookingDetailsCubit(BookingDetailsRepo(
        const BookingDetailsMockService(),
        const BookingDetailsMockService(),
      ), bookingUuid: booking.uuid)
        ..startRating(item)
        ..changeRating(5);

      await cubit.submitRating();

      expect(item.rating, 5);
      expect(item.ratingComment, isEmpty);

      await cubit.close();
    });
  });

  /// **`changeBranch` كان بيحطّ الفرع ويـ`emit` وبس.**
  ///
  /// وتعليقه فوقه بيقول «بيحمّل الخدمات من الأول» — يعني التوثيق كان
  /// بيوصف كود مش موجود. النتيجة إن العميل بيغيّر الفرع وبيفضل بيبصّ على
  /// أسعار وأخصائيين الفرع اللي ساب.
  group('تغيير الفرع في شاشة المحل بيعيد التحميل فعلاً', () {
    test('الأسعار والأخصائيين بيتغيّروا', () async {
      final cubit = ServiceProviderDetailsCubit(ServiceProviderDetailsRepo(
        const ServiceProviderDetailsMockService(),
        const ServiceProviderDetailsMockService(),
      ), providerUuid: 'prv-1');
      await cubit.loadDetails();

      final before = cubit.services.map((s) => s.price).toList();
      final staffBefore = cubit.employees.map((e) => e.uuid).toList();
      expect(before, isNotEmpty);
      expect(staffBefore, isNotEmpty);

      await cubit.changeBranch(cubit.branches[1]);

      expect(cubit.services.map((s) => s.price), isNot(before));
      expect(cubit.employees.map((e) => e.uuid), isNot(staffBefore));
      expect(cubit.isReloadingBranch, isFalse);

      await cubit.close();
    });

    /// **الشارة فوق كانت بتقول ٢٥٠ والصف تحتها بيقول ٢٩٠.**
    ///
    /// `ProviderUiModel.priceFrom` و`servicesCount` مستوى **المحل**، فأول
    /// ما الأسعار بقت فرعية بقوا بيناقضوا القايمة اللي تحتيهم على نفس
    /// الشاشة من غير سكرول.
    test('«يبدأ من» وعدد الخدمات بيتحسبوا من خدمات الفرع', () async {
      final cubit = ServiceProviderDetailsCubit(ServiceProviderDetailsRepo(
        const ServiceProviderDetailsMockService(),
        const ServiceProviderDetailsMockService(),
      ), providerUuid: 'prv-1');
      await cubit.loadDetails();

      double cheapest(List<ServiceUiModel> list) => list
          .where((s) => !s.isCategory && s.price > 0)
          .map((s) => s.price)
          .reduce((a, b) => a < b ? a : b);

      final before = cheapest(cubit.services);
      await cubit.changeBranch(cubit.branches[1]);

      expect(cheapest(cubit.services), greaterThan(before));

      await cubit.close();
    });

    /// الأخصائيين كانوا بيتحمّلوا بـ`forService('')` — نص فاضي بيقع في
    /// الـ `null` بتاع خريطة الخدمات فبيرجّع الفريق كله **بالصدفة**.
    test('الأخصائيين طاقم الفرع مش الفريق كله بالصدفة', () async {
      final cubit = ServiceProviderDetailsCubit(ServiceProviderDetailsRepo(
        const ServiceProviderDetailsMockService(),
        const ServiceProviderDetailsMockService(),
      ), providerUuid: 'prv-1');
      await cubit.loadDetails();

      expect(
        cubit.employees.map((e) => e.uuid),
        MockEmployees.rosterOf().map((e) => e.uuid),
      );
      expect(cubit.employees.any((e) => e.isAnyAvailable), isFalse);

      await cubit.changeBranch(cubit.branches[1]);
      expect(
        cubit.employees.map((e) => e.uuid),
        MockEmployees.rosterOf(branchIndex: 1).map((e) => e.uuid),
      );

      await cubit.close();
    });
  });

  group('تغيير الفرع بيعيد تحميل الكارت المفتوح', () {
    test('الكارت مابيفضلش فاضي بعد التغيير', () async {
      final cubit = CreateBookingCubit(
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();
      await cubit.bootstrap();

      // ⚠ **استنى على الحالة مش على مدة ثابتة.**
      //
      // الاقتراحات بقت نداء تواريخ + نداءات مواعيد متوازية بدل نداء
      // واحد. الـ٢٠ ملي ثانية كانت معايرة للنداء الواحد، وبقت بتقع
      // لما الاختبارات تتشغّل مع بعض (حمل على الجهاز). الانتظار على
      // النتيجة مش على الوقت بيشيل الهشاشة دي خالص.
      await _until(() => cubit.items.single.proposals.isNotEmpty);
      expect(cubit.items.single.proposals, isNotEmpty);

      final other = MockProviders.branchesOf('prv-1')[1];
      cubit.selectBranch(other);

      // `_clearScheduling` بيفضّي التواريخ، و`enterDateTimeStep` بيرجع
      // من غير ما يعمل حاجة لو فيه كارت مفتوح — فالكارت كان بيفضل مفتوح
      // على تقويم من غير أيام.
      await _until(() => cubit.items.single.proposals.isNotEmpty);

      expect(cubit.selectedBranch?.uuid, other.uuid);
      expect(cubit.items.single.proposals, isNotEmpty);

      await cubit.close();
    });

    test('اختيار نفس الفرع مابيرميش الشغل', () async {
      final cubit = CreateBookingCubit(
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();
      await cubit.bootstrap();

      await _until(() => cubit.items.single.proposals.isNotEmpty);
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
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialServiceUuid: 'srv-1',
      )..enterDateTimeStep();
      await cubit.bootstrap();

      await _until(() => cubit.items.single.proposals.isNotEmpty);
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
    test('«احجز تاني» بيفتح على فرع الحجز القديم', () async {
      final cubit = CreateBookingCubit(
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        // فرع مدينة نصر — مش الأول في القايمة.
        initialBranchUuid: 'brn-2',
      );
      await cubit.bootstrap();

      expect(cubit.selectedBranch?.uuid, 'brn-2');
      cubit.close();
    });

    test('uuid مش موجود بيقع على أول فرع', () async {
      final cubit = CreateBookingCubit(
        CreateBookingRepo(
      const CreateBookingMockService(),
      const CreateBookingMockService(),
    ),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        initialBranchUuid: 'brn-does-not-exist',
      );
      await cubit.bootstrap();

      expect(cubit.selectedBranch?.uuid, 'brn-1');
      cubit.close();
    });
  });

  /// **النص كان بيقول قاعدة السيرفر مالهاش وجود.**
  ///
  /// `Booking::getCanCancelAttribute()` بيقفل الإلغاء لما الميعاد
  /// **يعدّي** — مش عشان هو في نفس اليوم. والفيكستشر كانت مشفّرة نفس
  /// سوء الفهم، فأي حد يقراها كان هيعيد استنتاج النص الغلط.
  group('نافذة الإلغاء', () {
    test('حجز النهاردة اللي لسه ما بدأش ينفع يتلغي', () {
      MockConfig.scenario = MockScenario.happyPath;
      final booking = MockBookings.upcoming.single;

      expect(booking.canCancel, isTrue);
    });

    test('الميعاد اللي بدأ الإلغاء عنده مقفول', () {
      MockConfig.scenario = MockScenario.cancelWindowClosed;
      final booking = MockBookings.upcoming.single;

      expect(booking.canCancel, isFalse);
      // بدأ فعلاً — مش «النهاردة» وبس.
      expect(booking.items.first.startAt.isBefore(DateTime.now()), isTrue);
      // ولسه في «القادمة» عشان الفرع ما علّمش الوصول، وده اللي بيخلي
      // العميل يلاقيه ويدوس عليه.
      expect(booking.status, BookingStatus.confirmed);
    });

    /// الحالة دي مكانش ليها fixture خالص، فالنص عمره ما اتشاف في سياقه.
    test('فيه سيناريو واحد بالظبط بيوصّل للحالة دي', () {
      final producing = <MockScenario>[];

      for (final scenario in MockScenario.values) {
        MockConfig.scenario = scenario;
        if (MockBookings.upcoming.any((b) => !b.canCancel)) {
          producing.add(scenario);
        }
      }

      // حالات الفرع بتديها كمان — وده **صح** بقاعدة السيرفر: «وصل»
      // و«مستني» و«في الخدمة» كلهم معناهم إن الميعاد بدأ.
      expect(producing, contains(MockScenario.cancelWindowClosed));
      for (final scenario in producing) {
        expect(
          scenario == MockScenario.cancelWindowClosed || scenario.isInBranch,
          isTrue,
          reason: '«${scenario.title}» بيقفل الإلغاء من غير ما الميعاد يبدأ',
        );
      }
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

      // `canCancel` في البصمة عشان `cancelWindowClosed` **كل فرقها هو
      // ده** — من غيره البصمة مابتشوفش الحاجة اللي السيناريو معمول عشانها.
      //
      // وحالة كل زيارة لنفس السبب بالظبط: بقى ينفع سيناريوهين يتطابقوا في
      // كل حاجة ويفترقوا في إن زيارة خلصت والتانية لأ — وده فرق **بيبان
      // على الشاشة**، بلوك «إنت في الفرع» بيظهر ولا لأ.
      String describe(List<BookingUiModel> list) => list
          .map(
            (b) =>
                '${b.status.name}:${b.branchUuid}:${b.canCancel}'
                ':${b.visits.map((v) => '${v.uuid}=${v.status.name}').join('+')}'
                ':${b.items.map((i) => '${i.serviceUuid}@${i.startAt}=${i.price}/${i.ratingStatus.name}').join(',')}',
          )
          .join(' , ');

      final waitlist = MockWaitlist.forUser(
        DateTime.now(),
      ).map((e) => '${e.status.name}:${e.serviceName}').join(' , ');

      // **بلوك «إنت في الفرع» جزء من اللي التستر بيشوفه.**
      //
      // `waitingInBranch` و`waitingNoEstimate` بيعرضوا **نفس الحجز
      // بالظبط** — وده مقصود، عشان المقارنة بينهم تبقى على متغيّر واحد.
      // الفرق كله عايش في `MockInBranch`. من غير السطر ده البصمة بتشوف
      // السيناريوهين متطابقين وبتفشل على تطابق حقيقي ومقصود.
      //
      // بناخد `hasLiveEstimate` مش النص: التقدير نفسه بيتحرّك مع ساعة
      // الجهاز، فالنص كان هيدّي بصمات مختلفة كل ثانية ويخفي أي تصادم
      // حقيقي ورا فرق وهمي.
      final inBranch = MockBookings.upcoming
          .map((b) => MockInBranch.forBooking(b, DateTime.now()))
          .map((d) => d == null ? '—' : '${d.status.name}/${d.hasLiveEstimate}')
          .join(' , ');

      return 'قادمة[${describe(MockBookings.upcoming)}] '
          'سابقة[${describe(MockBookings.past)}] '
          'إشعارات[${describe(MockBookings.notices)}] '
          'انتظار[$waitlist] '
          'في الفرع[$inBranch]';
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
        byFingerprint
            .putIfAbsent(fingerprintOf(scenario), () => [])
            .add(scenario);
      }

      final clashes = byFingerprint.entries.where((e) => e.value.length > 1);

      expect(
        clashes,
        isEmpty,
        reason:
            'سيناريوهات بتعرض نفس الحجوزات بالحرف: '
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
