import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_package_offers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_mock_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_mock_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_packages_widget.dart';

/// **كتالوج باقات الفرع** — «باقات المكان» في صفحة المزوّد.
///
/// القسم ده بيتكلم عن **فلوس لسه ما اتدفعتش**، وده اللي بيحكم كل اللي
/// تحت: السعر لازم يبقى بتاع الفرع اللي العميلة واقفة فيه، والخصم لازم
/// يبان إنه مؤقت، والقسم لازم يختفي بالكامل لو المكان مابيبيعش باقات.
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });

  Future<void> pump(
    WidgetTester tester,
    WidgetBuilder build, {
    Brightness brightness = Brightness.light,
    double scale = 1.0,
    Size size = const Size(375, 812),
  }) async {
    AppSemanticColors.apply(brightness);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          locale: const Locale('ar', 'EG'),
          home: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SingleChildScrollView(child: Builder(builder: build)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('القسم', () {
    testWidgets('الفرع مابيبيعش باقات = مفيش قسم خالص', (tester) async {
      await pump(
        tester,
        (_) => const ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[],
        ),
      );

      expect(
        tester.getSize(find.byType(ServiceProviderDetailsPackagesWidget)),
        Size.zero,
      );
    });

    testWidgets('بيقول الاسم واللي جواها والسعر', (tester) async {
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[MockPackageOffers.captainHaircut],
          onOpen: (_) {},
        ),
      );

      expect(find.text('باقات المكان'), findsOneWidget);
      expect(find.text('باقة قص الشعر'), findsOneWidget);
      expect(find.text('8 جلسات'), findsOneWidget);
      expect(
        find.text(AppFormat.money(MockPackageOffers.captainHaircut.basePrice)),
        findsOneWidget,
      );
    });

    /// ⚠ **العدّادات ممنوعة هنا.** الكارت بتاع الاستحقاق بيقول «فاضل ٣
    /// جلسات»؛ الكتالوج بيقول «٨ جلسات» — الأول رصيد، والتاني اللي هتاخده
    /// لو دفعت. «فاضل» على حاجة محدش اشتراها كذبة.
    testWidgets('مابيقولش «فاضل»', (tester) async {
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[MockPackageOffers.captainHaircut],
          onOpen: (_) {},
        ),
      );

      expect(find.textContaining('فاضل'), findsNothing);
    });

    testWidgets('البركة بتتكلم بالوحدات مش بالجلسات', (tester) async {
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[MockPackageOffers.relaxMassagePool],
          onOpen: (_) {},
        ),
      );

      expect(find.text('300 دقيقة'), findsOneWidget);
      expect(find.textContaining('جلسات'), findsNothing);
    });

    testWidgets('الزيارة الواحدة مابتقولش «1 جلسة»', (tester) async {
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[MockPackageOffers.captainSingle],
          onOpen: (_) {},
        ),
      );

      expect(find.text('زيارة واحدة'), findsOneWidget);
    });
  });

  group('العرض', () {
    /// السعر الأقل من غير القديم المشطوب جنبه رقم مالوش مرجع — العميلة
    /// ماتعرفش إنها بتوفّر، والخصم اللي المزوّد دافع تكلفته بيروح هدر.
    testWidgets('السعر القديم بيتشطب لما يبقى فيه عرض', (tester) async {
      final offer = MockPackageOffers.captainGrooming;
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[offer],
          onOpen: (_) {},
        ),
      );

      expect(find.text(AppFormat.money(offer.effectivePrice)), findsOneWidget);
      expect(find.text(AppFormat.money(offer.basePrice)), findsOneWidget);
    });

    testWidgets('من غير عرض = رقم واحد بس', (tester) async {
      final plain = MockPackageOffers.captainHaircut;
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[plain],
          onOpen: (_) {},
        ),
      );

      // نفس الرقم بيتعرض مرة واحدة — مش مشطوب وجنبه نسخة تانية.
      expect(find.text(AppFormat.money(plain.effectivePrice)), findsOneWidget);
    });

    test('savings صفر لما مفيش عرض', () {
      expect(MockPackageOffers.captainHaircut.savings, 0);
      expect(MockPackageOffers.captainGrooming.savings, greaterThan(0));
    });

    test('العرض ليه آخر يوم', () {
      // خصم من غير تاريخ بيقرا سعر دايم.
      expect(MockPackageOffers.captainGrooming.offerEndsAt, isNotNull);
    });
  });

  group('الفلترة بالفرع', () {
    /// ⚠ **ده مش تفصيلة تنظيم.** `packages.branch_id` حقيقي على السيرفر:
    /// نفس الصالون بيبيع نفس الباقة بسعر تاني في فرع تاني. فلترة
    /// بالمزوّد كانت هتقول للي واقفة في المعادي سعر مدينة نصر.
    test('فرعين لنفس الصالون = كتالوجين بسعرين', () {
      final maadi = MockPackageOffers.ofBranch('brn-1');
      final nasrCity = MockPackageOffers.ofBranch('brn-2');

      final maadiHaircut = maadi.firstWhere((p) => p.name == 'باقة قص الشعر');
      final nasrHaircut = nasrCity.firstWhere((p) => p.name == 'باقة قص الشعر');

      expect(maadiHaircut.effectivePrice, isNot(nasrHaircut.effectivePrice));
      expect(maadi.any((p) => p.branchUuid == 'brn-2'), isFalse);
      expect(nasrCity.any((p) => p.branchUuid == 'brn-1'), isFalse);
    });

    test('باقات مزوّد تاني مابتدخلش', () {
      expect(
        MockPackageOffers.ofBranch(
          'brn-1',
        ).any((p) => p.providerUuid != 'prv-1'),
        isFalse,
      );
    });

    /// الـwidget بيرسم اللي يتبعتله — نفس قاعدة `ProviderPackagesNoticeWidget`.
    /// لو فلتر من عنده، كل مستهلك جديد لازم يفتكر يبعت الفرع الصح.
    testWidgets('الـwidget مابيفلترش', (tester) async {
      await pump(
        tester,
        (_) => ServiceProviderDetailsPackagesWidget(
          packages: <PackageOfferUiModel>[
            MockPackageOffers.captainHaircut,
            MockPackageOffers.relaxMassagePool,
          ],
          onOpen: (_) {},
        ),
      );

      expect(find.text('باقة قص الشعر'), findsOneWidget);
      expect(find.text('رصيد المساج'), findsOneWidget);
    });
  });

  group('الكيوبت', () {
    ServiceProviderDetailsCubit build() => ServiceProviderDetailsCubit(
      ServiceProviderDetailsRepo(
        const ServiceProviderDetailsMockService(),
        const ServiceProviderDetailsMockService(),
      ),
      EntitlementsRepo(
        const EntitlementsMockService(),
        const EntitlementsMockService(),
      ),
      providerUuid: 'prv-1',
    );

    test('بيحمّل كتالوج الفرع المختار', () async {
      final cubit = build();
      await cubit.loadDetails();

      expect(cubit.branchPackages, isNotEmpty);
      expect(
        cubit.branchPackages.every(
          (p) => p.branchUuid == cubit.selectedBranch!.uuid,
        ),
        isTrue,
      );

      await cubit.close();
    });

    /// **ده الباج اللي الاختبار ده موجود عشانه.**
    ///
    /// الكتالوج فرعي. لو `changeBranch` ما أعادش تحميله، اللي بدّلت
    /// لمدينة نصر بتفضل بتقرا سعر المعادي — نفس الباج بالظبط اللي حصل
    /// قبل كده في الأسعار والأخصائيين.
    test('تغيير الفرع بيعيد تحميل الكتالوج', () async {
      final cubit = build();
      await cubit.loadDetails();

      final before = cubit.branchPackages.map((p) => p.uuid).toList();
      expect(before, isNotEmpty);

      await cubit.changeBranch(cubit.branches[1]);

      expect(cubit.branchPackages.map((p) => p.uuid), isNot(before));
      expect(
        cubit.branchPackages.every(
          (p) => p.branchUuid == cubit.branches[1].uuid,
        ),
        isTrue,
      );

      await cubit.close();
    });

    test('سيناريو «الفرع مابيبيعش باقات» بيفضّي الكتالوج', () async {
      MockConfig.scenario = MockScenario.providerPackagesNone;
      final cubit = build();
      await cubit.loadDetails();

      expect(cubit.branchPackages, isEmpty);
      // والصفحة نفسها لسه شغّالة — القسم بيختفي وبس.
      expect(cubit.services, isNotEmpty);

      await cubit.close();
    });
  });

  group('الرسم عبر الحالات', () {
    for (final config in <({Brightness b, double s, Size z})>[
      (b: Brightness.light, s: 1.0, z: const Size(375, 812)),
      (b: Brightness.dark, s: 1.0, z: const Size(375, 812)),
      (b: Brightness.light, s: 1.3, z: const Size(360, 640)),
      (b: Brightness.dark, s: 1.3, z: const Size(360, 640)),
    ]) {
      testWidgets(
        '${config.b.name} · ${config.s} · ${config.z.width.toInt()}',
        (tester) async {
          await pump(
            tester,
            (_) => ServiceProviderDetailsPackagesWidget(
              packages: <PackageOfferUiModel>[
                MockPackageOffers.captainGrooming,
                MockPackageOffers.captainHaircut,
                MockPackageOffers.captainSingle,
                MockPackageOffers.relaxMassagePool,
              ],
              onOpen: (_) {},
            ),
            brightness: config.b,
            scale: config.s,
            size: config.z,
          );

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
