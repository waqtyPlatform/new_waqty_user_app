import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

import 'wcag.dart';

/// **الوضع الغامق.**
///
/// التوكنز كلها `static getters` بتقرا من palette عام، يعني الاختبارات هنا
/// بتلمس **حالة عامة**. الـ `tearDown` بيرجّع الفاتح بعد كل اختبار عشان
/// الترتيب مايفرقش — من غيره اختبار بينسى يرجّع بيكسّر اللي بعده.
void main() {
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  group('١ · التبديل بيشتغل', () {
    test('الافتراضي فاتح', () {
      expect(AppSemanticColors.isDark, isFalse);
      expect(AppSemanticColors.palette, same(AppPalette.light));
    });

    test('apply بيقلب الـ palette', () {
      AppSemanticColors.apply(Brightness.dark);
      expect(AppSemanticColors.isDark, isTrue);
      expect(AppSemanticColors.palette, same(AppPalette.dark));
    });

    test('apply بيرجّع false لو الوضع ما اتغيّرش', () {
      expect(AppSemanticColors.apply(Brightness.light), isFalse);
      expect(AppSemanticColors.apply(Brightness.dark), isTrue);
      expect(AppSemanticColors.apply(Brightness.dark), isFalse);
    });

    test('الصفحة بتغمق والنص بيفتح — مش بس بيتغيّروا', () {
      final lightPage = AppSemanticColors.page;
      final lightText = AppSemanticColors.textPrimary;

      AppSemanticColors.apply(Brightness.dark);

      expect(luminance(AppSemanticColors.page), lessThan(luminance(lightPage)));
      expect(
        luminance(AppSemanticColors.textPrimary),
        greaterThan(luminance(lightText)),
      );
    });
  });

  group('٢ · ترتيب الأسطح متحفظ عليه في الوضعين', () {
    /// الكارت لازم يقعد **فوق** الصفحة والغاطس **تحتها** — الترتيب ده هو
    /// نظام العمق كله. لو اتقلب في الغامق، الكروت بتغطس والبحث بيطفو.
    void expectOrdering() {
      final page = luminance(AppSemanticColors.page);
      final raised = luminance(AppSemanticColors.surfaceRaised);
      final sunken = luminance(AppSemanticColors.surfaceSunken);

      expect(raised, greaterThan(page), reason: 'الكارت لازم يبقى أفتح');
      expect(sunken, lessThan(page), reason: 'الغاطس لازم يبقى أغمق');
    }

    test('فاتح', expectOrdering);

    test('غامق', () {
      AppSemanticColors.apply(Brightness.dark);
      expectOrdering();
    });

    test('الحبر بينقلب: أغمق حاجة في الفاتح، أفتح حاجة في الغامق', () {
      // لوح أسود على صفحة سودا مش بؤرة، هو اختفاء.
      expect(
        luminance(AppSemanticColors.surfaceInk),
        lessThan(luminance(AppSemanticColors.surfaceSunken)),
        reason: 'في الفاتح الحبر لازم يبقى أغمق حاجة',
      );

      AppSemanticColors.apply(Brightness.dark);

      expect(
        luminance(AppSemanticColors.surfaceInk),
        greaterThan(luminance(AppSemanticColors.surfaceRaised)),
        reason: 'في الغامق الحبر لازم يبقى أفتح من الكارت',
      );
    });
  });

  group('٣ · النص على الصفحة الغامقة', () {
    setUp(() => AppSemanticColors.apply(Brightness.dark));

    test('الأساسي والثانوي بيعدّوا على الصفحة والكارت', () {
      for (final surface in <String, Color>{
        'page': AppSemanticColors.page,
        'surfaceRaised': AppSemanticColors.surfaceRaised,
      }.entries) {
        expect(
          contrast(AppSemanticColors.textPrimary, surface.value),
          greaterThan(kAaSmall),
          reason: 'الأساسي وقع على ${surface.key}',
        );
        expect(
          contrast(AppSemanticColors.textSecondary, surface.value),
          greaterThan(kAaSmall),
          reason: 'الثانوي وقع على ${surface.key}',
        );
      }
    });

    test('textOnSunken بيعدّي على الغاطس', () {
      expect(
        contrast(
          AppSemanticColors.textOnSunken,
          AppSemanticColors.surfaceSunken,
        ),
        greaterThan(kAaSmall),
      );
    });
  });

  group('٤ · اللمسة بتفتح — ونصّها بينقلب', () {
    test('الأخضر الغامق تباينه على الصفحة أعلى من الفاتح', () {
      final lightRatio = contrast(
        AppSemanticColors.accent,
        AppSemanticColors.page,
      );

      AppSemanticColors.apply(Brightness.dark);
      final darkRatio = contrast(
        AppSemanticColors.accent,
        AppSemanticColors.page,
      );

      expect(darkRatio, greaterThan(kAaLarge));
      expect(darkRatio, greaterThan(lightRatio));
    });

    test('النص على اللمسة بيعدّي عتبة الرسومات في الوضعين', () {
      // ⚠ **عتبة الرسومات مش عتبة النص، وده مقصود.**
      //
      // `accent` مسموح يشيل أيقونة أو شكل كبير، **مش نص متن**. في الفاتح
      // الأبيض عليه **3.96:1** — عدّى 3.0 ورسب 4.5. أي تعبئة خضرا تحتها
      // نص بتاخد `accentDeep` (المجموعة ٥ بتقيسها بـ 4.5).
      //
      // الاختبار ده بيمنع حاجتين: إن اللمسة تغمق لدرجة إن الأيقونة عليها
      // تختفي، وإن حد يفتكر إن الرقم ده سهو.
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          contrast(AppSemanticColors.textOnAccent, AppSemanticColors.accent),
          greaterThan(kAaLarge),
          reason: 'الرسم على اللمسة اختفى في $brightness',
        );
      }

      // وفي الغامق بس، اللمسة بتفتح كفاية إن نصّها يعدّي AA كامل.
      AppSemanticColors.apply(Brightness.dark);
      expect(
        contrast(AppSemanticColors.textOnAccent, AppSemanticColors.accent),
        greaterThan(kAaSmall),
      );
    });

    test('الأبيض على اللمسة الغامقة راسب — ده سبب انقلاب التوكن', () {
      AppSemanticColors.apply(Brightness.dark);
      expect(
        contrast(const Color(0xffFFFFFF), AppSemanticColors.accent),
        lessThan(kAaLarge),
        reason: 'لو ده عدّى، textOnAccent مش محتاج ينقلب',
      );
    });
  });

  group('٥ · السطح الأخضر الغامق — نفس اللون في الوضعين', () {
    test('accentDeep مابيتغيّرش حرفيًا', () {
      final lightDeep = AppSemanticColors.surfaceAccentDeep;
      AppSemanticColors.apply(Brightness.dark);
      expect(AppSemanticColors.surfaceAccentDeep, lightDeep);
    });

    test('نصّه بيعدّي في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          contrast(
            AppSemanticColors.textOnAccentDeep,
            AppSemanticColors.surfaceAccentDeep,
          ),
          greaterThan(kAaSmall),
          reason: 'النص الأساسي على الأخضر الغامق وقع في $brightness',
        );
        expect(
          contrast(
            AppSemanticColors.textOnAccentMuted,
            AppSemanticColors.surfaceAccentDeep,
          ),
          greaterThan(kAaSmall),
          reason: 'النص الثانوي على الأخضر الغامق وقع في $brightness',
        );
      }
    });

    test(
      'textOnAccent على الأخضر الغامق بيرسب — الباج اللي التوكن اتعمل عشانه',
      () {
        AppSemanticColors.apply(Brightness.dark);
        expect(
          contrast(
            AppSemanticColors.textOnAccent,
            AppSemanticColors.surfaceAccentDeep,
          ),
          lessThan(kAaSmall),
          reason: 'لو ده عدّى، textOnAccentDeep مالوش لازمة',
        );
      },
    );
  });

  group('٦ · الأسطح المقلوبة والحالات', () {
    test('نص الـ snackbar بيعدّي في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          contrast(
            AppSemanticColors.textOnInverse,
            AppSemanticColors.surfaceInverse,
          ),
          greaterThan(kAaSmall),
          reason: 'المقلوب وقع في $brightness',
        );
      }
    });

    test('كل زوج حالة/soft بيعدّي في الوضعين', () {
      // thunks مش قيم — لازم يتقروا **بعد** apply مش قبله.
      final pairs = <String, (Color, Color) Function()>{
        'dangerOnSoft': () =>
            (AppSemanticColors.dangerOnSoft, AppSemanticColors.dangerSoft),
        'warning': () =>
            (AppSemanticColors.warning, AppSemanticColors.warningSoft),
        'positive': () =>
            (AppSemanticColors.positive, AppSemanticColors.positiveSoft),
        'info': () => (AppSemanticColors.info, AppSemanticColors.infoSoft),
        'danger على الكارت': () =>
            (AppSemanticColors.danger, AppSemanticColors.surfaceRaised),
      };

      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final entry in pairs.entries) {
          final (fg, bg) = entry.value();
          expect(
            contrast(fg, bg),
            greaterThan(kAaSmall),
            reason: '${entry.key} وقع في $brightness',
          );
        }
      }
    });

    test('نص زرار الحذف بينقلب — والأبيض راسب في الغامق', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          contrast(AppSemanticColors.textOnDanger, AppSemanticColors.danger),
          greaterThan(kAaSmall),
          reason: 'نص زرار الحذف وقع في $brightness',
        );
      }

      // النفي اللي بيثبّت سبب وجود التوكن.
      AppSemanticColors.apply(Brightness.dark);
      expect(
        contrast(const Color(0xffFFFFFF), AppSemanticColors.danger),
        lessThan(kAaLarge),
        reason: 'لو ده عدّى، textOnDanger مش محتاج ينقلب',
      );
    });

    test('accentText بيعدّي على كل سطح في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final surface in <String, Color>{
          'page': AppSemanticColors.page,
          'surfaceRaised': AppSemanticColors.surfaceRaised,
          'surfaceSunken': AppSemanticColors.surfaceSunken,
          'accentSoft': AppSemanticColors.surfaceAccentSoft,
        }.entries) {
          expect(
            contrast(AppSemanticColors.accentText, surface.value),
            greaterThan(kAaSmall),
            reason: 'accentText وقع على ${surface.key} في $brightness',
          );
        }
      }
    });

    test('الحدود باينة على الكارت في الوضعين', () {
      // ⚠ ده الاختبار اللي WCAG مابيغطيهوش وهو اللي بيفشل في صمت.
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          contrast(AppSemanticColors.border, AppSemanticColors.surfaceRaised),
          greaterThan(kBorderVisible),
          reason: 'الحد اختفى على الكارت في $brightness',
        );
        expect(
          contrast(
            AppSemanticColors.borderStrong,
            AppSemanticColors.surfaceRaised,
          ),
          greaterThan(1.5),
          reason: 'الحد القوي اختفى على الكارت في $brightness',
        );
      }
    });

    test('نجمة التقييم توكن مستقل — اختبار من غير تباين', () {
      // الإضاءة مقياس غلط لنجمة. الحاجة اللي بتتكسر فعلًا إن حد يلمّ
      // rating على warning عشان الاتنين «أصفر».
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          AppSemanticColors.rating,
          isNot(AppSemanticColors.warning),
          reason: 'التقييم بقى بنّي في $brightness',
        );
        expect(AppSemanticColors.rating, isNot(AppSemanticColors.borderStrong));
      }
    });

    test('الـ skeleton لطيف — الوميض مش ستروب', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          luminance(AppSemanticColors.skeletonHighlight),
          greaterThan(luminance(AppSemanticColors.skeletonBase)),
          reason: 'الموجة لازم تبقى أفتح من الأرضية في $brightness',
        );
        expect(
          contrast(
            AppSemanticColors.skeletonHighlight,
            AppSemanticColors.skeletonBase,
          ),
          lessThan(1.5),
          reason: 'الفرق كبير أوي — ده بيقرا ستروب في $brightness',
        );
      }
    });

    test('ألوان الكيانات بتعدّي في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final grounds = AppSemanticColors.palette.entityGrounds;
        final inks = AppSemanticColors.palette.entityInks;

        expect(grounds.length, inks.length);
        expect(grounds.length, AppPalette.light.entityGrounds.length);

        for (var i = 0; i < grounds.length; i++) {
          expect(
            contrast(inks[i], grounds[i]),
            greaterThan(kAaSmall),
            reason: 'الكيان $i وقع في $brightness',
          );
        }
      }
    });

    test('أرضيات الكيانات بتنقلب فعلًا — مش نفس اللون في الوضعين', () {
      final lightGrounds = AppPalette.light.entityGrounds;
      final darkGrounds = AppPalette.dark.entityGrounds;

      for (var i = 0; i < lightGrounds.length; i++) {
        expect(
          luminance(darkGrounds[i]),
          lessThan(luminance(lightGrounds[i])),
          reason: 'أرضية الكيان $i ما غمقتش في الوضع الغامق',
        );
      }
    });
  });

  group('٧ · الغسلات — التباين بيتقاس عند كل نقطة توقّف', () {
    // ⚠ **مش على لون السطح.** الغسلة بتغيّر اللون تحت النص، فقياس التباين
    // على اللون الأساسي بيقيس حاجة مش موجودة على الشاشة. أي غسلة على سطح
    // شايل نص لازم كل نقطة توقّف فيها تتقاس لوحدها.
    List<Color> stopsOf(Gradient g) => g.colors;

    test('لوح الحبر — النص عليه بيعدّي عند كل نقطة في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final stop in stopsOf(AppGradients.ink)) {
          expect(
            contrast(AppSemanticColors.textOnInk, stop),
            greaterThan(kAaSmall),
            reason: 'النص الأساسي على نقطة $stop في $brightness',
          );
          expect(
            contrast(AppSemanticColors.textOnInkMuted, stop),
            greaterThan(kAaSmall),
            reason: 'النص الثانوي على نقطة $stop في $brightness',
          );
        }
      }
    });

    test('الشريط الأخضر — النص عليه بيعدّي عند كل نقطة في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final stop in stopsOf(AppGradients.brandBand)) {
          expect(
            contrast(AppSemanticColors.textOnAccentDeep, stop),
            greaterThan(kAaSmall),
            reason: 'الأساسي على نقطة $stop في $brightness',
          );
          expect(
            contrast(AppSemanticColors.textOnAccentMuted, stop),
            greaterThan(kAaSmall),
            reason: 'الثانوي على نقطة $stop في $brightness',
          );
        }
      }
    });

    test('الشريط الأخضر بيفتّح مش بيغمّق — اتجاه الغسلة مقصود', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final stops = stopsOf(AppGradients.brandBand);
        final base = luminance(AppSemanticColors.surfaceAccentDeep);
        for (final stop in stops) {
          expect(
            luminance(stop),
            greaterThanOrEqualTo(base - 0.0001),
            reason: 'الغسلة غمّقت في $brightness — ده مصدر ضوء مش ظل',
          );
        }
      }
    });

    test('اللوح الغاطس — النص عليه بيعدّي عند كل نقطة', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final stop in stopsOf(AppGradients.plate)) {
          expect(
            contrast(AppSemanticColors.textOnSunken, stop),
            greaterThan(kAaSmall),
            reason: 'الغاطس: نقطة $stop في $brightness',
          );
        }
        for (final stop in stopsOf(AppGradients.plateSelected)) {
          expect(
            contrast(AppSemanticColors.textPrimary, stop),
            greaterThan(kAaSmall),
            reason: 'المختار: نقطة $stop في $brightness',
          );
        }
      }
    });

    test('وهج الصفحة بينتهي شفاف تمامًا', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final stops = stopsOf(AppGradients.pageGlow);
        expect(
          stops.last.a,
          0,
          reason: 'آخر نقطة مش شفافة — هيبان للوهج حافة في $brightness',
        );
        expect(stops.first.a, lessThan(0.15));
      }
    });
  });

  group('٨ · الثيم بيتبني من الـ palette الشغّال', () {
    // ⚠ `testWidgets` مش `test`: `AppTextStyles` بيستخدم `.sp` فمحتاج
    // `ScreenUtil` تكون اتهيّأت، و`appTheme()` بيقرا الـ textTheme.
    Future<ThemeData> buildTheme(WidgetTester tester) async {
      late ThemeData built;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) {
            built = appTheme();
            return const SizedBox.shrink();
          },
        ),
      );
      return built;
    }

    testWidgets('إضاءة الثيم = إضاءة التوكنز في الوضعين', (tester) async {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final theme = await buildTheme(tester);

        expect(theme.brightness, brightness);
        expect(theme.colorScheme.brightness, brightness);
        expect(theme.scaffoldBackgroundColor, AppSemanticColors.page);
        expect(theme.colorScheme.primary, AppSemanticColors.accent);
        expect(theme.colorScheme.onPrimary, AppSemanticColors.textOnAccent);
      }
    });

    testWidgets('surfaceTint شفاف — فخ M3 مقفول', (tester) async {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final theme = await buildTheme(tester);
        expect(theme.colorScheme.surfaceTint.a, 0);
        expect(theme.appBarTheme.surfaceTintColor?.a, 0);
      }
    });

    testWidgets('الزرار الأساسي بيتعبّي بالأخضر الغامق مش باللمسة', (
      tester,
    ) async {
      // قرار D6 بيتقفل هنا: لو حد رجّع `accent` مكان `accentDeep`،
      // نص الزرار بيرجع 3.96:1.
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final theme = await buildTheme(tester);
        final style = theme.elevatedButtonTheme.style!;
        final bg = style.backgroundColor!.resolve({})!;
        final fg = style.foregroundColor!.resolve({})!;

        expect(bg, AppSemanticColors.surfaceAccentDeep);
        expect(
          contrast(fg, bg),
          greaterThan(kAaSmall),
          reason: 'نص الزرار الأساسي وقع في $brightness',
        );
      }
    });

    testWidgets('كل الخط بيعدّي على IBMPlexSansArabic — مفيش DMSans', (
      tester,
    ) async {
      final theme = await buildTheme(tester);
      final styles = <String, TextStyle?>{
        'bodyLarge': theme.textTheme.bodyLarge,
        'bodyMedium': theme.textTheme.bodyMedium,
        'titleMedium': theme.textTheme.titleMedium,
        'labelLarge': theme.textTheme.labelLarge,
        'hintStyle': theme.inputDecorationTheme.hintStyle,
        'labelStyle': theme.inputDecorationTheme.labelStyle,
      };

      expect(theme.textTheme.bodyLarge, isNotNull);
      for (final entry in styles.entries) {
        expect(
          entry.value?.fontFamily,
          'IBMPlexSansArabic',
          reason: '${entry.key} خرج بره الخط',
        );
      }
    });
  });
}
