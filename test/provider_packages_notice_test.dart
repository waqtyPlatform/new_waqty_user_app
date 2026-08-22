import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/provider_packages_notice_widget.dart';

/// **«باقاتك هنا» في صفحة المزوّد.**
///
/// ## اللي اتقلب مع BE-A1
///
/// أول نسخة من الملف ده كانت بتحرس العكس: النص **ممنوع** يدّعي إن الباقة
/// من الفرع ده، و**ممنوع** يبقى فيه زرار حجز. مكانش تحفّظ — كان الحد
/// الحقيقي: الرد مكانش فيه `provider`، والمطابقة بالخدمة مش صالحة لأن
/// `Service` مشترك بين مزوّدين، والتخمين كان هيحجز في صالون تاني بصمت.
///
/// دلوقتي كل صف بيقول مزوّده، فالادّعاء بقى حقيقة والزرار بيشتغل.
///
/// اللي الملف بيحرسه دلوقتي: **الفلترة مسؤولية اللي بينده** — الـwidget
/// بيرسم اللي يتبعتله ومابيفلترش من عنده. لو حد نسي الفلترة، باقة صالون
/// تاني هتظهر هنا بزرار حجز يروح لفرع تاني.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

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
              child: Scaffold(body: Builder(builder: build)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('مفيش باقات = مفيش قسم خالص', (tester) async {
    await pump(
      tester,
      (_) => const ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[],
      ),
    );
    expect(
      tester.getSize(find.byType(ProviderPackagesNoticeWidget)),
      Size.zero,
    );
  });

  testWidgets('بيقول «باقاتك هنا» وبيدّي زرار حجز', (tester) async {
    await pump(
      tester,
      (_) => ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[MockEntitlements.multiSession],
        onBook: (_) {},
      ),
    );

    expect(find.text('باقاتك هنا'), findsOneWidget);
    expect(find.text('باقة قص الشعر'), findsOneWidget);
    expect(find.textContaining('فاضل 3 جلسات'), findsOneWidget);
    expect(find.text('احجز'), findsOneWidget);
  });

  testWidgets('من غير onBook = مفيش زرار، والقسم لسه بيعرض', (tester) async {
    await pump(
      tester,
      (_) => ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[MockEntitlements.multiSession],
      ),
    );

    expect(find.text('باقاتك هنا'), findsOneWidget);
    expect(find.text('احجز'), findsNothing);
  });

  testWidgets('البركة بتتكلم بالوحدات مش بالجلسات', (tester) async {
    await pump(
      tester,
      (_) => ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[MockEntitlements.usageBased],
        onBook: (_) {},
      ),
    );

    expect(find.textContaining('فاضل 120 دقيقة'), findsOneWidget);
    expect(find.textContaining('جلسات'), findsNothing);
  });

  testWidgets('الزيارة الواحدة مابتقولش «فاضل 1 جلسات»', (tester) async {
    await pump(
      tester,
      (_) => ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[MockEntitlements.singleVisit],
        onBook: (_) {},
      ),
    );

    expect(find.text('زيارة واحدة'), findsOneWidget);
  });

  /// ⚠ الـwidget **مابيفلترش** — الفلترة على المزوّد بتحصل في
  /// `ServiceProviderDetailsCubit`.
  testWidgets('بيرسم اللي يتبعتله — الفلترة مش شغله', (tester) async {
    await pump(
      tester,
      (_) => ProviderPackagesNoticeWidget(
        packages: <PackageEntitlementUiModel>[
          MockEntitlements.multiSession,
          MockEntitlements.usageBased,
        ],
        onBook: (_) {},
      ),
    );

    expect(find.text('احجز'), findsNWidgets(2));
  });

  test('الفكسشرز بتاعت الباقات ليها مزوّدين مختلفين', () {
    // من غير كده اختبار الفلترة في صفحة المزوّد مالوش معنى.
    expect(
      MockEntitlements.multiSession.owner.providerUuid,
      isNot(equals(MockEntitlements.usageBased.owner.providerUuid)),
    );
  });

  group('الرسم عبر الحالات', () {
    for (final config in <({Brightness b, double s, Size z})>[
      (b: Brightness.light, s: 1.0, z: const Size(375, 812)),
      (b: Brightness.dark, s: 1.0, z: const Size(375, 812)),
      (b: Brightness.light, s: 1.3, z: const Size(360, 640)),
      (b: Brightness.dark, s: 1.3, z: const Size(360, 640)),
    ]) {
      testWidgets('${config.b.name} · ${config.s} · ${config.z.width.toInt()}', (
        tester,
      ) async {
        await pump(
          tester,
          (_) => ProviderPackagesNoticeWidget(
            packages: <PackageEntitlementUiModel>[
              MockEntitlements.multiSession,
              MockEntitlements.usageBased,
            ],
            onOpen: () {},
            onBook: (_) {},
          ),
          brightness: config.b,
          scale: config.s,
          size: config.z,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
