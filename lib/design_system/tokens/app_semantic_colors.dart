import 'package:flutter/widgets.dart';

import 'app_palette.dart';

/// الطبقة الدلالية للألوان — **الواجهة الوحيدة اللي الـ widgets بتقرا منها**.
///
/// `AppPalette` هي القيم الخام (نسختين). الملف ده بيدّي كل لون **دوره**،
/// و**مافيهوش ولا hex واحد**.
///
/// ## من `const` لـ getters
///
/// كل توكن هنا `static … get`، مش `static const`. القيم بتتقرا من [palette]
/// وقت الاستدعاء، فنفس السطر `AppSemanticColors.page` بيدي الأبيض في النهار
/// و`#0F0F14` بالليل — **من غير ما أي widget يتلمس**.
///
/// الثمن إن التوكنز مابقتش `const`، يعني `const ColoredBox(color: …)` مابقاش
/// ينفع. الـ `analysis_options.yaml` مطفّي `prefer_const_constructors` عشان
/// كده بالظبط.
///
/// ## مين بيظبط الوضع
///
/// اللي بيشغّل الأبلكيشن بينادي [apply] **قبل** ما `appTheme()` تتبني وقبل ما
/// `MaterialApp` تتعمل. الترتيب ده مش تفصيلة — لو اتعكس، الثيم بيتبني من
/// الـ palette السابق فبتطلع كروم فاتح على صفحة غامقة. الـ README فيه
/// التسلسل كامل.
class AppSemanticColors {
  AppSemanticColors._();

  static AppPalette _palette = AppPalette.light;

  /// الـ palette الشغّال دلوقتي.
  static AppPalette get palette => _palette;

  static Brightness get brightness => _palette.brightness;

  static bool get isDark => _palette.isDark;

  /// بيتنادى من مدخل الأبلكيشن بس.
  ///
  /// بيرجّع `true` لو الوضع اتغيّر فعلاً — الرجوع ده بيخلي اللي فوق يقرر
  /// يعيد البناء ولا لأ من غير ما يقارن بنفسه.
  static bool apply(Brightness brightness) {
    if (_palette.brightness == brightness) return false;
    _palette = AppPalette.of(brightness);
    return true;
  }

  // ── الأسطح ───────────────────────────────────────────────────────────

  /// **الصفحة نفسها** — اللي كل حاجة قاعدة فوقه.
  static Color get page => _palette.page;

  /// **المحتوى المرفوع** — كارت، sheet، فوتر طايف، أو شريحة فوق سطح ملوّن.
  static Color get surfaceRaised => _palette.surfaceRaised;

  /// الكروم اللي المفروض يترجع لورا: البحث، الشيب غير المختار، الحقول.
  ///
  /// **قاعدة: مفيش نص أفتح من [textSecondary] يقعد هنا.** استخدم
  /// [textOnSunken].
  static Color get surfaceSunken => _palette.surfaceSunken;

  /// سطح بؤرة — البؤرة الوحيدة في الشاشة.
  static Color get surfaceInk => _palette.surfaceInk;

  /// خلفية اللمسة الخفيفة — للحالة المختارة بس.
  static Color get surfaceAccentSoft => _palette.accentSoft;

  /// **سطح أخضر غامق — نظير [surfaceInk] لما البؤرة تنبّه.**
  ///
  /// أي تعبئة خضرا تحتها نص بتيجي من هنا مش من [accent]. الأبيض على
  /// [accent] بيدي **3.96:1** وعلى ده **6.81:1**.
  static Color get surfaceAccentDeep => _palette.accentDeep;

  /// سطح مقلوب — الـ snackbar وشريط «مفيش نت».
  static Color get surfaceInverse => _palette.surfaceInverse;

  // ── الحدود ───────────────────────────────────────────────────────────

  static Color get border => _palette.border;
  static Color get borderStrong => _palette.borderStrong;

  // ── النص ─────────────────────────────────────────────────────────────

  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;

  /// **غير نصي.** معطّل، أيقونة، فاصل. تباينه على الصفحة **3.41:1**.
  static Color get textTertiary => _palette.textTertiary;

  /// نص على [accent].
  ///
  /// ⚠ **مش أبيض دايمًا.** في الغامق بينقلب لحبر غامق لأن اللمسة بتفتح.
  /// عمر ما تكتب `Colors.white` على زرار — اقرا التوكن.
  static Color get textOnAccent => _palette.textOnAccent;

  /// أقل لون مسموح على [surfaceSunken]. مش لون جديد — ده اسم بيقول «الحد
  /// الأدنى هنا» عشان القاعدة تبقى مكتوبة مش محفوظة.
  static Color get textOnSunken => _palette.textSecondary;

  /// نص على [surfaceInk].
  static Color get textOnInk => _palette.textOnInk;

  static Color get textOnInkMuted => _palette.textOnInkMuted;

  /// نص أساسي على [surfaceAccentDeep] — 6.81:1.
  ///
  /// ⚠ **استخدم ده مش [textOnAccent]** على أي سطح أخضر غامق. [textOnAccent]
  /// بينقلب لحبر في الوضع الغامق، وعلى `#00693C` بيدي **2.52:1**.
  static Color get textOnAccentDeep => _palette.textOnAccentDeep;

  /// نص ثانوي على [surfaceAccentDeep] — 6.00:1.
  static Color get textOnAccentMuted => _palette.textOnAccentMuted;

  /// نص على [surfaceInverse].
  static Color get textOnInverse => _palette.textOnInverse;

  // ── اللهجة ───────────────────────────────────────────────────────────

  /// الأخضر — **للزرار الأساسي والحالة المختارة وأيقونة التصنيف بس.**
  ///
  /// ⚠ لو هتحطه **تحت** نص، خد [surfaceAccentDeep] بدله.
  static Color get accent => _palette.accent;

  /// **الأخضر لما يبقى هو النص** — رابط، «شوف الكل»، زرار ثانوي، لابل ملوّن.
  ///
  /// حد أدنى مسمّى زي [textOnSunken] و[dangerOnSoft]: [accent] كنص على
  /// الصفحة بيدي **3.80:1** (راسب). ده بيدي **6.52** في الفاتح و**9.01**
  /// في الغامق.
  static Color get accentText => _palette.accentText;

  static Color get accentPressed => _palette.accentPressed;
  static Color get accentSoft => _palette.accentSoft;

  /// لمسة خضرا شفافة — خلفية دايرة أيقونة، صف مميّز، تظليل خفيف.
  ///
  /// employee-app كاتب النية دي بألفتين مختلفتين: `0x0F009354` (٦٪) في ٦
  /// مواضع، و`greenColor500.withValues(alpha: .08)` في `PayslipDetailRow`.
  /// واحدة بس بتفضل.
  static Color get accentTint => _palette.accent.withValues(alpha: .08);

  // ── الحالات ──────────────────────────────────────────────────────────

  static Color get danger => _palette.danger;

  /// نص على تعبئة [danger] — زرار الحذف.
  ///
  /// ⚠ **بينقلب زي [textOnAccent]**: أبيض في الفاتح، حبر في الغامق (الأحمر
  /// بيفتح هناك، والأبيض عليه بيدي **2.55:1**).
  static Color get textOnDanger => _palette.textOnDanger;

  /// ⚠ **الأحمر لما يقعد على [dangerSoft].** حد أدنى مسمّى، نفس فكرة
  /// [textOnSunken]: [danger] على [dangerSoft] بيدي **4.30:1** (راسب)،
  /// وده بيدي **7.85:1**.
  static Color get dangerOnSoft => _palette.dangerOnSoft;

  static Color get dangerSoft => _palette.dangerSoft;
  static Color get dangerBorder => _palette.dangerBorder;

  static Color get warning => _palette.warning;
  static Color get warningSoft => _palette.warningSoft;

  static Color get positive => _palette.positive;
  static Color get positiveSoft => _palette.positiveSoft;

  static Color get info => _palette.info;
  static Color get infoSoft => _palette.infoSoft;

  /// نجمة التقييم — دهبي. **مش [warning]** (ده بنّي عشان يعدّي كنص).
  static Color get rating => _palette.rating;

  // ── الـ skeleton والتعتيم ────────────────────────────────────────────

  static Color get skeletonBase => _palette.skeletonBase;
  static Color get skeletonHighlight => _palette.skeletonHighlight;

  /// طبقة التعتيم فوق الصور.
  static Color get scrim => _palette.scrimBase.withValues(alpha: .45);
  static Color get scrimSoft => _palette.scrimBase.withValues(alpha: .25);
}
