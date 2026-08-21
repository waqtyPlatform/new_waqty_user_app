import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_skeleton_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_empty_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/follow_up_card_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/follow_up_teaser_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_session_card_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_usage_card_widget.dart';

/// **الرسم عبر الحالات المتقاطعة (§9).**
///
/// كل كارت بيترسم في: **RTL · فاتح وغامق · مقياس خط ١٫٠ و١٫٣ · ٣٧٥×٨١٢
/// و٣٦٠×٦٤٠**. المصفوفة دي هي اللي بتمسك النوع اللي `flutter analyze`
/// مابيشوفوش خالص — فيضان تخطيط بيحصل وقت الرسم بس.
///
/// ⚠ **الغامق مش نسخة من الفاتح.** الكروت بتقرا `AppSemanticColors` اللي
/// بتقرا من الـpalette الحالي، وأي widget بيرسم لون واتكتب `const`
/// مابيتبنيش تاني لما الوضع يقلب. الاختبار ده بيمرّ على الوضعين بالفعل
/// عشان ده يبان.
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
    required Brightness brightness,
    required double textScale,
    required Size size,
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
            ).copyWith(textScaler: TextScaler.linear(textScale)),
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
    // ⚠ **`pump` مش `pumpAndSettle`.** الـskeleton فيه شيمر بيلف للأبد،
    // و`pumpAndSettle` بيستنى الأنيميشن يقف فبيعمل timeout. نبضتين كفاية
    // عشان التخطيط يستقر ويرمي أي فيضان.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// الحالات اللي بتكسر: أضيق شاشة، وأقصى مقياس خط، والوضعين.
  final matrix = <({Brightness brightness, double scale, Size size})>[
    (brightness: Brightness.light, scale: 1.0, size: const Size(375, 812)),
    (brightness: Brightness.dark, scale: 1.0, size: const Size(375, 812)),
    (brightness: Brightness.light, scale: 1.3, size: const Size(360, 640)),
    (brightness: Brightness.dark, scale: 1.3, size: const Size(360, 640)),
  ];

  final cards = <String, WidgetBuilder>{
    'باقة جلسات': (_) =>
        PackageSessionCardWidget(package: MockEntitlements.multiSession),
    'زيارة واحدة': (_) =>
        PackageSessionCardWidget(package: MockEntitlements.singleVisit),
    'باقة منتهية': (_) =>
        PackageSessionCardWidget(package: MockEntitlements.expired),
    'باقة تنتهي قريب': (_) =>
        PackageSessionCardWidget(package: MockEntitlements.expiringSoon),
    'بركة وحدات': (_) =>
        PackageUsageCardWidget(package: MockEntitlements.usageBased),
    'بركة من تلات شراءات': (_) => PackageUsageCardWidget(
      package: MockEntitlements.usageMultiplePurchases,
    ),
    'متابعة مجانية': (_) =>
        FollowUpCardWidget(followUp: MockEntitlements.followUpFree),
    'متابعة بخصم': (_) =>
        FollowUpCardWidget(followUp: MockEntitlements.followUpDiscounted),
    'متابعة أخصائيها مشي': (_) =>
        FollowUpCardWidget(followUp: MockEntitlements.followUpEmployeeLeft),
    'تنبيه متابعة': (_) => FollowUpTeaserWidget(
      followUp: MockEntitlements.followUpFree,
      onTap: () {},
    ),
    'تنبيه متابعة · الأخصائي مشي': (_) => FollowUpTeaserWidget(
      followUp: MockEntitlements.followUpEmployeeLeft,
    ),
    'التحميل': (_) => const EntitlementCardSkeletonWidget(),
    // ⚠ **`onVerify` مبعوت بالقصد.** `AppEmptyStateWidget` بيخفي الزرار
    // لما الـcallback يبقى `null` — فمن غيره المصفوفة كانت هترسم الحالة
    // من غير أهم عنصر فيها، والزرار ده بالظبط اللي ممكن يفيض عند ١٫٣.
    'فاضي · الرقم مش مأكّد': (_) => EntitlementEmptyWidget(
      tab: EntitlementTab.packages,
      needsVerification: true,
      onVerify: () {},
    ),
    'فاضي · مفيش باقات': (_) => const EntitlementEmptyWidget(
      tab: EntitlementTab.packages,
      needsVerification: false,
    ),
    'فاضي · مفيش متابعات': (_) => const EntitlementEmptyWidget(
      tab: EntitlementTab.followUps,
      needsVerification: false,
    ),
  };

  for (final entry in cards.entries) {
    group(entry.key, () {
      for (final config in matrix) {
        testWidgets(
          '${config.brightness.name} · ${config.scale} · '
          '${config.size.width.toInt()}',
          (tester) async {
            await pump(
              tester,
              entry.value,
              brightness: config.brightness,
              textScale: config.scale,
              size: config.size,
            );

            // الفيضان بيرمي استثناء وقت الرسم — مش بيرجع في مقاس.
            expect(tester.takeException(), isNull);
          },
        );
      }
    });
  }

  group('نصوص الفاضي مختلفة حسب السبب', () {
    testWidgets('الرقم مش مأكّد = دعوة للتأكيد', (tester) async {
      await pump(
        tester,
        (_) => EntitlementEmptyWidget(
          tab: EntitlementTab.packages,
          needsVerification: true,
          onVerify: () {},
        ),
        brightness: Brightness.light,
        textScale: 1.0,
        size: const Size(375, 812),
      );

      expect(find.text('أكّد رقمي'), findsOneWidget);
      expect(find.textContaining('لسه مافيش باقات'), findsNothing);
    });

    testWidgets('فاضي فعلاً = شرح من غير CTA شرا', (tester) async {
      await pump(
        tester,
        (_) => const EntitlementEmptyWidget(
          tab: EntitlementTab.packages,
          needsVerification: false,
        ),
        brightness: Brightness.light,
        textScale: 1.0,
        size: const Size(375, 812),
      );

      expect(find.text('لسه مافيش باقات'), findsOneWidget);
      expect(find.textContaining('بتتشتري من الفرع'), findsOneWidget);
      // ⚠ **عمرها ما تبقى «اشتري دلوقتي»** — مفيش catalogue ولا بوابة دفع.
      expect(find.textContaining('اشتري'), findsNothing);
      expect(find.text('أكّد رقمي'), findsNothing);
    });
  });
}
