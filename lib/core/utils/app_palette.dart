import 'package:flutter/widgets.dart';

/// السلّم الخام — **نسختين، فاتحة وغامقة**.
///
/// ده الملف **الوحيد** في الأبلكيشن اللي فيه `Color(0x…)`. أي widget بيقرا لون
/// بيقراه من `AppSemanticColors` مش من هنا.
///
/// ## ليه كلاس بنسختين مش ThemeExtension
///
/// الـ `ThemeExtension` محتاج `context` عند كل استدعاء، والأبلكيشن فيه **٥٥١
/// مرجع لون** مكتوبين `AppSemanticColors.x` من غير context — منهم عشرات جوه
/// `static` getters ودوال مالهاش شجرة أصلاً (`AppTextStyles`, `AppShadows`).
///
/// الطريقة دي بتخلي الوضع الغامق يشتغل في **كل** موضع من غير ما أي widget
/// يتلمس، والـ brightness بتتظبط مرة واحدة في `my_app.dart` **قبل** ما الشجرة
/// تتبني — فالقيم مضمون إنها صح وقت الرسم.
@immutable
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.page,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceInk,
    required this.surfaceInverse,
    required this.accent,
    required this.accentPressed,
    required this.accentSoft,
    required this.accentDeep,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnAccent,
    required this.textOnInk,
    required this.textOnInkMuted,
    required this.textOnAccentDeep,
    required this.textOnAccentMuted,
    required this.textOnInverse,
    required this.danger,
    required this.dangerSoft,
    required this.dangerBorder,
    required this.warning,
    required this.warningSoft,
    required this.positive,
    required this.positiveSoft,
    required this.info,
    required this.infoSoft,
    required this.rating,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.scrimBase,
    required this.shadowInk,
    required this.shadowScale,
    required this.entityGrounds,
    required this.entityGroundsDeep,
    required this.entityInks,
  });

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  // ── الأسطح ─────────────────────────────────────────────────────────────

  /// الصفحة نفسها — اللي كل حاجة قاعدة فوقه.
  final Color page;

  /// المحتوى المرفوع: كارت · sheet · فوتر طايف.
  final Color surfaceRaised;

  /// الكروم اللي بيترجع لورا: بحث · شيب غير مختار · حقول.
  /// **بيقعد تحت [page] في الوضعين** — أغمق في الفاتح، وأغمق كمان في الغامق.
  final Color surfaceSunken;

  /// لوح البؤرة — حاجة واحدة في الشاشة.
  ///
  /// في الفاتح بيغمق عشان يكسب. في الغامق **بيفتح** — لوح أسود على صفحة سودا
  /// مش بؤرة، هو اختفاء.
  final Color surfaceInk;

  /// snackbar وشريط «مفيش نت» — بينقلب: غامق في الفاتح، فاتح في الغامق.
  final Color surfaceInverse;

  // ── اللمسة ─────────────────────────────────────────────────────────────

  final Color accent;
  final Color accentPressed;
  final Color accentSoft;

  /// سطح أخضر غامق بيشيل نص — نظير [surfaceInk] لما البؤرة تنبّه.
  ///
  /// **نفس القيمة في الوضعين** عن قصد: الأبيض عليه 6.80:1 و[textOnAccentMuted]
  /// 4.74:1، والاتنين متحقّق منهم. أي تفتيح للوضع الغامق كان هيكسّر التاني.
  final Color accentDeep;

  // ── الحدود ─────────────────────────────────────────────────────────────

  final Color border;
  final Color borderStrong;

  // ── النص ───────────────────────────────────────────────────────────────

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// نص على [accent].
  ///
  /// ⚠ **بينقلب بين الوضعين.** أبيض في الفاتح، وحبر غامق في الغامق — لأن
  /// اللمسة بتفتح لـ `#00CC77` والأبيض عليها **2.12:1** (راسب).
  final Color textOnAccent;

  final Color textOnInk;
  final Color textOnInkMuted;

  /// نص أساسي على [accentDeep].
  ///
  /// ⚠ **مش [textOnAccent]** — دي أهم تفرقة في الملف كله.
  ///
  /// [accentDeep] **نفس اللون في الوضعين**، فلازم فوقه يبقى نفس اللون في
  /// الوضعين كمان. لو استخدمنا [textOnAccent] كان الشريط في الوضع الغامق
  /// هياخد الحبر `#062015` على أخضر `#00693C` — **2.52:1**، يعني أهم شريط
  /// في الأبلكيشن («الكرسي جاهز») بيختفي بالليل.
  final Color textOnAccentDeep;

  /// نص ثانوي على [accentDeep] — **مش نفس [textOnInkMuted]**: الرمادي الدافي
  /// بتاع الحبر بيدي 1.35:1 على الأخضر. لكل سطح غامق رماديه.
  final Color textOnAccentMuted;

  final Color textOnInverse;

  // ── الحالات ────────────────────────────────────────────────────────────

  final Color danger;
  final Color dangerSoft;
  final Color dangerBorder;
  final Color warning;
  final Color warningSoft;
  final Color positive;
  final Color positiveSoft;
  final Color info;
  final Color infoSoft;

  /// نجمة التقييم — **دهبي مش [warning]**.
  ///
  /// `warning` بنّي (`#956321`) عشان يعدّي كـ**نص** على سطح فاتح. النجمة
  /// **رسمة مش نص**، وحدها ٣:١ مش ٤٫٥، والبنّي عليها بيقرا «معطّلة» مش
  /// «مقيّمة».
  final Color rating;

  // ── الـ skeleton والتعتيم والظل ────────────────────────────────────────

  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color scrimBase;

  /// لون الظل — **الحبر مش الأسود**. الأسود الصافي على خلفية بيضا بيبان متسخ،
  /// والظل البارد على صفحة دافية بيعمل نفس الحاجة.
  final Color shadowInk;

  /// معامل شدة الظل.
  ///
  /// في الغامق الظل تقريبًا مش باين، والألفا العالية بتعمل **هالة سودا** حوالين
  /// الكروت بدل ما ترفعها. العمق هناك بيتقال بفرق إضاءة الأسطح
  /// (`page → raised → ink`) مش بالظل.
  final double shadowScale;

  // ── هوية الكيان ────────────────────────────────────────────────────────
  //
  // الأبلكيشن مالوش صور بقرار موثّق، فالحرف البديل هو **الهوية البصرية**
  // لكل محل. في الغامق الأرضيات بتنقلب (لمعان ~٨٥٪ → ~١٥٪) والحبر بيفتح،
  // فالتباين بيفضل 7–9:1 في الوضعين.

  final List<Color> entityGrounds;
  final List<Color> entityGroundsDeep;
  final List<Color> entityInks;

  // ═══════════════════════════════════════════════════════════════════════
  // النسخة الفاتحة
  // ═══════════════════════════════════════════════════════════════════════

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,

    // **أوف-وايت دافي مش أبيض صافي.** لما الصفحة والكارت كانوا الاتنين
    // `#FFFFFF`، نظام العمق كله كان بيعتمد على ظل ٣٪ — يعني مستوى واحد.
    page: Color(0xffFAF9F7),
    surfaceRaised: Color(0xffFFFFFF),
    surfaceSunken: Color(0xffF1EFEC),
    surfaceInk: Color(0xff141314),
    surfaceInverse: Color(0xff272835),

    accent: Color(0xff009354),
    accentPressed: Color(0xff007A46),
    accentSoft: Color(0xffE5FFEE),
    accentDeep: Color(0xff00693C),

    border: Color(0xffECEFF3),
    borderStrong: Color(0xffDFE1E6),

    textPrimary: Color(0xff0D0D12),
    textSecondary: Color(0xff666D80),
    textTertiary: Color(0xff808897),
    textOnAccent: Color(0xffFFFFFF),
    textOnInk: Color(0xffFAF9F7),
    textOnInkMuted: Color(0xff9A968F),
    textOnAccentDeep: Color(0xffFAF9F7),
    textOnAccentMuted: Color(0xffC9DCD0),
    textOnInverse: Color(0xffFAF9F7),

    // **`#D81438` مش `#DF1C41`.**
    //
    // الأحمر القديم كان بيدي 4.79:1 على الكارت الأبيض ✓ بس **4.30:1 على
    // [dangerSoft]** ✗ — يعني شارة «لم يحضر» (١١sp) كانت راسبة، وهي أصغر
    // خط بيتكتب بالأحمر في الأبلكيشن.
    //
    // التغميق ده مالوش أثر محسوس على شكل اللون، وبيرفع الاتنين:
    // **5.15:1 على الأبيض** و**4.62:1 على الخلفية الوردية**.
    danger: Color(0xffD81438),
    dangerSoft: Color(0xffFEEFF2),
    dangerBorder: Color(0xffED8296),
    warning: Color(0xff956321),
    warningSoft: Color(0xffFFF6E0),
    positive: Color(0xff287F6E),
    positiveSoft: Color(0xffEFFEFA),
    info: Color(0xff106A97),
    infoSoft: Color(0xffEFFBFF),
    rating: Color(0xffFFB900),

    skeletonBase: Color(0xffECEFF3),
    skeletonHighlight: Color(0xffFFFFFF),
    scrimBase: Color(0xff0D0D12),

    shadowInk: Color(0xff141314),
    shadowScale: 1,

    entityGrounds: [
      Color(0xffD3DFEA), // أزرق مغبّر
      Color(0xffE7DAC6), // رملي
      Color(0xffD2E2D7), // أخضر مغبّر
      Color(0xffDED3E8), // بنفسجي مغبّر
    ],
    entityGroundsDeep: [
      Color(0xffBFD1E1),
      Color(0xffDBC9AC),
      Color(0xffBED5C6),
      Color(0xffCEBEDD),
    ],
    entityInks: [
      Color(0xff22374B),
      Color(0xff4A3A24),
      Color(0xff1F3B2C),
      Color(0xff382B47),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════
  // النسخة الغامقة
  // ═══════════════════════════════════════════════════════════════════════

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,

    // **دافي مش رمادي حيادي.** `#121212` بتاع ماتيريال بارد، والأبلكيشن كله
    // دافي — فبالليل كان هيقرا كأنه تطبيق تاني. القيم دي من نفس عيلة حبر
    // الأبلكيشن `#141314`.
    page: Color(0xff121110),
    surfaceRaised: Color(0xff1E1C1B),
    surfaceSunken: Color(0xff0B0A0A),
    surfaceInk: Color(0xff242120),
    surfaceInverse: Color(0xffE9E5E0),

    // `#009354` تباينه على الصفحة الغامقة **4.76:1** — عدّى بالعافية.
    // `#00CC77` (نفس السلّم، الدرجة ٣٠٠) بيدي **8.9:1**.
    accent: Color(0xff00CC77),
    accentPressed: Color(0xff00B369),
    accentSoft: Color(0xff0E2A1C),
    accentDeep: Color(0xff00693C),

    border: Color(0xff2A2725),
    borderStrong: Color(0xff3A3633),

    textPrimary: Color(0xffF5F3F0), // 17.0:1
    textSecondary: Color(0xffA8A29B), // 7.46:1
    textTertiary: Color(0xff86807A), // 4.83:1
    // حبر غامق مش أبيض — شوف شرح [textOnAccent].
    textOnAccent: Color(0xff062015), // 8.8:1 على اللمسة الفاتحة
    textOnInk: Color(0xffF5F3F0),
    textOnInkMuted: Color(0xffA8A29B),
    // **نفس الفاتح** — السطح اللي تحته نفس اللون في الوضعين.
    textOnAccentDeep: Color(0xffFAF9F7),
    textOnAccentMuted: Color(0xffC9DCD0),
    textOnInverse: Color(0xff141314),

    danger: Color(0xffFF6B85),
    dangerSoft: Color(0xff2A1218),
    dangerBorder: Color(0xff7A2337),
    warning: Color(0xffFFC24D),
    warningSoft: Color(0xff2A2010),
    positive: Color(0xff4FD1B0),
    positiveSoft: Color(0xff0E2621),
    info: Color(0xff63B8E8),
    infoSoft: Color(0xff0D2231),
    // أفتح من [warning] عن قصد — التوكنين لازم يفضلوا متفرقين في الوضعين،
    // وإلا أول ما حد يغيّر التحذير بكرة هياخد النجمة معاه من غير ما ياخد باله.
    rating: Color(0xffFFD166),

    skeletonBase: Color(0xff232120),
    skeletonHighlight: Color(0xff2E2B29),
    scrimBase: Color(0xff000000),

    shadowInk: Color(0xff000000),
    shadowScale: 0.55,

    entityGrounds: [
      Color(0xff22303D),
      Color(0xff3A3226),
      Color(0xff223328),
      Color(0xff302742),
    ],
    entityGroundsDeep: [
      Color(0xff1A2530),
      Color(0xff2E271D),
      Color(0xff1A2820),
      Color(0xff251E33),
    ],
    entityInks: [
      Color(0xffA9C4DC),
      Color(0xffDCC7A3),
      Color(0xffA6CBB2),
      Color(0xffC3AEDA),
    ],
  );

  static AppPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
