import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

/// الطبقة الدلالية للألوان.
///
/// `AppColors` هي الألوان الخام (السلّم). الملف ده بيدّي كل لون **دوره**.
/// **مافيهوش ولا hex واحد** — بس إعادة توجيه، فمفيش تكرار ولا مصدرين للحقيقة.
///
/// قبل كده مكانش فيه طبقة دلالية خالص: لون الحدود ولون النص الثانوي كانوا
/// الاتنين اسمهم رقم من السلّم، فمن مكان الاستدعاء مش فارقين عن بعض.
class AppSemanticColors {
  AppSemanticColors._();

  // ── الأسطح ───────────────────────────────────────────────────────────
  //
  // كان فيه توكن واحد اسمه `surface` بيعمل **شغلانتين مختلفتين** في ١٧ موضع:
  // «الصفحة اللي كل حاجة قاعدة عليها»، و«شريحة بيضا فوق حاجة تانية» (زي
  // الطبق الأبيض جوه بلاطة التصنيف الغاطسة، أو شارة الحالة فوق الكارت
  // الأخضر). الاسم مكانش بيفرّق بينهم، فأي تغيير في قيمته كان بيقلب التسعة
  // بتوع الدور التاني في صمت.

  /// **الصفحة نفسها** — اللي كل حاجة قاعدة فوقه.
  ///
  /// التوكن القديم `surface` **اتحذف** عن قصد بدل ما يفضل alias — عشان أي
  /// كود جديد يضطر يقرر: ده صفحة ولا شريحة مرفوعة؟
  ///
  /// **أوف-وايت دافي مش أبيض صافي.** لما الصفحة والكارت كانوا الاتنين
  /// `#FFFFFF`، نظام العمق التلاتي كله كان بيعتمد على ظل ٤٪ — يعني
  /// عمليًا مستوى واحد. دلوقتي فيه فرق إضاءة حقيقي، والظل بقى تأكيد
  /// مش الإشارة الوحيدة.
  static const Color page = AppColors.pageColor;

  /// **المحتوى المرفوع** — كارت، sheet، فوتر طايف، أو شريحة بيضا فوق سطح
  /// ملوّن أو غاطس.
  static const Color surfaceRaised = AppColors.whiteColor;

  /// الكروم اللي المفروض يترجع لورا: البحث، الشيب غير المختار، الحقول.
  ///
  /// **قاعدة: مفيش نص أفتح من [textSecondary] يقعد هنا.** استخدم
  /// [textOnSunken]. الـ `textTertiary` تباينه على الغاطس **3.11:1** — راسب.
  ///
  /// اتنقل من `#F6F8FA` (رمادي بارد) لـ `#F1EFEC` (دافي وأغمق) عشان يقعد
  /// **تحت** الصفحة الجديدة مش فوقها. الفرق عن الكارت الأبيض طلع من ٦٫٥٪
  /// لـ **١٤٫٨٪**.
  static const Color surfaceSunken = AppColors.sunkenColor;

  /// سطح حبر غامق — البؤرة الوحيدة في الشاشة.
  static const Color surfaceInk = AppColors.inkColor;

  /// خلفية خضرا فاتحة — للحالة المختارة بس.
  static const Color surfaceAccentSoft = AppColors.greenColor505;

  /// **سطح أخضر غامق — نظير [surfaceInk] لما البؤرة تنبّه.**
  ///
  /// كان الشريط بياخد [accent] نفسه لما الكرسي يجهز. و[accent] معمول
  /// عشان يقعد **على** صفحة فاتحة، فتباينه محسوب مع الأبيض مش مع النص
  /// اللي فوقه. لما بقى خلفية، النص الثانوي طلع **1.35:1** والعنوان
  /// **3.76:1** — يعني أهم لحظة في الأبلكيشن كانت أقل شاشة مقروءة فيه.
  static const Color surfaceAccentDeep = AppColors.greenColor700;

  /// سطح غامق — الـ snackbar وشريط «مفيش نت».
  static const Color surfaceInverse = AppColors.greyColor700;

  // ── الحدود ───────────────────────────────────────────────────────────

  static const Color border = AppColors.greyColor50;
  static const Color borderStrong = AppColors.greyColor100;

  // ── النص ─────────────────────────────────────────────────────────────

  static const Color textPrimary = AppColors.greyColor900;
  static const Color textSecondary = AppColors.greyColor500;
  static const Color textTertiary = AppColors.greyColor400;
  static const Color textOnAccent = AppColors.whiteColor;

  /// أقل لون مسموح على [surfaceSunken]. مش توكن جديد بلون جديد — ده اسم
  /// بيقول «الحد الأدنى هنا» عشان القاعدة تبقى مكتوبة مش محفوظة.
  static const Color textOnSunken = AppColors.greyColor500;

  /// نص على الحبر. **مش أبيض صافي** — الأبيض على شبه الأسود بيرجرج
  /// وبيقرا رخيص. نفس تباين الصفحة الدافية (17.6:1).
  static const Color textOnInk = AppColors.pageColor;

  /// نص ثانوي على الحبر — 6.30:1.
  static const Color textOnInkMuted = AppColors.inkMutedColor;

  /// نص ثانوي على [surfaceAccentDeep] — 4.74:1.
  ///
  /// **مش نفس [textOnInkMuted]** عن قصد: الرمادي الدافي بتاع الحبر بيدي
  /// 1.35:1 على الأخضر. لكل سطح غامق رماديه.
  static const Color textOnAccentMuted = AppColors.greenInkMutedColor;

  // ── اللهجة ───────────────────────────────────────────────────────────

  /// الأخضر — **للزرار الأساسي والحالة المختارة بس.**
  /// كان بيتستخدم في ٣٨ موضع (٢١٪ من كل مراجع الألوان) كأيقونة ونص ورابط
  /// وخلفية وحد وحلقة تركيز — فبطّل يعلّم أي حاجة.
  static const Color accent = AppColors.greenColor500;

  /// حالة الضغط. `greenColor500` كان أغمق أخضر في السلّم فمكانش فيه لون
  /// للضغط، و`400` أفتح فبيقرا hover مش press.
  static const Color accentPressed = AppColors.greenColor600;

  static const Color accentSoft = AppColors.greenColor505;

  // ── الحالات ──────────────────────────────────────────────────────────

  static const Color danger = AppColors.errorColor100;
  static const Color dangerSoft = AppColors.errorColor0;
  static const Color dangerBorder = AppColors.errorColor50;

  static const Color warning = AppColors.warningColor200;
  static const Color warningSoft = AppColors.warningColor0;

  static const Color positive = AppColors.successColor200;
  static const Color positiveSoft = AppColors.successColor0;

  static const Color info = AppColors.blueColor200;
  static const Color infoSoft = AppColors.blueColor0;

  // ── الـ skeleton ─────────────────────────────────────────────────────

  /// الأساس والإضاءة. القديم كان `#F6F8FA` → `#F8F9FB` — فرق قيمتين،
  /// يعني الـ shimmer تقريبًا مش باين.
  static const Color skeletonBase = AppColors.greyColor50;
  static const Color skeletonHighlight = AppColors.whiteColor;

  /// طبقة التعتيم فوق الصور.
  static Color get scrim => AppColors.greyColor900.withValues(alpha: .45);
  static Color get scrimSoft => AppColors.greyColor900.withValues(alpha: .25);
}
