import 'package:flutter/widgets.dart';

import 'app_semantic_colors.dart';

/// الظلال — **أربعة، وكل واحد طبقتين**.
///
/// employee-app فيه **٧٠ `BoxShadow` inline**، وتوزيع الـ blur بيقول إن
/// فيه تلات مستويات حقيقية: 4 (×٢٩) · 2 (×١٣) · 16 (×١٣) · 3 (×٨).
///
/// وفيه ديكوريشن واحد بس قابل لإعادة الاستخدام —
/// `features/money/shared/widgets/my_earning_card_decoration.dart`، ٢٧
/// استخدام — ومعاه **نسختين خاصتين شبهه** في
/// `biometric_settings_screen.dart:659` و`change_pin_info_card_widget.dart:63`.
/// الطبقة الأولى من [raised] هي الديكوريشن ده حرفيًا.
///
/// ⚠ الديكوريشن ده كان شايل كمان حد (`greyColor100` بألفا `.2` وعرض `.8`).
/// تباين الحد ده على الأبيض **1.02:1** — يعني مش موجود بصريًا. الطبقة
/// الملامسة بتقوم بدوره بالكامل، فاتشال.
///
/// ## ليه طبقتين
///
/// طبقة **ملامسة** ضيقة بتقول «الحاجة دي قاعدة على حاجة»، وطبقة **محيطة**
/// واسعة بـ spread سالب بتقول «قد إيه مرفوعة». الظل الواحد بيضطر يختار
/// بين الاتنين فبيطلع إما قذر أو مش موجود.
class AppShadows {
  AppShadows._();

  static Color get _ink => AppSemanticColors.palette.shadowInk;

  /// الألفا مضروبة في معامل الوضع.
  ///
  /// في الغامق الظل تقريبًا مش باين، والألفا العالية بتعمل **هالة سودا**
  /// حوالين الكروت بدل ما ترفعها.
  static double _a(double alpha) =>
      alpha * AppSemanticColors.palette.shadowScale;

  /// الكارت العادي — الافتراضي لأي سطح مرفوع.
  static List<BoxShadow> get raised => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.04)),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// حاجة طايفة فوق المحتوى — sheet، dropdown، كارت مضغوط.
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.10)),
      offset: const Offset(0, 16),
      blurRadius: 28,
      spreadRadius: -6,
    ),
  ];

  /// فوتر ملزوق تحت — الظل بيطلع **لفوق** ناحية المحتوى اللي بيغطيه.
  static List<BoxShadow> get floatingUp => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: const Offset(0, -1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.08)),
      offset: const Offset(0, -8),
      blurRadius: 24,
      spreadRadius: -6,
    ),
  ];

  /// هالة خضرا تحت الزرار الأساسي.
  ///
  /// ⚠ **بيتخطى [_a] عن قصد.** في الوضع الغامق الظل الأسود مش بيقول حاجة،
  /// واللي بيقول إن الزرار مرفوع هو **الهالة الخضرا نفسها** — فلازم تتقوّى
  /// هناك مش تخف.
  static List<BoxShadow> get accent => [
    BoxShadow(
      color: AppSemanticColors.accent.withValues(
        alpha: AppSemanticColors.isDark ? .28 : .20,
      ),
      offset: const Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];
}
