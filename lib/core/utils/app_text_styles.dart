import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// سلّم الخطوط.
///
/// قبل كده: ٣١ ستايل، ٦ أحجام بس ٨٥٪ من النص كان بيترسم في ١٢/١٤/١٦،
/// و**ستايل واحد (`font16greyColor900Weight600`) كان بيخدم عنوان القسم
/// وعنوان الكارت في ٢٤ موضع** — فالهرمية كانت مفلطحة تمامًا.
/// و`letterSpacing` مكانش متحطّ ولا مرة في الـ ٣١.
///
/// ## قواعد العربي المتبنية هنا
///
/// **التتبّع السالب عند ٢٠sp فأكتر بس.** تضييق المسافة بين الحروف في أحجام
/// النص العادي بيضر وصلات الحروف العربية. في العناوين الكبيرة بيشدّ الكلمة
/// وبيبان أنيق.
///
/// **الـ leading اتقسّم لتلاتة بدل ١٫٦ المسطّحة.** ١٫٣٠ للعناوين، ١٫٥٠ للنص،
/// ١٫٤٠ للبيانات الثانوية. الـ ١٫٦ على ١٢sp هي بالذات اللي كانت مخلّية الكروت
/// تبان مفكّكة وهي في الحقيقة متضايقة.
class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'IBMPlexSansArabic';

  static TextStyle _s({
    required double size,
    required FontWeight weight,
    required double height,
    double tracking = 0,
    Color color = AppSemanticColors.textPrimary,
  }) => TextStyle(
    fontFamily: _family,
    fontSize: size.sp,
    fontWeight: weight,
    height: height,
    letterSpacing: tracking,
    color: color,
  );

  // ── العرض ────────────────────────────────────────────────────────────
  //
  // مدى الخط في الهوم كان **١١ → ٢٢٫٤** — نسبة ٢:١. يعني مفيش حاجة عالية
  // ومفيش حاجة واطية، وكل النص بيقرا بنفس الصوت. التصميم التحريري بيمشي
  // على ٤:١ فأكتر. الحجمين دول بيوسّعوا المدى لـ **١١ → ٤٠**.

  /// **رقم البؤرة** — رقم الدور، «تم الحجز». حاجة واحدة في الشاشة بس.
  static TextStyle get displayXl =>
      _s(size: 40, weight: FontWeight.w700, height: 1.10, tracking: -1.0);

  /// لحظة فتح الشاشة — الترحيب.
  static TextStyle get displayLg =>
      _s(size: 32, weight: FontWeight.w700, height: 1.15, tracking: -0.8);

  /// الحرف البديل لما يبقى **هو التصميم** مش خطة بديلة.
  ///
  /// خارج السلّم عن قصد: مقاسه بيتحسب من الصندوق اللي جواه مش من درجة
  /// في سلّم. قبل كده كان `TextStyle` خام متكتوب جوه الـ widget بأربع
  /// قيم درجية (٤٨/٣٢/٢٤/١٨) — وأكبرها كان **أضخم حرف في الأبلكيشن كله**
  /// من غير ما يكون قرار.
  static TextStyle entityGlyph(double size, {FontWeight? weight}) => TextStyle(
    fontFamily: _family,
    fontSize: size.sp,
    fontWeight: weight ?? FontWeight.w700,
    height: 1,
    color: AppSemanticColors.textPrimary,
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
  /// **مبقاش لعناوين الأقسام** — دي بقت [sectionLabel].
  static TextStyle get sectionHeader =>
      _s(size: 18, weight: FontWeight.w600, height: 1.35, tracking: -0.2);

  /// **لابل القسم — صغير وهادي.**
  ///
  /// عكس الحدس: العنوان **بيصغر** عشان المحتوى يعلى. لما القسم كان ١٨/w600
  /// كان بنفس وزن الكارت اللي تحته بالظبط، فالصفحة كانت بتقرا عمود واحد
  /// مالوش هرمية. دلوقتي اللابل كروم، والكروت هي الصوت.
  ///
  /// **التتبّع صفر مش موجب.** فلاتر بيطبّق `letterSpacing` **بعد** التشكيل،
  /// فالمسافة بتتحط جوه الحروف العربية المتصلة نفسها — «الأكثر طلبًا» بـ
  /// +0.6 بتتفكّك. صيغة «اللابل الصغير المتتبّع» لاتينية ومالهاش مقابل
  /// عربي؛ اللي بيعمل نفس الشغل هنا هو الصغر + هبوط التباين + خط شعري قصير.
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

  /// النص الرمادي في حقول الإدخال (كان `font16greyColor4002Weight500`،
  /// واللي اسمه كان بيقول ٥٠٠ وهو بيحط ٤٠٠).
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

  /// الأزرار والروابط: «عرض الكل» · «تغيير» · «احجز».
  static TextStyle get label => _s(
    size: 14,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accent,
  );

  /// لابل على سطح غامق.
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
  /// توكن مش `copyWith` متكرر: الشطب بقى في تفاصيل الحجز **وفي صف
  /// القايمة**، ولو كل واحد كتبه لنفسه أول تغيير هيمشي في مكان ويسيب
  /// التاني. والشطب علامة معنى (ده رقم مابقاش صح) مش تزويقة، فمكانه
  /// السلّم مش موضع الاستعمال.
  ///
  /// **أحمر بقرار المالك.** الأحمر في الأبلكيشن كان محجوز للخطر (زرار
  /// «إلغاء الحجز»)، فالخصم دلوقتي بيشارك اللون ده. ده تنازل مقصود —
  /// أحمر الأوفر عُرف راسخ في السوق المصري (جوميا ونون وأي فاترينة)،
  /// والشطب مع الأحمر بيقرا «أوفر» فورًا من غير لابل ولا شرح.
  ///
  /// التباين على الكارت الأبيض **4.79:1** — فوق حد النص الصغير.
  static TextStyle get captionStruck => caption.copyWith(
    decoration: TextDecoration.lineThrough,
    decorationColor: AppSemanticColors.danger,
    color: AppSemanticColors.danger,
  );

  /// بيانات على السطر: المسافة · أقل سعر · عدد الخدمات.
  /// حبر غامق مش رمادي — دي المعلومة اللي بتفرّق محل عن محل، مش زينة.
  static TextStyle get captionInk =>
      _s(size: 12, weight: FontWeight.w400, height: 1.40);

  /// «أقرب موعد» — **الأخضر النصي الوحيد المسموح بيه جوه كارت.**
  static TextStyle get captionAccent => _s(
    size: 12,
    weight: FontWeight.w600,
    height: 1.40,
    color: AppSemanticColors.accent,
  );

  /// الشارات: «آخر موعد» · حالة الحجز · عدّاد التصنيف.
  ///
  /// **التتبّع صفر.** كان +0.4 بمبرر «النص صغير وحروفه قريبة» — وده تبرير
  /// لاتيني. فلاتر بيطبّق الـ `letterSpacing` **بعد** التشكيل، فالمسافة
  /// بتتحط جوه الحروف العربية المتصلة نفسها. كل الشارات في الأبلكيشن
  /// عربية («مؤكد» · «بانتظار التأكيد» · «٢٤ خدمة»)، يعني القاعدة كانت
  /// بتتكسر في كل استخدام ليها.
  ///
  /// التمييز بيجي من الوزن (w600) والحجم (١١) واللون — تلاتة كفاية.
  static TextStyle get overline =>
      _s(size: 11, weight: FontWeight.w600, height: 1.30);
}
