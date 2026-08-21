import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_mock_service.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_mock_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/booking_details_screen.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/follow_up_teaser_widget.dart';

/// **التنبيه بالمتابعة في تفاصيل الحجز — المدخل التالت.**
///
/// المتابعة بتتولد **لوحدها** لما خدمة تخلص. العميلة ما طلبتهاش ومش عارفة
/// إنها بقت ليها — فلو استنينا لحد ما تفتح «باقاتي»، هي لازم تدوّر على
/// حاجة مش متأكدة إنها موجودة.
///
/// الاختبارات هنا بتحرس تلات حاجات:
///
///  1. **الربط بيحصل على حجز حقيقي.** لو الـuuid في الفكسشر ما طابقش حجز
///     في `MockBookings`، التنبيه مايظهرش أبدًا **ومحدش هيلاحظ** — الشاشة
///     هتبان طبيعية.
///  2. **النداء الزيادة للمكتمل بس.** حجز جاي أو ملغي عمره ما هيبقى ليه
///     متابعة، فنداء شبكة عشان نتأكد تكلفة على كل فتحة تفاصيل.
///  3. **الأخصائي اللي مشي بيغيّر النص مش بيخفيه** (BE-A5).
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
    MockConfig.delay = Duration.zero;
    MockBookings.resetSession();
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });

  BookingDetailsCubit build(String uuid) => BookingDetailsCubit(
    BookingDetailsRepo(
      const BookingDetailsMockService(),
      const BookingDetailsMockService(),
    ),
    EntitlementsRepo(
      const EntitlementsMockService(),
      const EntitlementsMockService(),
    ),
    bookingUuid: uuid,
  );

  Future<void> pump(WidgetTester tester, WidgetBuilder build) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          locale: const Locale('ar', 'EG'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(child: Builder(builder: build)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('الربط بالحجز', () {
    test('الفكسشر بيشاور على حجز مكتمل موجود فعلاً', () {
      final target = MockEntitlements.followUpFree.originalBookingUuid;

      // ⚠ الاختبار ده هو اللي بيمسك انفصال الفكسشرز في صمت.
      final match = MockBookings.past.where((b) => b.uuid == target);
      expect(
        match,
        isNotEmpty,
        reason: 'المتابعة مربوطة بحجز مش موجود في الفكسشرز',
      );
      expect(match.first.status, BookingStatus.completed);
    });

    test('الحجز المكتمل بيلاقي متابعته', () async {
      final uuid = MockEntitlements.followUpFree.originalBookingUuid;
      final cubit = build(uuid);
      await cubit.loadBooking();

      expect(cubit.followUp, isNotNull);
      expect(cubit.followUp!.uuid, MockEntitlements.followUpFree.uuid);
      await cubit.close();
    });

    test('الحجز الجاي مابيسألش أصلاً', () async {
      final upcoming = MockBookings.upcoming.first;
      final cubit = build(upcoming.uuid);
      await cubit.loadBooking();

      expect(upcoming.status, isNot(BookingStatus.completed));
      expect(cubit.followUp, isNull);
      await cubit.close();
    });

    test('مكتمل من غير متابعة = مفيش تنبيه', () async {
      // حجز مكتمل تاني مش مربوط بأي متابعة في السيناريو الافتراضي.
      final other = MockBookings.past.firstWhere(
        (b) =>
            b.uuid != MockEntitlements.followUpFree.originalBookingUuid &&
            b.uuid != MockEntitlements.followUpDiscounted.originalBookingUuid,
        orElse: () => MockBookings.past.first,
      );

      final cubit = build(other.uuid);
      await cubit.loadBooking();

      if (other.uuid != MockEntitlements.followUpFree.originalBookingUuid) {
        expect(cubit.followUp, isNull);
      }
      await cubit.close();
    });
  });

  group('نص التنبيه', () {
    test('المجانية بتقول مجانية وبتاريخ', () {
      final teaser = FollowUpTeaserWidget(
        followUp: MockEntitlements.followUpFree,
      );
      expect(teaser.message, contains('مجانية'));
      // ⚠ التاريخ مش اختياري — «متابعة مجانية» من غير صلاحية بتقرا عرض
      // مفتوح، وهي بتنتهي فعلاً.
      expect(teaser.message, contains('لحد'));
    });

    test('اللي بخصم بتقول السعر', () {
      final teaser = FollowUpTeaserWidget(
        followUp: MockEntitlements.followUpDiscounted,
      );
      expect(teaser.message, contains('خصم'));
      expect(teaser.message, contains('150'));
    });
  });

  group('الرسم', () {
    testWidgets('المتابعة القابلة للحجز فيها زرار', (tester) async {
      await pump(
        tester,
        (_) => FollowUpTeaserWidget(
          followUp: MockEntitlements.followUpFree,
          onTap: () {},
        ),
      );

      expect(find.text('ليكي متابعة'), findsOneWidget);
      expect(find.text('احجز المتابعة'), findsOneWidget);
    });

    testWidgets('الأخصائي مشي = نص مختلف ومفيش زرار — BE-A5', (tester) async {
      await pump(
        tester,
        (_) => FollowUpTeaserWidget(
          followUp: MockEntitlements.followUpEmployeeLeft,
          // الشاشة مابتبعتش `onTap` للحالة دي أصلاً، وحتى لو بعتته
          // الـwidget بيتجاهله عشان الفرع بيرجع بانر تاني.
          onTap: () {},
        ),
      );

      expect(find.textContaining('مابقاش متاح'), findsOneWidget);
      expect(find.text('احجز المتابعة'), findsNothing);
    });
  });

  group('على الشاشة نفسها — end to end', () {
    /// ⚠ **ده الاختبار اللي بيثبت إن التنبيه بيوصل للعميلة فعلاً.**
    ///
    /// المتابعة بتتجاب في نداء **تاني** بعد ما الحجز يوصل، والكيوبت بيعمل
    /// `emit(BookingDetailsSuccessState())` تاني عشان الشاشة تتبني. لو
    /// الحالات دي كانت `Equatable` بمقارنة بالقيمة، الـemit التاني كان
    /// هيتبلع (نفس الحالة) و**التنبيه مكانش هيظهر أبدًا** — والاختبار
    /// اللي بيقرا `cubit.followUp` بس كان هيعدّي وهو مبسوط.
    testWidgets('تفاصيل الحجز المكتمل بتوري التنبيه', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final uuid = MockEntitlements.followUpFree.originalBookingUuid;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            theme: appTheme(),
            locale: const Locale('ar', 'EG'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocProvider<BookingDetailsCubit>(
                create: (_) => build(uuid)..loadBooking(),
                child: const BookingDetailsScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      expect(find.text('ليكي متابعة'), findsOneWidget);
      expect(find.text('احجز المتابعة'), findsOneWidget);
    });

    testWidgets('الحجز الجاي مافيهوش تنبيه', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            theme: appTheme(),
            locale: const Locale('ar', 'EG'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocProvider<BookingDetailsCubit>(
                create: (_) =>
                    build(MockBookings.upcoming.first.uuid)..loadBooking(),
                child: const BookingDetailsScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('ليكي متابعة'), findsNothing);
    });
  });
}
