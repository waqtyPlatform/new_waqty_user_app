import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// سلّم الخطوط.
///
/// ## ليه مش سلّم الـ kit حرفيًا
///
/// الـ design DNA ماشي على Work Sans بـ body 15 و small 13 و caption 11.
/// الأرقام دي لاتينية: حروف العربي فيها نقط وتشكيل وارتفاع صاعد/نازل أكبر،
/// فـ ١٣ للنص الثانوي بتقرا مهروسة على شاشة موبايل. السلّم هنا بيحافظ على
/// **نسب** الـ kit (مدى ٤:١ من الأصغر للأكبر) بأرقام تنفع العربي.
///
/// ## قواعد العربي المتبنية هنا
///
/// **أتقل وزن `w600`.** مفيش ملف Bold في `pubspec.yaml` — بس `Regular 400`
/// و`Medium 500` و`SemiBold 600`. أي `w700` فلاتر بيولّده صناعيًا، وده بيلطّخ
/// وصلات الحروف العربية ويطمس التشكيل.
///
/// **التتبّع السالب عند ٢٠sp فأكتر بس.** تضييق المسافة بين الحروف في أحجام
/// النص العادي بيضر وصلات الحروف. في العناوين الكبيرة بيشدّ الكلمة وبيبان أنيق.
///
/// **التتبّع الموجب ممنوع نهائيًا.** فلاتر بيطبّق `letterSpacing` **بعد**
/// التشكيل، فالمسافة بتتحط جوه الحروف العربية المتصلة نفسها — «الأكثر طلبًا»
/// بـ +0.6 بتتفكّك. صيغة «اللابل الصغير المتتبّع» لاتينية ومالهاش مقابل عربي؛
/// اللي بيعمل نفس الشغل هو **الصغر + هبوط التباين + الوزن**.
///
/// **الـ leading تلات قيم:** ١٫٣٠ للعناوين، ١٫٥٠ للنص، ١٫٤٠ للبيانات الثانوية.
///
/// ## الألوان
///
/// كل ستايل بيقرا لونه من `AppSemanticColors` **وقت الاستدعاء** — عشان كده
/// كلهم `get` مش `static final`. لو كانوا متقيّمين مرة واحدة، الوضع الغامق كان
/// هيلاقي نص أسود على صفحة سودا.
class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'IBMPlexSansArabic';

  static TextStyle _s({
    required double size,
    required FontWeight weight,
    required double height,
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: _family,
    fontSize: size.sp,
    fontWeight: weight,
    height: height,
    letterSpacing: tracking,
    color: color ?? AppSemanticColors.textPrimary,
  );

  // ── العرض ────────────────────────────────────────────────────────────
  //
  // مدى الخط في الهوم كان **١١ → ٢٢٫٤** — نسبة ٢:١. يعني مفيش حاجة عالية
  // ومفيش حاجة واطية، وكل النص بيقرا بنفس الصوت. التصميم التحريري بيمشي
  // على ٤:١ فأكتر. الحجمين دول بيوسّعوا المدى لـ **١١ → ٤٠**.

  /// **رقم البؤرة** — رقم الدور، «تم الحجز»، الرقم الضخم في بانر العرض.
  /// حاجة واحدة في الشاشة بس.
  static TextStyle get displayXl =>
      _s(size: 40, weight: FontWeight.w600, height: 1.10, tracking: -1.0);

  /// لحظة فتح الشاشة — الترحيب.
  static TextStyle get displayLg =>
      _s(size: 32, weight: FontWeight.w600, height: 1.15, tracking: -0.8);

  /// الحرف البديل لما يبقى **هو التصميم** مش خطة بديلة.
  ///
  /// خارج السلّم عن قصد: مقاسه بيتحسب من الصندوق اللي جواه مش من درجة في
  /// سلّم.
  static TextStyle entityGlyph(double size, {FontWeight? weight, Color? color}) =>
      TextStyle(
        fontFamily: _family,
        fontSize: size.sp,
        fontWeight: weight ?? FontWeight.w600,
        height: 1,
        color: color ?? AppSemanticColors.textPrimary,
      );

  // ── العناوين ─────────────────────────────────────────────────────────

  /// عناوين شاشات الـ auth.
  static TextStyle get titleXl =>
      _s(size: 24, weight: FontWeight.w600, height: 1.30, tracking: -0.3);

  /// عنوان الشاشة جوه الجسم · الإجمالي · اسم المحل في صفحته.
  static TextStyle get titleLg =>
      _s(size: 20, weight: FontWeight.w600, height: 1.30, tracking: -0.2);

  /// **عناوين الـ AppBar والـ sheets.**
  ///
  /// ⚠ مربوط بـ `textTheme.titleMedium` **و**`appBarTheme.titleTextStyle` —
  /// أي تغيير في مقاسه بيغيّر كل عنوان AppBar في الأبلكيشن.
  ///
  /// **مش لعناوين الأقسام** — دي [sectionLabel].
  static TextStyle get sectionHeader =>
      _s(size: 18, weight: FontWeight.w600, height: 1.35, tracking: -0.2);

  /// **لابل القسم — صغير وهادي.**
  ///
  /// عكس الحدس: العنوان **بيصغر** عشان المحتوى يعلى. لما القسم كان ١٨/w600
  /// كان بنفس وزن الكارت اللي تحته بالظبط، فالصفحة كانت بتقرا عمود واحد
  /// مالوش هرمية. دلوقتي اللابل كروم، والكروت هي الصوت.
  static TextStyle get sectionLabel => _s(
    size: 12,
    weight: FontWeight.w600,
    height: 1.35,
    color: AppSemanticColors.textSecondary,
  );

  /// **عناوين الكروت — وبس.** ١٦ مقابل ١٨ للقسم: خطوة ٢sp بدل صفر.
  static TextStyle get cardTitle =>
      _s(size: 16, weight: FontWeight.w600, height: 1.40);

  // ── النص ─────────────────────────────────────────────────────────────

  /// نص حقول الإدخال.
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

  /// قيم الصفوف · أسماء الأيام.
  static TextStyle get bodyMdStrong =>
      _s(size: 14, weight: FontWeight.w500, height: 1.50);

  // ── اللابلات والبيانات ───────────────────────────────────────────────

  /// **لابل الحقل — فوق الحقل مش جوّاه.**
  ///
  /// من الـ DNA: `label positioned above the field`. الـ placeholder اللي
  /// بيقوم بدور اللابل بيختفي أول ما العميل يكتب، فمحدش بيفتكر الحقل ده كان
  /// بيطلب إيه — وده أوحش في فورم تسجيل من غير ما يبان إنه مشكلة.
  static TextStyle get fieldLabel => _s(
    size: 13,
    weight: FontWeight.w500,
    height: 1.40,
    color: AppSemanticColors.textSecondary,
  );

  /// الأزرار والروابط: «عرض الكل» · «تغيير» · «احجز».
  static TextStyle get label => _s(
    size: 14,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accent,
  );

  /// لابل على سطح اللمسة.
  static TextStyle get labelOnAccent => _s(
    size: 14,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.textOnAccent,
  );

  /// زرار أساسي.
  static TextStyle get button => _s(
    size: 16,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.textOnAccent,
  );

  static TextStyle get caption => _s(
    size: 12,
    weight: FontWeight.w400,
    height: 1.40,
    color: AppSemanticColors.textSecondary,
  );

  static TextStyle get captionStrong =>
      _s(size: 12, weight: FontWeight.w600, height: 1.40);

  /// **السعر القديم المشطوب** — «كان ٢٥٠ · بقى ٢٠٠».
  ///
  /// توكن مش `copyWith` متكرر: الشطب بقى في تفاصيل الحجز **وفي صف القايمة**،
  /// ولو كل واحد كتبه لنفسه أول تغيير هيمشي في مكان ويسيب التاني.
  ///
  /// **أحمر بقرار المالك.** الأحمر محجوز للخطر، فالخصم بيشارك اللون ده —
  /// تنازل مقصود: أحمر الأوفر عُرف راسخ في السوق المصري (جوميا ونون وأي
  /// فاترينة)، والشطب مع الأحمر بيقرا «أوفر» فورًا من غير لابل.
  ///
  /// التباين على الكارت **5.15:1** — فوق حد النص الصغير.
  static TextStyle get captionStruck => caption.copyWith(
    decoration: TextDecoration.lineThrough,
    decorationColor: AppSemanticColors.danger,
    color: AppSemanticColors.danger,
  );

  /// بيانات على السطر: المسافة · أقل سعر · عدد الخدمات.
  /// حبر غامق مش رمادي — دي المعلومة اللي بتفرّق محل عن محل، مش زينة.
  static TextStyle get captionInk =>
      _s(size: 12, weight: FontWeight.w400, height: 1.40);

  /// «أقرب موعد» — **اللمسة النصية الوحيدة المسموح بيها جوه كارت.**
  static TextStyle get captionAccent => _s(
    size: 12,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accent,
  );

  /// الشارات: «آخر موعد» · حالة الحجز · عدّاد التصنيف.
  ///
  /// التمييز بيجي من الوزن (w600) والحجم (١١) واللون — تلاتة كفاية، والتتبّع
  /// صفر عشان الشارات كلها عربية («مؤكد» · «بانتظار التأكيد» · «٢٤ خدمة»).
  static TextStyle get overline =>
      _s(size: 11, weight: FontWeight.w600, height: 1.30);
}
