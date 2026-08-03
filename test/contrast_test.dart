import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

/// **الأسطح الغامقة لازم تشيل نصها.**
///
/// الباج اللي الاختبارات دي بتمنع رجوعه: الشريط بيقلب من الحبر للأخضر
/// و**الألوان اللي فوقه تفضل زي ما هي**. `textOnInkMuted` معمول للحبر،
/// وعلى الأخضر كان بيدي **1.35:1** — يعني «متوقع تخلص 6:45 م» كانت
/// مرسومة ومش مقروءة.
///
/// و`accent` نفسه مكانش ينفع خلفية أصلاً: حتى **الأبيض الصافي** عليه
/// 3.96:1، أقل من الحد. فاللون اتغمق مش النص بس.
void main() {
  // الحد الأدنى لنص صغير في WCAG AA.
  const small = 4.5;

  // نص كبير (≥18pt أو ≥14pt عريض) — العنوان بتاع الشريط ٤٠sp.
  const large = 3.0;

  group('طقم الحبر', () {
    test('النص الأساسي فوق الحد', () {
      expect(
        _contrast(AppSemanticColors.textOnInk, AppSemanticColors.surfaceInk),
        greaterThan(small),
      );
    });

    test('النص الثانوي فوق الحد', () {
      expect(
        _contrast(
          AppSemanticColors.textOnInkMuted,
          AppSemanticColors.surfaceInk,
        ),
        greaterThan(small),
      );
    });
  });

  group('طقم الأخضر الغامق', () {
    test('النص الأساسي فوق الحد', () {
      expect(
        _contrast(
          AppSemanticColors.textOnAccent,
          AppSemanticColors.surfaceAccentDeep,
        ),
        greaterThan(small),
      );
    });

    test('النص الثانوي فوق الحد', () {
      expect(
        _contrast(
          AppSemanticColors.textOnAccentMuted,
          AppSemanticColors.surfaceAccentDeep,
        ),
        greaterThan(small),
      );
    });
  });

  group('الطقم الغلط بيسقط — ده اللي كان بيحصل', () {
    test('رمادي الحبر على الأخضر مابيعديش حتى للنص الكبير', () {
      expect(
        _contrast(
          AppSemanticColors.textOnInkMuted,
          AppSemanticColors.surfaceAccentDeep,
        ),
        lessThan(large),
      );
    });

    test('لهجة الزراير مابتنفعش خلفية شريط', () {
      // `accent` معمول عشان يقعد **على** صفحة فاتحة. لو رجع خلفية،
      // الأبيض عليه بيسقط تحت الحد — فالاختبار ده بيثبّت السبب.
      expect(
        _contrast(AppSemanticColors.textOnAccent, AppSemanticColors.accent),
        lessThan(small),
      );
    });
  });

  group('أحمر الخصم', () {
    test('مقروء على الكارت الأبيض', () {
      // الخصم بقى أحمر بقرار المالك. لو الأحمر مادّاش الحد بيبقى
      // «تحذير مش مقروء» — أوحش من الرمادي اللي كان قبله.
      //
      // بنختبر التوكن مش الـ `TextStyle`: `AppTextStyles` محتاج
      // `ScreenUtil` متهيّأ (بيحسب الـ sp من مقاس الشاشة)، والعقد اللي
      // بيتكسر لو حد غيّر اللون هو التوكن.
      expect(
        _contrast(AppSemanticColors.danger, AppSemanticColors.surfaceRaised),
        greaterThan(small),
      );
    });

    test('متميّز عن نص السعر العادي', () {
      // لو الاتنين قربوا من بعض، الشطب يبقى هو الإشارة الوحيدة —
      // والشطب لوحده بيضيع في صف فيه أرقام كتير.
      expect(AppSemanticColors.danger, isNot(AppSemanticColors.textPrimary));
      expect(AppSemanticColors.danger, isNot(AppSemanticColors.textSecondary));
    });
  });
}
