import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// حسبة التباين المشتركة بين كل اختبارات اللون.
///
/// user-app ناسخ الدالتين دول **حرفيًا في ملفين** (`dark_mode_test.dart`
/// و`contrast_test.dart`). الكيت بيشيلهم مرة واحدة — لو المعادلة اتغيّرت،
/// بتتغيّر في مكان واحد.

/// عتبة WCAG AA للنص العادي.
const double kAaSmall = 4.5;

/// عتبة WCAG AA للنص الكبير (≥18pt عادي أو ≥14pt عريض) وللرسومات.
const double kAaLarge = 3.0;

/// أقل فرق إضاءة بين حد شعري والسطح اللي بيترسم عليه.
///
/// ⚠ **دي مش عتبة WCAG** — WCAG 1.4.11 بيطلب ٣:١ لحدود المكوّنات اللي
/// **لازمة** عشان تعرف المكوّن، والحد الشعري هنا زخرفي (الظل هو اللي
/// بيفصل الكارت). ١٫٣ هي أرضية «الحد باين إنه موجود».
///
/// السبب إنها موجودة أصلًا: **الحدود بتختفي في الوضع الغامق** وبتفشل في
/// صمت — لا الـ analyzer ولا اختبارات الرسم بيمسكوها.
const double kBorderVisible = 1.3;

/// نسبة التباين بين لونين — معادلة WCAG 2.1.
double contrast(Color a, Color b) {
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// الإضاءة النسبية — WCAG 2.1.
double luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}
