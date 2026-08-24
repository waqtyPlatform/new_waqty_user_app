import 'package:flutter/widgets.dart';

/// السلّم الخام — **نسختين، فاتحة وغامقة**.
///
/// ده الملف **الوحيد** في الكيت اللي فيه `Color(0x…)`. أي widget بيقرا لون
/// بيقراه من `AppSemanticColors` مش من هنا.
///
/// ## منين جت القيم
///
/// النسخة الفاتحة **مش مخترعة** — كل لون فيها توكن موجود في
/// `employee-app/lib/core/utils/app_colors_white_theme.dart`، ومكتوب جنبه
/// اسمه الأصلي. الـ ٦٤ توكن هناك اتلمّوا على ٣٩ **دور**: ١٢ منهم كانوا
/// مكررين أو شبه مكررين (`greyColor100`/`greyColor1001` بيفرقوا رقم hex
/// واحد)، والباقي اتوزّع على أدوار بدل أسماء زي `errorColor200333`.
///
/// النسخة الغامقة **مشتقة مش مخترعة**. الـ ramps بتاعة employee-app فيها
/// دارك مود أصلًا، محدش عمل الربط: `accent` الغامق هو `greenColor300`،
/// و`warning` الغامق هو `warningColor50`، وهكذا. ١١ قيمة بس جديدة فعلًا،
/// وكلهم أسطح أو تعبئات خفيفة — مافيش لون بيحمل هوية اتخلق من العدم.
///
/// ## ليه كلاس بنسختين مش ThemeExtension
///
/// الـ `ThemeExtension` محتاج `context` عند كل استدعاء، و`AppTextStyles`
/// و`AppShadows` و`AppGradients` كلهم **static getters مالهمش element tree**.
/// يعني الـ `ThemeExtension` كان هيفرض `context` عليهم كلهم ويغيّر كل call site.
///
/// الثمن مكتوب في `AppSemanticColors` وفي الـ README: التوكنز statics، فالـ
/// `const` widget اللي بيرسم توكن بيمسك لون بايت لما الوضع يقلب — والحل
/// `ValueKey(brightness)` على `MaterialApp`.
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
    required this.accentText,
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
    required this.textOnDanger,
    required this.dangerOnSoft,
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
  final Color surfaceSunken;

  /// لوح البؤرة — حاجة واحدة في الشاشة.
  ///
  /// في الفاتح بيغمق عشان يكسب. في الغامق **بيفتح** — لوح أسود على صفحة
  /// سودا مش بؤرة، هو اختفاء.
  final Color surfaceInk;

  /// snackbar وشريط «مفيش نت» — بينقلب: غامق في الفاتح، فاتح في الغامق.
  final Color surfaceInverse;

  // ── اللمسة ─────────────────────────────────────────────────────────────

  /// أخضر Waqty — `greenColor500` بتاع employee-app، ١٦٥ استخدام.
  ///
  /// ⚠ **للهوية بس: أيقونة، حالة مختارة، حلقة تركيز، حد.** مش تعبئة تحت نص.
  /// الأبيض عليه **3.96:1** — عدّى AA-large ورسب AA-normal، ولابل الزرار
  /// 16sp/w600 يعني ١٢٫٦ نقطة، تحت عتبة النص الكبير. أي سطح أخضر بيشيل نص
  /// بياخد [accentDeep].
  final Color accent;

  /// **الأخضر لما يبقى هو النص نفسه** — رابط، «شوف الكل»، زرار ثانوي.
  ///
  /// نفس منطق [accentDeep] بالظبط بس في الاتجاه التاني: [accent] كنص على
  /// الصفحة بيدي **3.80:1** وعلى الكارت **3.96:1** — راسب AA. فده حد أدنى
  /// مسمّى مش لون جديد: في الفاتح بياخد [accentDeep] (**6.52** على الصفحة)،
  /// وفي الغامق بياخد [accent] نفسه (**9.01**) لأنه بيفتح هناك أصلًا.
  final Color accentText;

  final Color accentPressed;
  final Color accentSoft;

  /// سطح أخضر غامق بيشيل نص — نظير [surfaceInk] لما البؤرة تنبّه.
  ///
  /// **نفس القيمة في الوضعين** عن قصد: الأبيض عليه 6.81:1
  /// و[textOnAccentMuted] 6.00:1، والاتنين متحقّق منهم. أي تفتيح للوضع
  /// الغامق كان هيكسّر التاني.
  ///
  /// ده **مش لون جديد على الهوية**: زرار employee-app الأساسي بيرسم تدرّج
  /// `#009354 → #007341` النهاردة، يعني أخضر أغمق من `accent` **متحطوط
  /// على الزرار ده فعلًا**. [accentDeep] بياخد نهاية الرامب ويثبّتها.
  final Color accentDeep;

  // ── الحدود ─────────────────────────────────────────────────────────────

  /// الحد الشعري — **بيترسم على [surfaceRaised] مش على [page]**.
  ///
  /// الكارت بينفصل عن الصفحة **بالظل**، مش بالحد. فالعتبة (١٫٣:١) بتتقاس
  /// على الكارت. القيمة الفاتحة `#DFE1E7` بتدي 1.31 على الكارت ✓ و1.25 على
  /// الصفحة — وده مقبول لأنه مش السطح اللي بترسم عليه.
  final Color border;

  final Color borderStrong;

  // ── النص ───────────────────────────────────────────────────────────────

  final Color textPrimary;

  /// النص الثانوي — **`greyColor500 #666D80` مش `greyColorA3` ولا `greyColor4002`**.
  ///
  /// employee-app بيستخدم `#A3A3A3` (**2.52:1**) و`#818898` (**3.55:1**)
  /// كنص ثانوي في ~٣٠ ستايل. ولا واحد فيهم بيعدّي AA. `#666D80` بيدي
  /// **4.95:1** وهو **كمان توكن من employee-app**، فالإصلاح فاضل جوه
  /// الـ palette.
  ///
  /// ⚠ ده تغيير **مرئي**: النص الثانوي بيغمق في الواجهة كلها.
  final Color textSecondary;

  /// **غير نصي بس** — معطّل، أيقونات، فواصل. 3.41:1 على الصفحة.
  final Color textTertiary;

  /// نص على [accent].
  ///
  /// ⚠ **بينقلب بين الوضعين.** أبيض في الفاتح، وحبر غامق في الغامق — لأن
  /// اللمسة بتفتح لـ `#00CC77` والأبيض عليها **2.12:1** (راسب).
  final Color textOnAccent;

  final Color textOnInk;
  final Color textOnInkMuted;

  /// نص أساسي على [accentDeep] — **6.81:1**.
  ///
  /// ⚠ **مش [textOnAccent]** — دي أهم تفرقة في الملف كله. [accentDeep]
  /// نفس اللون في الوضعين، فلازم اللي فوقه يبقى نفس اللون كمان. لو
  /// استخدمنا [textOnAccent] كان الشريط في الوضع الغامق هياخد الحبر
  /// `#062015` على أخضر `#00693C` — **2.52:1**.
  final Color textOnAccentDeep;

  /// نص ثانوي على [accentDeep] — 6.00:1. **مش [textOnInkMuted]**؛ الرمادي
  /// البارد بتاع الحبر بيقرا ميت على الأخضر. لكل سطح غامق رماديه.
  final Color textOnAccentMuted;

  final Color textOnInverse;

  // ── الحالات ────────────────────────────────────────────────────────────

  /// الأحمر — `errorColor100` بتاع employee-app، ٣٨ استخدام. 4.79:1 على الكارت.
  final Color danger;

  /// نص على تعبئة [danger] — زرار الحذف.
  ///
  /// ⚠ **بينقلب زي [textOnAccent] بالظبط.** أبيض على الأحمر الفاتح
  /// **4.79:1** ✓، وعلى الأحمر الغامق (`#ED8296`، بيفتح في الوضع الغامق)
  /// **2.55:1** ✗ — فبياخد حبر غامق هناك (**7.60:1**).
  final Color textOnDanger;

  /// ⚠ **الأحمر لما يقعد على [dangerSoft].**
  ///
  /// [danger] على [dangerSoft] بيدي **4.30:1** — راسب. ده مش لون جديد،
  /// ده **حد أدنى مسمّى**: نفس فكرة `textOnSunken`، القاعدة تتكتب بدل ما
  /// تتحفظ. القيمة `errorColor200` بتدي **7.85:1**.
  final Color dangerOnSoft;

  final Color dangerSoft;
  final Color dangerBorder;

  /// التحذير كـ**نص** — `warningColor200 #956321` (بنّي، 5.14:1).
  ///
  /// employee-app بيستخدم `warningColor1001 #EAB308` كنص، وده **1.92:1**
  /// على الأبيض — مالوش أي استخدام كنص. الدهبي عاش في [rating].
  final Color warning;

  final Color warningSoft;
  final Color positive;
  final Color positiveSoft;
  final Color info;
  final Color infoSoft;

  /// نجمة التقييم — **دهبي مش [warning]**.
  ///
  /// النجمة **رسمة مش نص**، وحدها ٣:١ مش ٤٫٥، والبنّي عليها بيقرا «معطّلة»
  /// مش «مقيّمة».
  final Color rating;

  // ── الـ skeleton والتعتيم والظل ────────────────────────────────────────

  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color scrimBase;

  /// لون الظل — **الحبر مش الأسود**. ظلال employee-app بتستخدم
  /// `greyColor900` حرفيًا؛ الكيت بيمسك القرار ده.
  final Color shadowInk;

  /// معامل شدة الظل.
  ///
  /// في الغامق الظل تقريبًا مش باين، والألفا العالية بتعمل **هالة سودا**
  /// حوالين الكروت بدل ما ترفعها. العمق هناك بيتقال بفرق إضاءة الأسطح
  /// (`sunken → page → raised → ink`) مش بالظل.
  final double shadowScale;

  // ── هوية الكيان ────────────────────────────────────────────────────────
  //
  // الأبلكيشنين مافيهمش ولا صورة فوتوغرافية، فالحرف البديل هو **الهوية
  // البصرية** لكل كيان. في الغامق الأرضيات بتنقلب والحبر بيفتح، فالتباين
  // بيفضل 6–12:1 في الوضعين.

  final List<Color> entityGrounds;
  final List<Color> entityInks;

  // ═══════════════════════════════════════════════════════════════════════
  // النسخة الفاتحة — كل لون توكن من employee-app، مكتوب جنبه اسمه
  // ═══════════════════════════════════════════════════════════════════════

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,

    page: Color(0xffFAFAFA), // greyColorFA — ٥٣ استخدام
    surfaceRaised: Color(0xffFFFFFF), // whiteColor
    surfaceSunken: Color(0xffF5F5F5), // greyColorF5
    surfaceInk: Color(0xff1A1B25), // greyColor800
    surfaceInverse: Color(0xff272835), // greyColor700

    accent: Color(0xff009354), // greenColor500 — ١٦٥ استخدام
    accentText: Color(0xff00693C), // = accentDeep — 6.52 على الصفحة
    accentPressed: Color(0xff007341), // نقطة التدرّج اللي كانت سايبة
    accentSoft: Color(0xffE5FFEE), // greenColor505
    accentDeep: Color(0xff00693C), // خطوة بعد accentPressed

    border: Color(0xffDFE1E7), // greyColor1001 — ٤٨ استخدام
    borderStrong: Color(0xffC1C7CF), // greyColor200

    textPrimary: Color(0xff0D0D12), // greyColor900 — ١١٣ استخدام
    textSecondary: Color(0xff666D80), // greyColor500
    textTertiary: Color(0xff818898), // greyColor4002
    textOnAccent: Color(0xffFFFFFF), // whiteColor
    textOnInk: Color(0xffFAFAFA), // greyColorFA
    textOnInkMuted: Color(0xffA4ACB9), // greyColor3003
    textOnAccentDeep: Color(0xffFFFFFF), // whiteColor
    textOnAccentMuted: Color(0xffC0FFD6), // greenColor50
    textOnInverse: Color(0xffFAFAFA), // greyColorFA

    danger: Color(0xffDF1C41), // errorColor100 — ٣٨ استخدام
    textOnDanger: Color(0xffFFFFFF), // 4.79 على الأحمر
    dangerOnSoft: Color(0xff95122B), // errorColor200
    dangerSoft: Color(0xffFEEFF2), // errorColor0
    dangerBorder: Color(0xffED8296), // errorColor50
    warning: Color(0xff956321), // warningColor200
    warningSoft: Color(0xffFFF6E0), // warningColor0
    positive: Color(0xff287F6E), // successColor200
    positiveSoft: Color(0xffEFFEFA), // successColor0
    info: Color(0xff106A97), // blueColor200
    infoSoft: Color(0xffEFFBFF), // blueColor0
    rating: Color(0xffFFB900), // warningColor3003

    skeletonBase: Color(0xffECEFF3), // greyColor50
    skeletonHighlight: Color(0xffFFFFFF), // whiteColor
    scrimBase: Color(0xff0D0D12), // greyColor900

    shadowInk: Color(0xff0D0D12), // greyColor900
    shadowScale: 1,

    entityGrounds: [
      Color(0xffD1F0F9), // blueColor25
      Color(0xffFFF6E0), // warningColor0
      Color(0xffE5FFEE), // greenColor505
      Color(0xffECEFF3), // greyColor50
    ],
    entityInks: [
      Color(0xff0C4D6E), // blueColor300 — 7.62:1
      Color(0xff5B3D1E), // warningColor300 — 9.16:1
      Color(0xff00693C), // accentDeep — 6.44:1
      Color(0xff353849), // greyColor600 — 10.04:1
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════
  // النسخة الغامقة — ١١ قيمة جديدة بس، الباقي خطوات من نفس الـ ramps
  // ═══════════════════════════════════════════════════════════════════════

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,

    // الأربع أسطح دول هم أكتر حاجة جديدة في الملف. الترتيب بينقلب:
    // في الفاتح الحبر **أغمق** حاجة، وفي الغامق **أفتح** حاجة.
    page: Color(0xff0F0F14), // جديد
    surfaceRaised: Color(0xff16161D), // جديد
    surfaceSunken: Color(0xff0A0A0E), // جديد
    surfaceInk: Color(0xff1F1F28), // جديد — بيفتح مش بيغمق
    surfaceInverse: Color(0xffECEFF3), // greyColor50

    accent: Color(0xff00CC77), // greenColor300 — 9.01:1 على الصفحة
    accentText: Color(0xff00CC77), // = accent — بيفتح هنا أصلًا
    accentPressed: Color(0xff00B166), // greenColor400
    accentSoft: Color(0xff12301F), // جديد
    accentDeep: Color(0xff00693C), // **نفس الفاتح**
    // `#2A2B38` كان بيدي 1.287 على الكارت — تحت عتبة الظهور بشعرة.
    // ده بالظبط الباج اللي الاختبار موجود عشانه: الحدود بتختفي في الغامق.
    border: Color(0xff2D2E3C), // جديد — 1.34 على الكارت
    borderStrong: Color(0xff353849), // greyColor600 — 1.55

    textPrimary: Color(0xffF5F5F5), // greyColorF5
    textSecondary: Color(0xffA4ACB9), // greyColor3003 — 8.36:1
    textTertiary: Color(0xff808897), // greyColor400
    textOnAccent: Color(0xff062015), // جديد — 8.08:1؛ الأبيض هيدي 2.12
    textOnInk: Color(0xffF5F5F5), // greyColorF5
    textOnInkMuted: Color(0xffA4ACB9), // greyColor3003
    textOnAccentDeep: Color(0xffFFFFFF), // **نفس الفاتح**
    textOnAccentMuted: Color(0xffC0FFD6), // **نفس الفاتح**
    textOnInverse: Color(0xff0D0D12), // greyColor900

    danger: Color(0xffED8296), // errorColor50
    textOnDanger: Color(0xff0D0D12), // greyColor900 — 7.60؛ الأبيض هيدي 2.55
    dangerOnSoft: Color(0xffFCA5A5), // errorColor200333
    dangerSoft: Color(0xff2A1218), // جديد
    dangerBorder: Color(0xff95122B), // errorColor200
    warning: Color(0xffFBD982), // warningColor50
    warningSoft: Color(0xff2A2010), // جديد
    positive: Color(0xff9DE0D3), // successColor50
    positiveSoft: Color(0xff0E2621), // جديد
    info: Color(0xff7EDCF1), // blueColor50
    infoSoft: Color(0xff0D2231), // جديد
    rating: Color(0xffFFB900), // warningColor3003 — **نفس الفاتح**
    // لطيفين بقصد: وميض أبيض على كارت أسود ستروب مش تحميل.
    skeletonBase: Color(0xff1C1C24), // جديد
    skeletonHighlight: Color(0xff26262F), // جديد
    scrimBase: Color(0xff000000),

    shadowInk: Color(0xff000000),
    shadowScale: 0.55,

    entityGrounds: [
      Color(0xff0D2231), // infoSoft الغامق
      Color(0xff2A2010), // warningSoft الغامق
      Color(0xff12301F), // accentSoft الغامق
      Color(0xff272835), // greyColor700
    ],
    entityInks: [
      Color(0xff7EDCF1), // blueColor50 — 10.38:1
      Color(0xffFBD982), // warningColor50 — 11.69:1
      Color(0xff00CC77), // greenColor300 — 6.74:1
      Color(0xffA4ACB9), // greyColor3003 — 6.37:1
    ],
  );

  static AppPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
