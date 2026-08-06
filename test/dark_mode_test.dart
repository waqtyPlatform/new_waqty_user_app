import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/config/themes/app_theme.dart';
import 'package:waqty_user_application/config/themes/theme_cubit.dart';
import 'package:waqty_user_application/core/utils/app_gradients.dart';
import 'package:waqty_user_application/core/utils/app_palette.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// نسبة التباين بين لونين — نفس معادلة WCAG 2.1.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// **الوضع الغامق.**
///
/// التوكنز كلها `static getters` بتقرا من palette عام، يعني الاختبارات هنا
/// بتلمس **حالة عامة**. كل اختبار بيرجّع الوضع الفاتح في `tearDown` عشان
/// الترتيب مايفرقش.
void main() {
  const small = 4.5;
  const large = 3.0;

  tearDown(() => AppSemanticColors.apply(Brightness.light));

  group('التبديل بيشتغل', () {
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

    test('الصفحة والحبر بيقلبوا فعلاً مش بيفضلوا زي ما هما', () {
      final lightPage = AppSemanticColors.page;
      final lightText = AppSemanticColors.textPrimary;

      AppSemanticColors.apply(Brightness.dark);

      expect(AppSemanticColors.page, isNot(lightPage));
      expect(AppSemanticColors.textPrimary, isNot(lightText));
      // الصفحة الغامقة لازم تبقى **أغمق** من الفاتحة، والنص أفتح.
      expect(
        _luminance(AppSemanticColors.page),
        lessThan(_luminance(lightPage)),
      );
      expect(
        _luminance(AppSemanticColors.textPrimary),
        greaterThan(_luminance(lightText)),
      );
    });
  });

  group('ترتيب الأسطح متحفظ عليه في الوضعين', () {
    /// الكارت لازم يقعد **فوق** الصفحة، والغاطس **تحتها** — الترتيب ده هو
    /// نظام العمق كله. لو اتقلب في الغامق، الكروت بتغطس والبحث بيطفو.
    void expectOrdering() {
      final page = _luminance(AppSemanticColors.page);
      final raised = _luminance(AppSemanticColors.surfaceRaised);
      final sunken = _luminance(AppSemanticColors.surfaceSunken);

      expect(raised, greaterThan(page), reason: 'الكارت لازم يبقى أفتح');
      expect(sunken, lessThan(page), reason: 'الغاطس لازم يبقى أغمق');
    }

    test('فاتح', expectOrdering);

    test('غامق', () {
      AppSemanticColors.apply(Brightness.dark);
      expectOrdering();
    });
  });

  group('النص على الصفحة الغامقة', () {
    setUp(() => AppSemanticColors.apply(Brightness.dark));

    test('الأساسي فوق الحد', () {
      expect(
        _contrast(AppSemanticColors.textPrimary, AppSemanticColors.page),
        greaterThan(small),
      );
    });

    test('الثانوي فوق الحد', () {
      expect(
        _contrast(AppSemanticColors.textSecondary, AppSemanticColors.page),
        greaterThan(small),
      );
    });

    /// الثالثي هو أضعف لون نص في السلّم — لو عدّى، اللي فوقه عدّى.
    test('الثالثي فوق الحد', () {
      expect(
        _contrast(AppSemanticColors.textTertiary, AppSemanticColors.page),
        greaterThan(small),
      );
    });

    test('الثانوي على السطح الغاطس فوق الحد', () {
      expect(
        _contrast(
          AppSemanticColors.textOnSunken,
          AppSemanticColors.surfaceSunken,
        ),
        greaterThan(small),
      );
    });
  });

  group('اللمسة بتفتح في الغامق — ومعاها النص اللي عليها بينقلب', () {
    /// `#009354` على صفحة `#121110` بيدي 4.76:1 — عدّى بالعافية. الغامق
    /// بياخد `#00CC77` (8.9:1)، والاختبار ده بيثبّت إن الفرق ده موجود.
    test('اللمسة الغامقة أوضح على صفحتها من الفاتحة', () {
      final lightRatio = _contrast(
        AppSemanticColors.accent,
        AppSemanticColors.page,
      );

      AppSemanticColors.apply(Brightness.dark);

      final darkRatio = _contrast(
        AppSemanticColors.accent,
        AppSemanticColors.page,
      );

      expect(darkRatio, greaterThan(small));
      expect(darkRatio, greaterThan(lightRatio));
    });

    /// **ده أهم اختبار في الملف.**
    ///
    /// لو `textOnAccent` فضل أبيض في الغامق، نص الزرار الأساسي كان هيبقى
    /// أبيض على `#00CC77` = **2.12:1**. الاختبار بيقيس الزرار كوحدة: النص
    /// على ملء اللمسة.
    test('نص الزرار الأساسي مقروء على ملء اللمسة في الغامق', () {
      AppSemanticColors.apply(Brightness.dark);
      expect(
        _contrast(AppSemanticColors.textOnAccent, AppSemanticColors.accent),
        greaterThan(small),
      );
    });

    test('الأبيض على اللمسة الغامقة كان هيسقط — ده اللي التوكن بيمنعه', () {
      AppSemanticColors.apply(Brightness.dark);
      expect(
        _contrast(const Color(0xffFFFFFF), AppSemanticColors.accent),
        lessThan(large),
      );
    });
  });

  group('السطح الأخضر الغامق — نفس اللون في الوضعين', () {
    test('اللون ما اتغيّرش', () {
      final light = AppSemanticColors.surfaceAccentDeep;
      AppSemanticColors.apply(Brightness.dark);
      expect(AppSemanticColors.surfaceAccentDeep, light);
    });

    test('نصه الأساسي مقروء في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          _contrast(
            AppSemanticColors.textOnAccentDeep,
            AppSemanticColors.surfaceAccentDeep,
          ),
          greaterThan(small),
          reason: 'وقع في $brightness',
        );
      }
    });

    test('نصه الثانوي مقروء في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          _contrast(
            AppSemanticColors.textOnAccentMuted,
            AppSemanticColors.surfaceAccentDeep,
          ),
          greaterThan(small),
          reason: 'وقع في $brightness',
        );
      }
    });

    /// **الباج اللي `textOnAccentDeep` اتعمل عشانه.**
    ///
    /// `textOnAccent` بينقلب لحبر غامق في الوضع الغامق، وعلى الأخضر الغامق
    /// بيدي 2.52:1 — يعني شريط «الكرسي جاهز» كان هيختفي بالليل. لو حد رجّع
    /// `textOnAccent` مكانه، الاختبار ده هو اللي هيمسكه.
    test('`textOnAccent` على السطح الأخضر بيسقط في الغامق', () {
      AppSemanticColors.apply(Brightness.dark);
      expect(
        _contrast(
          AppSemanticColors.textOnAccent,
          AppSemanticColors.surfaceAccentDeep,
        ),
        lessThan(large),
      );
    });
  });

  group('الأسطح المقلوبة والحالات', () {
    test('نص الـ snackbar مقروء في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          _contrast(
            AppSemanticColors.textOnInverse,
            AppSemanticColors.surfaceInverse,
          ),
          greaterThan(small),
          reason: 'وقع في $brightness',
        );
      }
    });

    test('ألوان الحالات مقروءة على أسطحها الخفيفة في الوضعين', () {
      final pairs = <String, (Color, Color) Function()>{
        'danger': () =>
            (AppSemanticColors.danger, AppSemanticColors.dangerSoft),
        'warning': () =>
            (AppSemanticColors.warning, AppSemanticColors.warningSoft),
        'positive': () =>
            (AppSemanticColors.positive, AppSemanticColors.positiveSoft),
        'info': () => (AppSemanticColors.info, AppSemanticColors.infoSoft),
      };

      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        for (final entry in pairs.entries) {
          final (ink, surface) = entry.value();
          expect(
            _contrast(ink, surface),
            greaterThan(small),
            reason: '${entry.key} وقع في $brightness',
          );
        }
      }
    });

    /// **مفيش نسبة تباين هنا عن قصد.**
    ///
    /// الدهبي على أبيض لمعانه قريب منه (1.72:1) — بس ده مش القياس الصح
    /// للنجمة: الفرق بين «مقيّمة» و«مش مقيّمة» بيتقال بـ**تلات إشارات** —
    /// الشكل (`star_rounded` مقابل `star_outline_rounded`)، والملء، واللون.
    /// نسبة اللمعان لوحدها بتقيس واحدة منهم وبتسقط اللي عليها الشغل.
    ///
    /// اللي بيتقاس هنا هو العقد اللي ممكن يتكسر بالغلط: **النجمة توكن
    /// مستقل**. لو حد وحّدها مع [AppSemanticColors.warning] بكرة، أول
    /// تغيير في لون التحذير هياخد النجمة معاه.
    test('نجمة التقييم توكن مستقل في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        expect(
          AppSemanticColors.rating,
          isNot(AppSemanticColors.warning),
          reason: 'اتوحّدت مع التحذير في $brightness',
        );
        expect(
          AppSemanticColors.rating,
          isNot(AppSemanticColors.borderStrong),
          reason: 'النجمة المليانة زي الفاضية في $brightness',
        );
      }
    });

    test('هوية الكيان بتنقلب مع الوضع والتباين بيفضل عالي', () {
      // نفس عدد التدرّجات في الوضعين — الفهرس محسوب من الاسم، فلو العدد
      // اختلف نفس المحل كان هياخد لون تاني بالليل.
      expect(
        AppPalette.light.entityGrounds.length,
        AppPalette.dark.entityGrounds.length,
      );

      for (var i = 0; i < AppPalette.light.entityGrounds.length; i++) {
        for (final palette in [AppPalette.light, AppPalette.dark]) {
          expect(
            _contrast(palette.entityInks[i], palette.entityGrounds[i]),
            greaterThan(small),
            reason: 'التدرّج $i وقع في ${palette.brightness}',
          );
        }

        // الفاتح لمعانه عالي والغامق واطي — يعني فعلاً اتقلبوا.
        expect(
          _luminance(AppPalette.dark.entityGrounds[i]),
          lessThan(_luminance(AppPalette.light.entityGrounds[i])),
        );
      }
    });
  });

  /// **الغسلات بتغيّر لون السطح تحت النص.**
  ///
  /// كل الحساب اللي فوق بيقيس النص على **لون واحد**. أول ما اتحط تدرّج على
  /// لوح البؤرة، السطح بقى مدى ألوان — والنص بيتقرا على المدى كله مش على
  /// نقطة البداية. فالقياس بيتعمل على **كل نقطة توقّف في التدرّج**.
  ///
  /// ده اللي بيخلي زيادة `_lift` في `AppGradients` حاجة الاختبار بيرد
  /// عليها، مش حاجة حد يكتشفها بعينه بالليل.
  group('غسلات AppGradients', () {
    /// كل ألوان التدرّج — نقطة الضوء ولون السطح.
    List<Color> stopsOf(Gradient gradient) => gradient.colors;

    test('نص لوح الحبر مقروء على الغسلة كلها في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);

        for (final stop in stopsOf(AppGradients.ink)) {
          expect(
            _contrast(AppSemanticColors.textOnInk, stop),
            greaterThan(small),
            reason: 'النص الأساسي وقع على $stop في $brightness',
          );
          expect(
            _contrast(AppSemanticColors.textOnInkMuted, stop),
            greaterThan(small),
            reason: 'النص الثانوي وقع على $stop في $brightness',
          );
        }
      }
    });

    /// ⚠ الشريط الأخضر هامشه فوق AA **٠٫٢٤ بس** على النص الثانوي، فغسلته
    /// معمولة تغمق مش تفتح. الاختبار ده بيثبّت الاتجاه: أي نقطة في التدرّج
    /// لازم تبقى **أغمق أو زي** السطح الأساسي.
    test('غسلة الشريط الأخضر بتغمق مش بتفتح', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final base = _luminance(AppSemanticColors.surfaceAccentDeep);

        for (final stop in stopsOf(AppGradients.accentDeep)) {
          expect(
            _luminance(stop),
            lessThanOrEqualTo(base + 0.0001),
            reason: 'الغسلة فتّحت الشريط عند $stop في $brightness',
          );
          expect(
            _contrast(AppSemanticColors.textOnAccentMuted, stop),
            greaterThan(small),
            reason: 'النص الثانوي وقع على $stop في $brightness',
          );
        }
      }
    });

    /// الطبق شايل أيقونة مش نص — والأيقونة رسمة، فحدها ٣:١ مش ٤٫٥.
    test('أيقونة التصنيف بتبان على الطبق في الوضعين', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);

        for (final gradient in [AppGradients.plate, AppGradients.plateSelected]) {
          for (final stop in stopsOf(gradient)) {
            expect(
              _contrast(AppSemanticColors.accent, stop),
              greaterThan(large),
              reason: 'الأيقونة وقعت على $stop في $brightness',
            );
          }
        }
      }
    });

    /// الهالة بتقعد **ورا** المحتوى وبتنتهي عند شفافية صفر — لو حد رفع
    /// الشفافية دي بقت طبقة لون فوق الصفحة وبتاكل من تباين النص عليها.
    test('هالة الصفحة بتخلص شفافة', () {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final stops = stopsOf(AppGradients.pageGlow);

        expect(stops.last.a, 0, reason: 'مابتخلصش شفافة في $brightness');
        expect(
          stops.first.a,
          lessThan(0.15),
          reason: 'الهالة بقت طبقة لون في $brightness',
        );
      }
    });
  });

  /// `appTheme()` بيقرا `AppTextStyles`، واللي بيحسب الـ `sp` من `ScreenUtil`
  /// — فلازم يتهيّأ الأول. عشان كده الاختبارات دي `testWidgets` مش `test`.
  group('الثيم بيتبني من الـ palette الشغّال', () {
    Future<ThemeData> buildTheme(WidgetTester tester) async {
      late ThemeData theme;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) {
            theme = appTheme();
            return const SizedBox.shrink();
          },
        ),
      );
      return theme;
    }

    testWidgets('إضاءة الثيم بتطابق التوكنز', (tester) async {
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

    /// أول ما `primary` يبقى أخضر، الـ `surfaceTint` بياخده تلقائيًا وكل
    /// سطح مرفوع بياخد مسحة خضرا — الـ AppBar وقت السكرول والـ sheets.
    testWidgets('surfaceTint شفاف في الوضعين', (tester) async {
      for (final brightness in Brightness.values) {
        AppSemanticColors.apply(brightness);
        final theme = await buildTheme(tester);
        expect(theme.colorScheme.surfaceTint, Colors.transparent);
      }
    });
  });

  group('ThemeCubit.resolve', () {
    test('الاختيار اليدوي بيكسب على الجهاز', () {
      expect(
        ThemeCubit.resolve(ThemeMode.light, Brightness.dark),
        Brightness.light,
      );
      expect(
        ThemeCubit.resolve(ThemeMode.dark, Brightness.light),
        Brightness.dark,
      );
    });

    test('«حسب الجهاز» بيتبع الجهاز', () {
      expect(
        ThemeCubit.resolve(ThemeMode.system, Brightness.dark),
        Brightness.dark,
      );
      expect(
        ThemeCubit.resolve(ThemeMode.system, Brightness.light),
        Brightness.light,
      );
    });

    test('لكل وضع اسم عربي وأيقونة', () {
      for (final mode in ThemeMode.values) {
        expect(ThemeCubit.labelOf(mode), isNotEmpty);
        expect(ThemeCubit.iconOf(mode), isNotNull);
      }
    });
  });
}
