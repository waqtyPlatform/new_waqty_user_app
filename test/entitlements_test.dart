import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/repo/my_bookings_repo.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_mock_service.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_mock_service.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_service.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_progress_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_strip_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_session_card_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_usage_card_widget.dart';

/// **الباقات والمتابعات.**
///
/// الاختبارات هنا بتحرس تلات حاجات، كل واحدة فيها كانت هتعدّي من المراجعة
/// وتوصل لعميلة:
///
///  1. **النوعين مايختلطوش.** كارت وحدات بيقول «جلسات» أو العكس = رقم
///     مالوش معنى على شاشة فيها فلوس العميلة.
///  2. **المحجوز شريحة لوحده.** لو اتلمّ مع المتاح، العميلة بتشوف جلسة
///     تقدر تحجزها وهي محجوزة أصلاً.
///  3. **الحجز مقفول للباقات وشغّال للمتابعات** — الفرق ده حدود العقد
///     الحالي (BE-A1)، ولو اتلخبط بيطلع زرار بيفشل.
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
    MockConfig.delay = Duration.zero;
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });

  EntitlementsCubit buildCubit([EntitlementsService? service]) =>
      EntitlementsCubit(
        EntitlementsRepo(
          service ?? const EntitlementsMockService(),
          service ?? const EntitlementsMockService(),
        ),
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

  group('قراية الأنواع', () {
    test('multi_session بيتفرز جلسات', () {
      final parsed = PackageEntitlementUiModel.fromJson(<String, dynamic>{
        'uuid': 'p1',
        'package_type': 'multi_session',
        'package_name': 'باقة قص',
        'service_name': 'قص شعر',
        'total_sessions': 8,
        'completed_sessions': 4,
        'reserved_sessions': 1,
        'available_sessions': 3,
        'status': 'active',
        'can_book': true,
      });

      expect(parsed, isA<SessionPackageEntitlement>());
      expect((parsed as SessionPackageEntitlement).reservedSessions, 1);
      expect(parsed.isSingleVisit, isFalse);
    });

    test('single_visit بيتفرز جلسات كمان بس متعلّم', () {
      final parsed = PackageEntitlementUiModel.fromJson(<String, dynamic>{
        'uuid': 'p2',
        'package_type': 'single_visit',
        'package_name': 'يوم العروسة',
        'service_name': 'مكياج',
        'total_sessions': 1,
        'available_sessions': 1,
        'status': 'active',
        'can_book': true,
      });

      expect((parsed as SessionPackageEntitlement).isSingleVisit, isTrue);
    });

    test('usage_based بيتفرز بركة بدفترها', () {
      final parsed = PackageEntitlementUiModel.fromJson(<String, dynamic>{
        'uuid': 'p3',
        'package_type': 'usage_based',
        'package_name': 'رصيد مساج',
        'unit_name': 'دقيقة',
        'total_units_purchased': 300,
        'total_units_consumed': 165,
        'available_units': 120,
        'expired_units': 15,
        'purchase_count': 1,
        'can_book': true,
        'allowed_services': <Map<String, dynamic>>[
          {'service_uuid': 's1', 'name': 'مساج', 'duration': 60},
        ],
        'usage_history': <Map<String, dynamic>>[
          {
            'uuid': 't1',
            'type': 'consume',
            'units': 60,
            'balance_before': 195,
            'balance_after': 135,
          },
        ],
      });

      expect(parsed, isA<UsagePackageEntitlement>());
      final usage = parsed as UsagePackageEntitlement;
      expect(usage.availableUnits, 120);
      expect(usage.expiredUnits, 15);
      expect(usage.allowedServices.single.name, 'مساج');
      expect(usage.usageHistory.single.isDebit, isTrue);
    });

    test('الرد مافيهوش provider ولا branch — الموديل مابيخترعهمش', () {
      // BE-A1. الاختبار ده بيقع لو حد ضاف الحقول من غير ما السيرفر يبعتها.
      final fields = SessionPackageEntitlement.fromJson(<String, dynamic>{
        'uuid': 'p1',
        'package_type': 'multi_session',
        'package_name': 'باقة',
      });
      expect(fields.isBookableFromApp, isFalse);
      expect(fields.blockedReason, contains('كلّم الفرع'));
    });
  });

  group('الشريط بتلات شرايح', () {
    testWidgets('المحجوز بيترسم لوحده مش مع المتاح', (tester) async {
      await pump(
        tester,
        (_) => const EntitlementProgressWidget(
          used: 4,
          reserved: 1,
          available: 3,
        ),
      );

      // تلات لابلات = تلات كميات مميزة. لو المحجوز اتلمّ مع حاجة تانية
      // اللابل بتاعه بيختفي وده اللي بنمسكه.
      expect(find.textContaining('متاح 3'), findsOneWidget);
      expect(find.textContaining('محجوز 1'), findsOneWidget);
      expect(find.textContaining('مستخدم 4'), findsOneWidget);
    });

    testWidgets('الكمية الصفر مابتاخدش لابل', (tester) async {
      await pump(
        tester,
        (_) => const EntitlementProgressWidget(
          used: 4,
          reserved: 0,
          available: 3,
        ),
      );

      expect(find.textContaining('محجوز'), findsNothing);
    });

    testWidgets('الإجمالي صفر = مافيش شريط خالص', (tester) async {
      await pump(
        tester,
        (_) => const EntitlementProgressWidget(
          used: 0,
          reserved: 0,
          available: 0,
        ),
      );

      expect(
        tester.getSize(find.byType(EntitlementProgressWidget)),
        Size.zero,
      );
    });
  });

  group('النوعين مايختلطوش', () {
    testWidgets('كارت الجلسات بيقول «جلسات» ومابيقولش «وحدة»', (tester) async {
      await pump(
        tester,
        (_) => PackageSessionCardWidget(package: MockEntitlements.multiSession),
      );

      expect(find.textContaining('جلسات'), findsWidgets);
      expect(find.textContaining('وحدة'), findsNothing);
    });

    testWidgets('كارت الوحدات بيقول اسم الوحدة من السيرفر', (tester) async {
      await pump(
        tester,
        (_) => PackageUsageCardWidget(package: MockEntitlements.usageBased),
      );

      // «دقيقة» جاية من `unit_name` — مش كلمة إحنا اخترناها.
      expect(find.textContaining('فاضل 120 دقيقة'), findsOneWidget);
      // والمنتهي سطر ثانوي، مش داخل الرقم الأساسي.
      expect(find.textContaining('15 دقيقة انتهت صلاحيتها'), findsOneWidget);
    });
  });

  group('الحجز — الحدود الحقيقية للعقد', () {
    test('كل الباقات مقفولة من التطبيق — BE-A1', () {
      expect(MockEntitlements.multiSession.isBookableFromApp, isFalse);
      expect(MockEntitlements.usageBased.isBookableFromApp, isFalse);
      expect(MockEntitlements.singleVisit.isBookableFromApp, isFalse);
    });

    test('المتابعة اللي ليها حجز أصلي بتتحجز', () {
      expect(MockEntitlements.followUpFree.isBookableFromApp, isTrue);
      expect(MockEntitlements.followUpDiscounted.isBookableFromApp, isTrue);
    });

    test('الأخصائي مشي = مقفولة ومابنرخّيش القاعدة — BE-A5', () {
      final orphan = MockEntitlements.followUpEmployeeLeft;
      expect(orphan.isOrphaned, isTrue);
      expect(orphan.isBookableFromApp, isFalse);
    });

    test('من غير حجز أصلي مفيش طريق للفرع', () {
      const stranded = FollowUpEntitlementUiModel(
        uuid: 'x',
        serviceName: 'خدمة',
        status: PackageStatus.active,
        availableCount: 1,
      );
      expect(stranded.isBookableFromApp, isFalse);
    });
  });

  group('الحالات النهائية', () {
    test('المنتهية بجلسات لسه — بتفضل بحالتها من السيرفر', () {
      final expired = MockEntitlements.expired;
      expect(expired.status, PackageStatus.expired);
      // ⚠ فيها جلستين متاحين ورغم كده منتهية. **مابنحسبش الحالة عندنا** —
      // لو حسبناها من `availableSessions > 0` كانت هتبان شغّالة.
      expect(expired.availableSessions, 2);
      expect(expired.status.isTerminal, isTrue);
    });

    test('المكتملة مش في العدّاد', () async {
      MockConfig.scenario = MockScenario.packageExpired;
      final cubit = buildCubit();
      await cubit.load();

      // الاتنين (منتهية ومكتملة) مش قابلين للتصرف.
      expect(cubit.packages.length, 2);
      expect(cubit.actionableCount, 0);
      await cubit.close();
    });

    test('تنتهي قريب بتتحسب من ٧ أيام', () {
      final soon = MockEntitlements.expiringSoon;
      expect(soon.expiresSoon(now: DateTime(2026, 8, 21, 12)), isTrue);
      expect(MockEntitlements.multiSession.expiresSoon(), isFalse);
    });
  });

  group('الكيوبت', () {
    test('بيحمّل الاتنين', () async {
      MockConfig.scenario = MockScenario.packageMultiSession;
      final cubit = buildCubit();
      await cubit.load();

      expect(cubit.packages, isNotEmpty);
      expect(cubit.state, isA<EntitlementsLoaded>());
      await cubit.close();
    });

    test('التبويب الفاضي حالته Empty مش Loaded بليستة فاضية', () async {
      MockConfig.scenario = MockScenario.packageMultiSession;
      final cubit = buildCubit();
      await cubit.load();

      // السيناريو ده فيه باقات ومفيش متابعات.
      cubit.selectTab(EntitlementTab.followUps);
      expect(cubit.state, isA<EntitlementsEmpty>());

      cubit.selectTab(EntitlementTab.packages);
      expect(cubit.state, isA<EntitlementsLoaded>());
      await cubit.close();
    });

    test('فشل نداء واحد مابينهارش الشاشة — حالة «جزئي»', () async {
      final cubit = buildCubit(const _HalfBrokenService());
      await cubit.load();

      // الباقات وصلت، فالشاشة بتعرضها والخطأ بيتاكل.
      expect(cubit.packages, isNotEmpty);
      expect(cubit.state, isNot(isA<EntitlementsError>()));
      await cubit.close();
    });

    test('فشل الاتنين = خطأ', () async {
      final cubit = buildCubit(const _BrokenService());
      await cubit.load();

      expect(cubit.state, isA<EntitlementsError>());
      await cubit.close();
    });

    test('الحجز الفاشل بيسيب الرسالة عشان الشيت يعرضها', () async {
      MockConfig.scenario = MockScenario.slotLostAtConfirm;
      final cubit = buildCubit();
      await cubit.bookFollowUp(
        uuid: 'fu-free-1',
        bookingDate: '2026-09-01',
        startTime: '14:30',
      );

      expect(cubit.state, isA<EntitlementBookingFailed>());
      expect(cubit.bookingError, contains('اتحجز'));
      await cubit.close();
    });
  });

  group('الشريط في «حجوزاتي»', () {
    test('بيتكلم عن باقة بالاسم مش عن مجموع', () {
      final strip = EntitlementStripWidget(
        package: MockEntitlements.multiSession,
        followUpCount: 0,
      );
      expect(strip.message, contains('باقة قص الشعر'));
      expect(strip.message, contains('3'));
    });

    test('من غير باقات بيتكلم عن المتابعات', () {
      const strip = EntitlementStripWidget(package: null, followUpCount: 2);
      expect(strip.message, contains('متابعات'));
    });

    test('مافيش حاجة = مفيش رسالة', () {
      const strip = EntitlementStripWidget(package: null, followUpCount: 0);
      expect(strip.message, isNull);
    });
  });

  group('تبويب «باقاتي» جوه «حجوزاتي»', () {
    /// التبويب التالت محتواه من `EntitlementsCubit` بالكامل، فنداء
    /// `GET /user/bookings` لما يتفتح مش بس هدر شبكة — بيدوس على
    /// `bookings` بنتيجة `upcoming: false`، فالعميلة لما ترجع
    /// لـ«القادمة» بتلاقي السابقة مكانها.
    test('التبديل ليه مابيجيبش حجوزات', () async {
      MockConfig.scenario = MockScenario.happyPath;
      final cubit = MyBookingsCubit(
        MyBookingsRepo(
          const MyBookingsMockService(),
          const MyBookingsMockService(),
        ),
      );
      await cubit.loadBookings();
      final upcoming = List<Object>.from(cubit.bookings);

      cubit.changeTab(MyBookingsCubit.entitlementsTab);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.selectedTab, MyBookingsCubit.entitlementsTab);
      // القايمة زي ما هي — مااتدهستش بنتيجة نداء مالوش لازمة.
      expect(cubit.bookings, orderedEquals(upcoming));
      await cubit.close();
    });

    test('الرجوع لـ«القادمة» بيجيب تاني', () async {
      MockConfig.scenario = MockScenario.happyPath;
      final cubit = MyBookingsCubit(
        MyBookingsRepo(
          const MyBookingsMockService(),
          const MyBookingsMockService(),
        ),
      );
      cubit.changeTab(MyBookingsCubit.entitlementsTab);
      cubit.changeTab(0);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.selectedTab, 0);
      expect(cubit.bookings, isNotEmpty);
      await cubit.close();
    });
  });

  group('السيناريوهات', () {
    test('الفاضي المرتبط بالتأكيد والفاضي الحقيقي الاتنين فاضيين', () async {
      for (final scenario in <MockScenario>[
        MockScenario.entitlementsEmptyUnlinked,
        MockScenario.entitlementsEmptyGenuine,
      ]) {
        MockConfig.scenario = scenario;
        final cubit = buildCubit();
        await cubit.load();
        expect(cubit.hasAnything, isFalse, reason: scenario.name);
        await cubit.close();
      }
    });

    test('packageMultiplePurchases بيدّي بركة من تلاتة', () async {
      MockConfig.scenario = MockScenario.packageMultiplePurchases;
      final cubit = buildCubit();
      await cubit.load();

      final pool = cubit.packages.single as UsagePackageEntitlement;
      expect(pool.purchaseCount, 3);
      expect(pool.purchases.length, 3);
      // تواريخ انتهاء مختلفة — ده كل الغرض من الفكسشر.
      final expiries = pool.purchases.map((p) => p.expiresAt).toSet();
      expect(expiries.length, 3);
      await cubit.close();
    });
  });
}

/// الباقات بتنجح والمتابعات بتفشل — بتختبر حالة «جزئي».
class _HalfBrokenService extends EntitlementsMockService {
  const _HalfBrokenService();

  @override
  Future<Either<Failure, List<FollowUpEntitlementUiModel>>>
  followUps() async => const Left(ServerFailure(message: 'فشل'));
}

class _BrokenService extends EntitlementsMockService {
  const _BrokenService();

  @override
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages() async =>
      const Left(ServerFailure(message: 'فشل'));

  @override
  Future<Either<Failure, List<FollowUpEntitlementUiModel>>>
  followUps() async => const Left(ServerFailure(message: 'فشل'));
}
