import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/provider_packages_notice_widget.dart';

/// **التذكرة بالباقات في صفحة المزوّد.**
///
/// ## الحد اللي الاختبارات دي بتحرسه
///
/// التطبيق **مش عارف** الباقة من أنهي فرع: الرد مافيهوش `provider`
/// (BE-A1)، والمطابقة بالخدمة مش صالحة لأن `Service` عنده
/// `providers()` belongsToMany — «قص شعر» صف واحد مشترك بين صالونات.
///
/// فالتذكرة ممنوع تدّعي ملكية. ولو حد بكرة حوّلها لـ«باقاتك هنا» أو حط
/// عليها زرار حجز، الاختبارات دي بتقع — والسبب مكتوب فوق.
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

  testWidgets('صفر باقات = مفيش تذكرة خالص', (tester) async {
    await pump(tester, (_) => const ProviderPackagesNoticeWidget(activeCount: 0));
    expect(
      tester.getSize(find.byType(ProviderPackagesNoticeWidget)),
      Size.zero,
    );
  });

  testWidgets('مابتدّعيش إن الباقة من الفرع ده', (tester) async {
    await pump(
      tester,
      (_) => const ProviderPackagesNoticeWidget(activeCount: 2),
    );

    // ⚠ الشرط: النص بيقول «لو واحدة منها من الفرع ده» — احتمال مش خبر.
    expect(find.textContaining('لو واحدة منها من الفرع ده'), findsOneWidget);
    expect(find.textContaining('باقاتك هنا'), findsNothing);
    // ولا زرار حجز — الحجز هيروح لفرع الباقة مش الفرع المعروض.
    expect(find.textContaining('احجز'), findsNothing);
  });

  testWidgets('بيوجّه للفرع مش للتطبيق', (tester) async {
    await pump(
      tester,
      (_) => const ProviderPackagesNoticeWidget(activeCount: 1),
    );
    expect(find.textContaining('كلّم الفرع'), findsOneWidget);
  });

  group('العدد بالعربي', () {
    for (final entry in <int, String>{
      1: 'باقة شغّالة',
      2: 'باقتين شغّالين',
      3: '3 باقات شغّالة',
    }.entries) {
      testWidgets('${entry.key} → ${entry.value}', (tester) async {
        await pump(
          tester,
          (_) => ProviderPackagesNoticeWidget(activeCount: entry.key),
        );
        expect(find.textContaining(entry.value), findsOneWidget);
      });
    }
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
          (_) => const ProviderPackagesNoticeWidget(activeCount: 3),
          brightness: config.b,
          scale: config.s,
          size: config.z,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
