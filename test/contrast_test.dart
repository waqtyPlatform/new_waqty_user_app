import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

import 'wcag.dart';

/// **التباين في الوضع الفاتح.**
///
/// الملف ده `test` عادي مش `testWidgets` عن قصد: بيختبر **التوكن** مش
/// الـ`TextStyle`. `AppTextStyles` محتاج `ScreenUtil` تكون اتهيّأت عشان
/// `.sp`، والعقد اللي بينكسر فعلًا هو قيمة التوكن مش الستايل اللي بيلفّها.
///
/// الوضع الغامق في `dark_mode_test.dart`.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));

  group('طقم الحبر — النص على الأسطح الفاتحة', () {
    test('النص الأساسي', () {
      expect(
        contrast(AppSemanticColors.textPrimary, AppSemanticColors.page),
        greaterThan(kAaSmall),
      );
      expect(
        contrast(
          AppSemanticColors.textPrimary,
          AppSemanticColors.surfaceRaised,
        ),
        greaterThan(kAaSmall),
      );
    });

    test('النص الثانوي بيعدّي على التلات أسطح', () {
      for (final surface in <String, Color>{
        'page': AppSemanticColors.page,
        'surfaceRaised': AppSemanticColors.surfaceRaised,
        'surfaceSunken': AppSemanticColors.surfaceSunken,
      }.entries) {
        expect(
          contrast(AppSemanticColors.textSecondary, surface.value),
          greaterThan(kAaSmall),
          reason: 'النص الثانوي وقع على ${surface.key}',
        );
      }
    });

    test('النص على الحبر وعلى المقلوب', () {
      expect(
        contrast(AppSemanticColors.textOnInk, AppSemanticColors.surfaceInk),
        greaterThan(kAaSmall),
      );
      expect(
        contrast(
          AppSemanticColors.textOnInkMuted,
          AppSemanticColors.surfaceInk,
        ),
        greaterThan(kAaSmall),
      );
      expect(
        contrast(
          AppSemanticColors.textOnInverse,
          AppSemanticColors.surfaceInverse,
        ),
        greaterThan(kAaSmall),
      );
    });
  });

  group('السطح الأخضر الغامق', () {
    test('النص الأساسي والثانوي عليه بيعدّوا', () {
      expect(
        contrast(
          AppSemanticColors.textOnAccentDeep,
          AppSemanticColors.surfaceAccentDeep,
        ),
        greaterThan(kAaSmall),
        reason: 'أبيض على #00693C',
      );
      expect(
        contrast(
          AppSemanticColors.textOnAccentMuted,
          AppSemanticColors.surfaceAccentDeep,
        ),
        greaterThan(kAaSmall),
      );
    });
  });

  group('الطقم الغلط بيرسب — ده اللي بيحصل في employee-app دلوقتي', () {
    // النفيات دي مش زيادة. كل واحدة فيهم **بتثبّت سبب وجود توكن**؛
    // من غيرها حد يقدر يشيل التوكن ويعدّي كل الاختبارات الإيجابية.

    test('أبيض على اللمسة الخضرا راسب — عشان كده accentDeep موجود', () {
      // زرار employee-app الأساسي: أبيض على #009354، ١٦٥ استخدام.
      expect(
        contrast(const Color(0xffFFFFFF), AppSemanticColors.accent),
        lessThan(kAaSmall),
        reason: 'لو ده بقى بيعدّي، accentDeep مالوش لازمة',
      );
      // بس بيعدّي عتبة الرسومات — الأيقونة الخضرا مش مشكلة، النص هو المشكلة.
      expect(
        contrast(const Color(0xffFFFFFF), AppSemanticColors.accent),
        greaterThan(kAaLarge),
      );
    });

    test('الأحمر على خلفيته الوردية راسب — عشان كده dangerOnSoft موجود', () {
      expect(
        contrast(AppSemanticColors.danger, AppSemanticColors.dangerSoft),
        lessThan(kAaSmall),
      );
      expect(
        contrast(AppSemanticColors.dangerOnSoft, AppSemanticColors.dangerSoft),
        greaterThan(kAaSmall),
      );
    });

    test('الأخضر كنص راسب — عشان كده accentText موجود', () {
      // الرابط و«شوف الكل» والزرار الثانوي.
      expect(
        contrast(AppSemanticColors.accent, AppSemanticColors.page),
        lessThan(kAaSmall),
        reason: 'لو ده بقى بيعدّي، accentText مالوش لازمة',
      );
      expect(
        contrast(AppSemanticColors.accentText, AppSemanticColors.page),
        greaterThan(kAaSmall),
      );
      expect(
        contrast(AppSemanticColors.accentText, AppSemanticColors.surfaceRaised),
        greaterThan(kAaSmall),
      );
    });

    test('textTertiary مش نص — راسب على الصفحة بقصد', () {
      expect(
        contrast(AppSemanticColors.textTertiary, AppSemanticColors.page),
        lessThan(kAaSmall),
        reason: 'لو بقى بيعدّي، الاسم بقى بيكدب — ده لون معطّل',
      );
    });

    test('ألوان employee-app اللي اتشالت كانت راسبة فعلًا', () {
      const white = Color(0xffFFFFFF);
      // greyColorA3 — كان النص الثانوي في ~٣٠ ستايل.
      expect(contrast(const Color(0xffA3A3A3), white), lessThan(kAaSmall));
      // greyColor4002 — التاني.
      expect(contrast(const Color(0xff818898), white), lessThan(kAaSmall));
      // warningColor1001 — كان بيتكتب كنص.
      expect(contrast(const Color(0xffEAB308), white), lessThan(kAaLarge));
      // واللي حلّهم بيعدّي.
      expect(
        contrast(AppSemanticColors.textSecondary, white),
        greaterThan(kAaSmall),
      );
      expect(contrast(AppSemanticColors.warning, white), greaterThan(kAaSmall));
    });
  });

  group('الحالات على خلفياتها الخفيفة', () {
    test('كل زوج حالة/soft بيعدّي', () {
      final pairs = <String, (Color, Color)>{
        'dangerOnSoft': (
          AppSemanticColors.dangerOnSoft,
          AppSemanticColors.dangerSoft,
        ),
        'warning': (AppSemanticColors.warning, AppSemanticColors.warningSoft),
        'positive': (
          AppSemanticColors.positive,
          AppSemanticColors.positiveSoft,
        ),
        'info': (AppSemanticColors.info, AppSemanticColors.infoSoft),
      };

      for (final entry in pairs.entries) {
        expect(
          contrast(entry.value.$1, entry.value.$2),
          greaterThan(kAaSmall),
          reason: '${entry.key} وقع على خلفيته',
        );
      }
    });
  });

  group('الحد باين', () {
    // الحد بيترسم على الكارت مش على الصفحة — الكارت بينفصل عن الصفحة
    // بالظل. فالقياس على الكارت.
    test('border و borderStrong باينين على الكارت', () {
      expect(
        contrast(AppSemanticColors.border, AppSemanticColors.surfaceRaised),
        greaterThan(kBorderVisible),
      );
      expect(
        contrast(
          AppSemanticColors.borderStrong,
          AppSemanticColors.surfaceRaised,
        ),
        greaterThan(1.5),
      );
    });

    test('borderStrong أقوى من border فعلًا', () {
      expect(
        contrast(
          AppSemanticColors.borderStrong,
          AppSemanticColors.surfaceRaised,
        ),
        greaterThan(
          contrast(AppSemanticColors.border, AppSemanticColors.surfaceRaised),
        ),
      );
    });
  });
}
