import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_semantic_colors.dart';

/// سلّم الخط — **٢١ دور + دالة**.
///
/// employee-app عنده **٥٠ ستايل** مسمّيين `font14greyColor900Weight500`،
/// يعني **الاسم هو نفسه التعريف**. النتيجة إن المصفوفة (مقاس × لون × وزن)
/// بتنفجر، وتغيير السلّم معناه تعديل كل call site.
///
/// هنا الاسم بيقول **الدور**: `bodyMd` · `cardTitle` · `caption`. والمقاس
/// واللون والوزن تفاصيل تنفيذ.
///
/// ## سلّم المقاسات: 10 · 12 · 14 · 16 · 18 · 20 · 24 · 32
///
/// employee-app عنده كمان **15** و**26**. الـ15 ستايل واحد بس
/// (`font15greyColor3003Weight500`) و14 هو مقاس المتن المسيطر بـ٢٠+ ستايل
/// — فاتلم على 14. الـ26 ستايل واحد كمان و24 موجود بنفس الوزن والفرق ٨٪،
/// يعني **مش باين** — فاتلم على 24.
///
/// الـ**10 باقي** (٥ ستايلات) وهو **الأرضية**: مفيش أصغر منه في الكيت،
/// لأن العربي عند 10sp ضيّق أصلًا.
///
/// ## تلات قواعد مفروضة بـ `assert` مش بتعليق
///
/// 1. **أتقل وزن `w600`.** الكيت بيشحن ٣ ملفات خط بس (400/500/600).
/// 2. **`letterSpacing` موجب ممنوع تمامًا** — فلاتر بيطبّقه **بعد** تشكيل
///    العربي، فبيفكّك وصلات الحروف.
/// 3. **السالب مسموح عند 20sp فأكتر بس.** تحت كده الفرق بيبقى تشويش.
///
/// ## الـ leading — تلات قيم بس
///
/// **1.30 عناوين · 1.50 متن · 1.40 داتا.**
///
/// ⚠ employee-app **كل الـ٥٠ ستايل عنده `height: null`** (مقاييس الخط
/// نفسه، ~1.29). الكيت بيفرض leading، فـ**نص المتن بيطول قياسًا** — وده
/// أوضح تغيير طباعي في النقل. كل رقم `heightOf` في الكيت معاير على الـ
/// leading الجديد.
class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'IBMPlexSansArabic';

  static TextStyle _s({
    required double size,
    required FontWeight weight,
    required double height,
    double tracking = 0,
    Color? color,
  }) {
    assert(
      weight.value <= 600,
      'أتقل وزن مسموح w600 — الكيت مابيشحنش Bold، وفلاتر بيولّده صناعيًا '
      'وبيلطّخ وصلات الحروف العربية.',
    );
    assert(
      tracking <= 0,
      'letterSpacing موجب ممنوع — فلاتر بيطبّقه بعد تشكيل العربي فبيفكّك الكلمة.',
    );
    assert(
      tracking == 0 || size >= 20,
      'tracking سالب مسموح عند 20sp فأكتر بس — تحت كده بيبقى تشويش.',
    );

    return TextStyle(
      fontFamily: _family,
      fontSize: size.sp,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking,
      color: color ?? AppSemanticColors.textPrimary,
    );
  }

  // ── العرض ────────────────────────────────────────────────────────────

  /// أكبر مقاس في الكيت. رقم واحد في الشاشة، مش أكتر.
  static TextStyle get displayLg =>
      _s(size: 32, weight: FontWeight.w600, height: 1.15, tracking: -0.8);

  // ── العناوين ─────────────────────────────────────────────────────────

  static TextStyle get titleXl =>
      _s(size: 24, weight: FontWeight.w600, height: 1.30, tracking: -0.3);

  static TextStyle get titleLg =>
      _s(size: 20, weight: FontWeight.w600, height: 1.30, tracking: -0.2);

  /// عنوان الشاشة في الهيدر — الـ **٩ هيدرز** بتاعة employee-app كلهم بيه.
  ///
  /// ⚠ `tracking: 0` مش سهو: 18 تحت عتبة الـ20، والقاعدة فوق بتمنعه.
  static TextStyle get sectionHeader =>
      _s(size: 18, weight: FontWeight.w600, height: 1.35);

  static TextStyle get cardTitle =>
      _s(size: 16, weight: FontWeight.w600, height: 1.40);

  // ── المتن ────────────────────────────────────────────────────────────

  static TextStyle get bodyLg =>
      _s(size: 16, weight: FontWeight.w400, height: 1.50);

  static TextStyle get bodyLgMuted => _s(
    size: 16,
    weight: FontWeight.w400,
    height: 1.50,
    color: AppSemanticColors.textTertiary,
  );

  static TextStyle get bodyMd =>
      _s(size: 14, weight: FontWeight.w400, height: 1.50);

  static TextStyle get bodyMdMuted => _s(
    size: 14,
    weight: FontWeight.w400,
    height: 1.50,
    color: AppSemanticColors.textSecondary,
  );

  static TextStyle get bodyMdStrong =>
      _s(size: 14, weight: FontWeight.w500, height: 1.50);

  // ── اللابلات والداتا ─────────────────────────────────────────────────

  /// لابل فوق الحقل. **جديد** — employee-app مافيهوش لابل حقل أصلًا،
  /// الـ hint كان بيقوم بالدورين.
  static TextStyle get fieldLabel => _s(
    size: 14,
    weight: FontWeight.w500,
    height: 1.40,
    color: AppSemanticColors.textSecondary,
  );

  /// لابل بلون اللمسة — رابط، «شوف الكل»، قيمة مميّزة.
  static TextStyle get label => _s(
    size: 14,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accentText,
  );

  static TextStyle get labelStrong =>
      _s(size: 14, weight: FontWeight.w600, height: 1.40);

  static TextStyle get labelOnAccent => _s(
    size: 14,
    weight: FontWeight.w500,
    height: 1.40,
    color: AppSemanticColors.textOnAccent,
  );

  /// نص الزرار الأساسي.
  static TextStyle get button => _s(
    size: 16,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.textOnAccent,
  );

  // ── التسميات الصغيرة ─────────────────────────────────────────────────

  static TextStyle get caption => _s(
    size: 12,
    weight: FontWeight.w400,
    height: 1.40,
    color: AppSemanticColors.textSecondary,
  );

  static TextStyle get captionInk =>
      _s(size: 12, weight: FontWeight.w400, height: 1.40);

  static TextStyle get captionStrong =>
      _s(size: 12, weight: FontWeight.w600, height: 1.40);

  static TextStyle get captionAccent => _s(
    size: 12,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accentText,
  );

  static TextStyle get captionOnAccent => _s(
    size: 12,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.textOnAccent,
  );

  /// الأرضية — ١٠sp. مفيش أصغر منه.
  static TextStyle get overline => _s(
    size: 10,
    weight: FontWeight.w600,
    height: 1.30,
    color: AppSemanticColors.textSecondary,
  );

  // ── بره السلّم ───────────────────────────────────────────────────────

  /// أرقام الفلوس الكبيرة — **دالة مش توكن، بقصد**.
  ///
  /// الرقم اللي في نص كارت الأرباح مالوش «دور» في السلّم: مقاسه بيتحدد
  /// بالمساحة المتاحة مش بالهيراركي. الـ `height: 1.0` عشان الرقم يقعد
  /// على خط الأساس من غير هوا فوقه.
  ///
  /// [size] لازم يبقى من السلّم (20 · 24 · 32) عشان يفضل متناسق.
  static TextStyle numeric(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => _s(
    size: size,
    weight: weight,
    height: 1.0,
    tracking: size >= 20 ? -0.5 : 0,
    color: color,
  );
}
