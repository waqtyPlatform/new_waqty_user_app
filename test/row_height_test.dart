import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/config/themes/app_theme.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_skeleton_widget.dart';

/// **`heightOf` = ارتفاع الكارت كله، بالحشوة.**
///
/// العقد ده مكتوب في تعليقات كل صف (`_fixedPart` بيحسب حشوة الكارت جواه)،
/// و`ProviderRowSkeletonWidget` مبني عليه — بيرسم `SizedBox(heightOf)`
/// وبيحط حشوته جواه.
///
/// و`AppRowWidget` كان بيخالفه: بيدي الرقم للصندوق الداخلي **وبعدين**
/// يزوّد ٣٢ حشوة فوقه. النتيجة حاجتين:
///
///  • **كل كارت أطول ٣٢ نقطة من اللي اتحسب له** — فراغ ميت تحت كل صف.
///  • **الـ skeleton أقصر من صفه الحقيقي بـ ٣٢** — يعني اللستة بتنطّ لما
///    الداتا توصل، وده بالظبط اللي التعليقات كتبت إنها بتمنعه.
///
/// الاختبارين دول بيقفلوا الباب على رجوع الاتنين.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));

  /// بيرجّع ارتفاع الكارت المرسوم و`heightOf` المحسوب في نفس الـ context.
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
          theme: appTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (innerContext) {
                  expected = ProviderRowWidget.heightOf(innerContext).h;
                  return ListView(
                    children: [
                      if (skeleton)
                        const ProviderRowSkeletonWidget(showHairline: false)
                      else
                        ProviderRowWidget(
                          provider: MockProviders.all.first,
                          onTap: () {},
                          showHairline: false,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    // `pumpAndSettle` مابينفعش مع الـ skeleton — موجة الـ shimmer بتلفّ
    // للأبد فالـ settle عمره ما بيحصل.
    if (skeleton) {
      await tester.pump(const Duration(milliseconds: 100));
    } else {
      await tester.pumpAndSettle();
    }

    final rendered = tester
        .getSize(find.byType(AppSurfaceWidget).first)
        .height;

    return (rendered: rendered, expected: expected);
  }

  group('ارتفاع الكارت = heightOf', () {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      testWidgets('عند مقياس خط $scale', (tester) async {
        final r = await measure(tester, textScale: scale, skeleton: false);

        // هامش بكسل واحد لتقريب الرسم.
        expect(
          r.rendered,
          closeTo(r.expected, 1),
          reason: 'الكارت اترسم ${r.rendered} والمحسوب ${r.expected}',
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('الـ skeleton بنفس ارتفاع الصف الحقيقي', (tester) async {
    final real = await measure(tester, textScale: 1.0, skeleton: false);
    final fake = await measure(tester, textScale: 1.0, skeleton: true);

    expect(
      fake.rendered,
      closeTo(real.rendered, 1),
      reason: 'اللستة هتنطّ لما الداتا توصل',
    );
  });
}
