import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
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

      final short = MockSlots.availableDates(
        month: month,
        durationMinutes: 20,
      );
      final long = MockSlots.availableDates(
        month: month,
        durationMinutes: 180,
      );

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
  });
}
