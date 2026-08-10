import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_cubit.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';

void main() {
  tearDown(() => MockConfig.scenario = MockScenario.happyPath);

  group('7.2 — الأخصائيين بيتفلتروا بالخدمة', () {
    test('خدمة عادية: الفريق كله + «أي أخصائي متاح»', () {
      final result = MockEmployees.forService('srv-1');

      expect(result.first.isAnyAvailable, isTrue);
      expect(result.where((e) => !e.isAnyAvailable).length, 3);
    });

    test('خدمة بأخصائي واحد — حالة الندرة', () {
      final result = MockEmployees.forService('srv-3');
      final staff = result.where((e) => !e.isAnyAvailable).toList();

      expect(staff.length, 1);
      expect(staff.single.uuid, 'emp-1');
    });

    test('خدمة مالهاش حد: ليستة فاضية بالكامل — من غير «أي أخصائي» كمان', () {
      // مفيش حد يتوزّع عليه، فـ «أي أخصائي متاح» نفسها بتبقى وعد كاذب.
      expect(MockEmployees.forService('srv-7'), isEmpty);
    });

    test('خدمة مش في الخريطة بتاخد الفريق كله', () {
      // محلات تانية لازم تفضل شغالة من غير ما نكتب كل خدمة فيها.
      final result = MockEmployees.forService('srv-999');
      expect(result.where((e) => !e.isAnyAvailable).length, 3);
    });

    test('الـ argument كان بيتجاهل تمامًا قبل كده', () {
      // لو الفلترة اتشالت، التلات نتايج دول هيبقوا متطابقين تاني.
      final a = MockEmployees.forService('srv-1').length;
      final b = MockEmployees.forService('srv-3').length;
      final c = MockEmployees.forService('srv-7').length;

      expect(<int>{a, b, c}.length, 3, reason: 'التلاتة لازم يختلفوا');
    });
  });

  group('7.3 — التقويم بيحسب بمدة الخدمة', () {
    test('خدمة طويلة أيامها المتاحة أقل أو تساوي القصيرة', () {
      final month = DateTime(2026, 9);

      final short = MockSlots.availableDates(month: month, durationMinutes: 20);
      final long = MockSlots.availableDates(month: month, durationMinutes: 180);

      expect(long.length, lessThanOrEqualTo(short.length));
    });

    test('خدمة أطول من يوم العمل مالهاش أيام خالص', () {
      // الفرع بيشتغل ٩–٩، يعني ١٢ ساعة. خدمة ١٣ ساعة مستحيلة.
      final result = MockSlots.availableDates(
        month: DateTime(2026, 9),
        durationMinutes: 13 * 60,
      );

      expect(result, isEmpty);
    });

    test('المدة الافتراضية مابتتغيرش سلوك النداءات القديمة', () {
      final month = DateTime(2026, 9);

      expect(
        MockSlots.availableDates(month: month).length,
        MockSlots.availableDates(month: month, durationMinutes: 45).length,
      );
    });
  });

  group('3.5 — «أي أخصائي متاح» مابتسمّيش حد', () {
    BookingDraftItem itemWith(EmployeeUiModel employee) => BookingDraftItem(
      key: 'k1',
      service: const ServiceUiModel(
        uuid: 'srv-1',
        name: 'قص شعر',
        price: 250,
        durationMinutes: 45,
      ),
      currentMonth: DateTime(2026, 9),
      employee: employee,
    );

    test('الاسم بيفضل اللابل العام حتى بعد اختيار ميعاد', () {
      final item = itemWith(EmployeeUiModel.anyAvailable)
        ..slots = MockSlots.slotsFor(date: DateTime(2026, 9, 7));
      item.selectedSlot = item.slots.first;

      // الميعاد شايل اسم من السيرفر، بس ده **تخمين** — التوزيع بيحصل وقت
      // الحفظ. عرضه كان بيخلي العميل يروح ويلاقي حد تاني.
      expect(item.selectedSlot!.employeeName, isNotEmpty);
      expect(item.resolvedEmployeeName, 'أي أخصائي متاح');
    });

    test('أخصائي بالاسم بيفضل باسمه', () {
      final ahmed = MockEmployees.forService(
        'srv-1',
      ).firstWhere((e) => !e.isAnyAvailable);

      expect(itemWith(ahmed).resolvedEmployeeName, ahmed.name);
    });
  });

  group('7.5 — الترقيم في مواعيدي', () {
    test('أول تحميل بيجيب صفحة واحدة بس', () async {
      MockConfig.scenario = MockScenario.manyBookings;
      MockConfig.delay = Duration.zero;

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();

      expect(MockBookings.upcoming.length, 40);
      expect(cubit.bookings.length, MyBookingsCubit.perPage);
      expect(cubit.hasMore, isTrue);

      await cubit.close();
    });

    test('loadMore بيلحق مايمسحش', () async {
      MockConfig.scenario = MockScenario.manyBookings;
      MockConfig.delay = Duration.zero;

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();
      final firstPage = List.of(cubit.bookings);

      await cubit.loadMore();

      expect(cubit.bookings.length, MyBookingsCubit.perPage * 2);
      // اللي كان على الشاشة لازم يفضل في مكانه وبنفس الترتيب.
      expect(
        cubit.bookings.take(MyBookingsCubit.perPage).map((b) => b.uuid),
        firstPage.map((b) => b.uuid),
      );

      await cubit.close();
    });

    test('بيقف عند آخر صفحة', () async {
      MockConfig.scenario = MockScenario.manyBookings;
      MockConfig.delay = Duration.zero;

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();
      await cubit.loadMore();
      await cubit.loadMore();

      expect(cubit.bookings.length, 40);
      expect(cubit.hasMore, isFalse);

      // نداء زيادة بعد النهاية مابيعملش حاجة.
      await cubit.loadMore();
      expect(cubit.bookings.length, 40);

      await cubit.close();
    });

    test('قايمة قصيرة مالهاش صفحات', () async {
      MockConfig.scenario = MockScenario.happyPath;
      MockConfig.delay = Duration.zero;

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();

      expect(cubit.hasMore, isFalse);
      await cubit.close();
    });

    test('حالة «بيحمّل صفحة زيادة» غير حالة التحميل الأولى', () async {
      MockConfig.scenario = MockScenario.manyBookings;
      MockConfig.delay = Duration.zero;

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();

      final seen = <MyBookingsState>[];
      final sub = cubit.stream.listen(seen.add);
      await cubit.loadMore();
      await sub.cancel();

      // لو طلّعت `MyBookingsLoadingState`، القايمة كانت هتتمسح وتوري
      // سكيلتون والعميل بيقرا تحت صباعه.
      expect(seen.whereType<MyBookingsLoadingMoreState>(), isNotEmpty);
      expect(seen.whereType<MyBookingsLoadingState>(), isEmpty);

      await cubit.close();
    });

    /// **الرد المتأخر بتاع التبويب القديم كان بيتلحق على الجديد.**
    ///
    /// `loadMore` بتحسب مُدخلها قبل الـ`await`. لو العميل غيّر التبويب
    /// والطلب شغّال، كان بيلاقي حجوزات خلصت تحت «القادمة».
    test('تغيير التبويب وسط تحميل صفحة مابيخلطش القايمتين', () async {
      MockConfig.scenario = MockScenario.manyBookings;
      MockConfig.delay = const Duration(milliseconds: 30);

      final cubit = MyBookingsCubit();
      await cubit.loadBookings();
      final upcomingUuids = cubit.bookings.map((b) => b.uuid).toSet();

      // نشغّل الصفحة التانية ومانستناهاش، وبعدين نقلب التبويب.
      final pending = cubit.loadMore();
      cubit.changeTab(1);
      await pending;

      // `changeTab` بينده `loadBookings` بنفسه، فنستنى اللي هو شغّله.
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(cubit.selectedTab, 1);
      for (final booking in cubit.bookings) {
        expect(
          upcomingUuids.contains(booking.uuid),
          isFalse,
          reason: 'حجز من «القادمة» ظهر في «السابقة»',
        );
      }

      await cubit.close();
    });
  });

  /// **حساب الترقيم بيتقاس عند الظرف مش من خلال cubit.**
  ///
  /// الحدود (الصفحة الفاضية، الصفحة المليانة بالظبط، آخر صفحة) هي اللي
  /// بتغلط، ولو اتقاست من خلال `MyBookingsCubit` بتبقى مربوطة بعدد
  /// الحجوزات في الـ fixture — يعني تغيير fixture بيكسر اختبار حسابي.
  group('7.6 — ظرف الترقيم', () {
    List<int> items(int count) => List<int>.generate(count, (i) => i);

    setUp(() => MockConfig.delay = Duration.zero);
    tearDown(() => MockConfig.forceEmpty = false);

    test('بالظبط حجم الصفحة = صفحة واحدة ومفيش كمان', () async {
      final page = (await MockSource.fetchPage(
        items(15),
        page: 1,
        perPage: 15,
      )).getOrElse(() => throw StateError('failed'));

      // الحالة اللي التعبير القديم (`data.length >= perPage && …`) كان
      // بيعديها بالصدفة.
      expect(page.lastPage, 1);
      expect(page.hasMore, isFalse);
      expect(page.total, 15);
    });

    test('٤٠ عنصر = تلات صفحات، والأخيرة ناقصة', () async {
      final first = (await MockSource.fetchPage(
        items(40),
        page: 1,
        perPage: 15,
      )).getOrElse(() => throw StateError('failed'));
      final last = (await MockSource.fetchPage(
        items(40),
        page: 3,
        perPage: 15,
      )).getOrElse(() => throw StateError('failed'));

      expect(first.lastPage, 3);
      expect(first.hasMore, isTrue);
      expect(first.data.length, 15);

      expect(last.currentPage, 3);
      expect(last.hasMore, isFalse);
      expect(last.data.length, 10);
    });

    test('صفحة برّه المدى بترجع فاضية من غير ما ترمي', () async {
      final page = (await MockSource.fetchPage(
        items(40),
        page: 9,
        perPage: 15,
      )).getOrElse(() => throw StateError('failed'));

      expect(page.data, isEmpty);
      expect(page.hasMore, isFalse);
    });

    /// ⚠ `LengthAwarePaginator` بيحسب `max(ceil(0/15), 1)` — يعني **صفحة
    /// واحدة** مش صفر. صفر بيخلي `hasMore` صح بالصدفة وبيبوظ أول ما حد
    /// يكتب `currentPage <= lastPage`.
    test('القايمة الفاضية آخر صفحة فيها ١ مش صفر', () async {
      MockConfig.forceEmpty = true;

      final page = (await MockSource.fetchPage(
        items(40),
        page: 1,
        perPage: 15,
      )).getOrElse(() => throw StateError('failed'));

      expect(page.data, isEmpty);
      expect(page.lastPage, 1);
      expect(page.currentPage, 1);
      expect(page.total, 0);
      expect(page.hasMore, isFalse);
    });

    test('الخطأ بيغلب على كل حاجة', () async {
      MockConfig.scenario = MockScenario.networkError;

      final result = await MockSource.fetchPage(
        items(40),
        page: 1,
        perPage: 15,
      );

      expect(result.isLeft(), isTrue);
    });
  });

  /// **الـ mock كان فرع-محايد بالكامل.**
  ///
  /// كل فرع بيرجّع نفس الخدمات ونفس الأسعار ونفس الطاقم — يعني إصلاح
  /// `changeBranch` كان ينفّذ صح ومحدش يقدر يشوف فرق.
  group('7.7 — بُعد الفرع', () {
    ServiceUiModel serviceIn(List<ServiceUiModel> list, String uuid) =>
        list.firstWhere((s) => s.uuid == uuid);

    test('الفرع التاني أغلى، والتصنيفات بتفضل بصفر', () {
      final main = MockServices.ofBranch(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
      );
      final second = MockServices.ofBranch(
        providerUuid: 'prv-1',
        branchUuid: 'brn-2',
      );

      expect(serviceIn(main, 'srv-1').price, 250);
      expect(serviceIn(second, 'srv-1').price, greaterThan(250));

      // مقرّب لأقرب ٥ — `287.50 ج.م` بتقرا باج حسابي مش تسعيرة فرع.
      for (final service in second) {
        expect(
          service.price % 5,
          0,
          reason: '«${service.name}» طلعت ${service.price}',
        );
      }

      // التصنيف سعره صفر لأنه مش خدمة — المعامل مالوش شغل بيه.
      expect(serviceIn(second, 'srv-4').price, 0);
    });

    test('خدمة مالهاش حد في الفرع التاني بتختفي من قايمته', () {
      final main = MockServices.ofBranch(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
      );
      final second = MockServices.ofBranch(
        providerUuid: 'prv-1',
        branchUuid: 'brn-2',
      );

      // «قص شعر + ذقن» بيعملها أحمد بس، وأحمد في الفرع الرئيسي بس.
      // الاختفاء **مشتق** من الطاقم مش مكتوب في كتالوج تاني.
      expect(main.map((s) => s.uuid), contains('srv-3'));
      expect(second.map((s) => s.uuid), isNot(contains('srv-3')));
    });

    test('الطاقم بيتفلتر بالفرع ومفيهوش «أي أخصائي متاح»', () {
      final main = MockEmployees.rosterOf();
      final second = MockEmployees.rosterOf(branchIndex: 1);

      expect(second.length, lessThan(main.length));
      expect(
        second.map((e) => e.uuid),
        everyElement(isIn(main.map((e) => e.uuid))),
      );
      // ده صف ناس حقيقيين — «أي أخصائي متاح» مفهوم بتاع فلو الحجز.
      expect(main.any((e) => e.isAnyAvailable), isFalse);
      expect(second.any((e) => e.isAnyAvailable), isFalse);
    });

    /// ⚠ `uuid.endsWith('-2')` شكلها صح وغلط: `brn-prv-2` هو الفرع
    /// **الأساسي** بتاع المحل التاني وكان هياخد سعر الفرع التاني.
    test('ترتيب الفرع من القايمة مش من نص الـ uuid', () {
      expect(
        MockProviders.branchIndexOf(
          providerUuid: 'prv-2',
          branchUuid: 'brn-prv-2',
        ),
        0,
      );
      expect(
        MockProviders.branchIndexOf(providerUuid: 'prv-1', branchUuid: 'brn-2'),
        1,
      );
      // uuid مش تابع للمحل بيرجع للأساسي بدل ما يرمي.
      expect(
        MockProviders.branchIndexOf(
          providerUuid: 'prv-1',
          branchUuid: 'brn-مش-موجود',
        ),
        0,
      );
    });

    /// القيمة الافتراضية هي اللي بتحمي كل النداءات اللي اتكتبت قبل
    /// بُعد الفرع.
    test('النداء من غير فرع = الفرع الرئيسي بالحرف', () {
      expect(
        MockEmployees.forService('srv-1').map((e) => e.uuid),
        MockEmployees.forService('srv-1', branchIndex: 0).map((e) => e.uuid),
      );
      expect(
        MockServices.ofBranch(providerUuid: 'prv-1').map((s) => s.price),
        MockServices.ofProvider('prv-1').map((s) => s.price),
      );
    });

    test('ولاد التصنيف بياخدوا سعر الفرع كمان', () {
      final main = MockServices.childrenOfBranch(
        'srv-4',
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
      );
      final second = MockServices.childrenOfBranch(
        'srv-4',
        providerUuid: 'prv-1',
        branchUuid: 'brn-2',
      );

      expect(main, isNotEmpty);
      expect(second.length, main.length);
      for (var i = 0; i < main.length; i++) {
        expect(second[i].price, greaterThan(main[i].price));
      }
    });
  });
}
