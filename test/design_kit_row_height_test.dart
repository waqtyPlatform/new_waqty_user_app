import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **عقد `heightOf`.**
///
/// القاعدة: **`heightOf` = ارتفاع الكارت كله بالحشوة.**
///
/// الباج اللي الاختبار ده موجود عشانه: الصف كان بيمرّر الرقم للصندوق
/// الداخلي **و** يزوّد حشوته فوقه، فكل كارت بيطلع أطول من اللي اتحسب له
/// بمقدار الحشوة × ٢، وكل skeleton بيطلع أقصر من صفه بنفس الرقم — يعني
/// **اللستة بتنطّ أول ما الداتا توصل**.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));

  /// بيرجّع المقيس والمحسوب — **الاتنين من نفس الـ context**.
  Future<({double rendered, double expected})> measure(
    WidgetTester tester, {
    required double textScale,
    required bool skeleton,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late double expected;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          home: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (innerContext) {
                  // ⚠ **جوه الـ Builder ده بالظبط.** لو الرقم اتحسب بره،
                  // بيتحسب من context مالوش نفس الـ textScaler فالمقارنة
                  // بتبقى بين حاجتين مختلفتين.
                  expected = AppMenuRowWidget.heightOf(innerContext).h;

                  return Scaffold(
                    body: skeleton
                        ? const AppSkeletonGroupWidget(
                            child: AppMenuRowSkeletonWidget(),
                          )
                        : AppMenuRowWidget(
                            title: 'بياناتي',
                            subtitle: 'الاسم والتليفون',
                            icon: Icons.person_outline_rounded,
                            onTap: () {},
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    // ⚠ **مش `pumpAndSettle`.** الشيمر بيلفّ للأبد فبيعلّق.
    await tester.pump(const Duration(milliseconds: 100));

    final rendered = tester.getSize(find.byType(AppSurfaceWidget).first).height;

    return (rendered: rendered, expected: expected);
  }

  group('AppMenuRowWidget', () {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      testWidgets('الصف الحقيقي = heightOf عند مقياس $scale', (tester) async {
        final result = await measure(tester, textScale: scale, skeleton: false);

        expect(
          result.rendered,
          closeTo(result.expected, 1),
          reason: 'الكارت اتبنى ${result.rendered} والمحسوب ${result.expected}',
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('الـ skeleton = heightOf عند مقياس $scale', (tester) async {
        final result = await measure(tester, textScale: scale, skeleton: true);
        expect(result.rendered, closeTo(result.expected, 1));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('الـ skeleton بنفس ارتفاع صفه بالظبط', (tester) async {
      final real = await measure(tester, textScale: 1.0, skeleton: false);
      final fake = await measure(tester, textScale: 1.0, skeleton: true);

      expect(
        fake.rendered,
        closeTo(real.rendered, 1),
        reason: 'اللستة هتنطّ لما الداتا توصل',
      );
    });

    testWidgets('الارتفاع بيكبر مع مقياس الخط — بس مش بالكامل', (tester) async {
      final normal = await measure(tester, textScale: 1.0, skeleton: false);
      final large = await measure(
        tester,
        textScale: AppSpacing.maxTextScale,
        skeleton: false,
      );

      expect(large.rendered, greaterThan(normal.rendered));
      // ⚠ الجزء الثابت (حشوة وأيقونة) **مابيتضاعفش**. لو الصندوق كله
      // اتضاعف، النسبة كانت هتبقى ١٫٣ بالظبط وكانت هتطلع بلاطة فاضية.
      expect(
        large.rendered / normal.rendered,
        lessThan(AppSpacing.maxTextScale),
      );
    });
  });

  group('باقي الـ heightOf', () {
    Future<double> heightIn(
      WidgetTester tester,
      double Function(BuildContext) fn, {
      double textScale = 1.0,
    }) async {
      late double value;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Builder(
              builder: (innerContext) {
                value = fn(innerContext);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return value;
    }

    testWidgets('الهيدر مابينزلش تحت ٤٨ ولا بيثبت عند ١٫٣', (tester) async {
      final normal = await heightIn(tester, AppScreenHeaderWidget.heightOf);
      final large = await heightIn(
        tester,
        AppScreenHeaderWidget.heightOf,
        textScale: AppSpacing.maxTextScale,
      );

      expect(normal, AppScreenHeaderWidget.height);
      expect(large, greaterThanOrEqualTo(normal));
    });

    testWidgets('الزرار ٥٠ عند ١٫٠ وبيكبر عند ١٫٣', (tester) async {
      final normal = await heightIn(tester, AppButtonWidget.heightOf);
      final large = await heightIn(
        tester,
        AppButtonWidget.heightOf,
        textScale: AppSpacing.maxTextScale,
      );

      expect(normal, closeTo(AppButtonWidget.height, 0.5));
      expect(large, greaterThan(normal));
      expect(large, lessThan(AppButtonWidget.height * AppSpacing.maxTextScale));
    });

    testWidgets('بلاطة الرقم بتكبر في الجزء النصي بس', (tester) async {
      final normal = await heightIn(tester, AppStatTileWidget.heightOf);
      final large = await heightIn(
        tester,
        AppStatTileWidget.heightOf,
        textScale: AppSpacing.maxTextScale,
      );

      expect(large, greaterThan(normal));
      expect(large / normal, lessThan(AppSpacing.maxTextScale));
    });
  });
}
