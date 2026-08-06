import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/core/utils/app_palette.dart';

/// الطبقة الدلالية للألوان — **الواجهة الوحيدة اللي الـ widgets بتقرا منها**.
///
/// `AppPalette` هي القيم الخام (نسختين). الملف ده بيدّي كل لون **دوره**،
/// و**مافيهوش ولا hex واحد**.
///
/// ## من `const` لـ getters
///
/// كل توكن هنا كان `static const`. القيم دلوقتي بتتقرا من [palette] وقت
/// الاستدعاء، فنفس السطر `AppSemanticColors.page` بيدي الأبيض الدافي في النهار
/// و`#121110` بالليل — **من غير ما أي widget يتلمس**.
///
/// الثمن الوحيد إن التوكنز مابقتش `const`، يعني `const ColoredBox(color: …)`
/// مابقاش ينفع. التلات مواضع اللي كانوا كده اتظبطوا.
///
/// ## مين بيظبط الوضع
///
/// `my_app.dart` بينادي [apply] **قبل** ما `MaterialApp` تتبني، فالقيم مضمون
/// إنها صح وقت الرسم. ماتناديهاش من أي مكان تاني.
class AppSemanticColors {
  AppSemanticColors._();

  static AppPalette _palette = AppPalette.light;

  /// الـ palette الشغّال دلوقتي.
  static AppPalette get palette => _palette;

  static Brightness get brightness => _palette.brightness;

  static bool get isDark => _palette.isDark;

  /// بيتنادى من `my_app.dart` بس.
  ///
  /// بيرجّع `true` لو الوضع اتغيّر فعلاً — الرجوع ده بيخلي اللي فوق يقرر
  /// يعيد البناء ولا لأ من غير ما يقارن بنفسه.
  static bool apply(Brightness brightness) {
    if (_palette.brightness == brightness) return false;
    _palette = AppPalette.of(brightness);
    return true;
  }

  // ── الأسطح ───────────────────────────────────────────────────────────
  //
  // كان فيه توكن واحد اسمه `surface` بيعمل **شغلانتين مختلفتين** في ١٧ موضع:
  // «الصفحة اللي كل حاجة قاعدة عليها»، و«شريحة بيضا فوق حاجة تانية». الاسم
  // مكانش بيفرّق بينهم، فأي تغيير في قيمته كان بيقلب التسعة بتوع الدور
  // التاني في صمت.

  /// **الصفحة نفسها** — اللي كل حاجة قاعدة فوقه.
  static Color get page => _palette.page;

  /// **المحتوى المرفوع** — كارت، sheet، فوتر طايف، أو شريحة فوق سطح ملوّن.
  static Color get surfaceRaised => _palette.surfaceRaised;

  /// الكروم اللي المفروض يترجع لورا: البحث، الشيب غير المختار، الحقول.
  ///
  /// **قاعدة: مفيش نص أفتح من [textSecondary] يقعد هنا.** استخدم
  /// [textOnSunken] — الـ `textTertiary` تباينه على الغاطس **3.11:1** (راسب).
  static Color get surfaceSunken => _palette.surfaceSunken;

  /// سطح بؤرة — البؤرة الوحيدة في الشاشة.
  static Color get surfaceInk => _palette.surfaceInk;

  /// خلفية اللمسة الخفيفة — للحالة المختارة بس.
  static Color get surfaceAccentSoft => _palette.accentSoft;

  /// **سطح أخضر غامق — نظير [surfaceInk] لما البؤرة تنبّه.**
  ///
  /// [accent] معمول عشان يقعد **على** صفحة، فتباينه محسوب مع الصفحة مش مع
  /// النص اللي فوقه. لما بقى خلفية، النص الثانوي طلع **1.35:1** — يعني أهم
  /// لحظة في الأبلكيشن كانت أقل شاشة مقروءة فيه.
  static Color get surfaceAccentDeep => _palette.accentDeep;

  /// سطح مقلوب — الـ snackbar وشريط «مفيش نت».
  static Color get surfaceInverse => _palette.surfaceInverse;

  // ── الحدود ───────────────────────────────────────────────────────────

  static Color get border => _palette.border;
  static Color get borderStrong => _palette.borderStrong;

  // ── النص ─────────────────────────────────────────────────────────────

  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textTertiary => _palette.textTertiary;

  /// نص على [accent].
  ///
  /// ⚠ **مش أبيض دايمًا.** في الغامق بينقلب لحبر غامق لأن اللمسة بتفتح.
  /// عمر ما تكتب `Colors.white` على زرار — اقرا التوكن.
  static Color get textOnAccent => _palette.textOnAccent;

  /// أقل لون مسموح على [surfaceSunken]. مش لون جديد — ده اسم بيقول «الحد
  /// الأدنى هنا» عشان القاعدة تبقى مكتوبة مش محفوظة.
  static Color get textOnSunken => _palette.textSecondary;

  /// نص على [surfaceInk]. **مش أبيض صافي** — الأبيض على شبه الأسود بيرجرج.
  static Color get textOnInk => _palette.textOnInk;

  static Color get textOnInkMuted => _palette.textOnInkMuted;

  /// نص أساسي على [surfaceAccentDeep] — 6.4:1.
  ///
  /// ⚠ **استخدم ده مش [textOnAccent]** على أي سطح أخضر غامق. [textOnAccent]
  /// بينقلب لحبر في الوضع الغامق، وعلى `#00693C` بيدي **2.52:1**.
  static Color get textOnAccentDeep => _palette.textOnAccentDeep;

  /// نص ثانوي على [surfaceAccentDeep] — 4.74:1.
  static Color get textOnAccentMuted => _palette.textOnAccentMuted;

  /// نص على [surfaceInverse].
  static Color get textOnInverse => _palette.textOnInverse;

  // ── اللهجة ───────────────────────────────────────────────────────────

  /// الأخضر — **للزرار الأساسي والحالة المختارة وأيقونة التصنيف بس.**
  /// كان بيتستخدم في ٣٨ موضع كأيقونة ونص ورابط وخلفية وحد وحلقة تركيز —
  /// فبطّل يعلّم أي حاجة.
  static Color get accent => _palette.accent;

  static Color get accentPressed => _palette.accentPressed;
  static Color get accentSoft => _palette.accentSoft;

  // ── الحالات ──────────────────────────────────────────────────────────

  static Color get danger => _palette.danger;
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
