import 'package:flutter/animation.dart';

/// مدد ومنحنيات الحركة.
///
/// الـ ٦ شاشات الجديدة كان فيها **حركة واحدة** (الـ stepper) — وكمان من غير
/// `curve`، يعني خطية، وعشان كده بتحس ميكانيكية.
///
/// كل تغييرات الحالة (شيب مختار، يوم مختار، تبويب) كانت تبديل لون فوري.
class AppMotion {
  AppMotion._();

  /// أيقونة بتظهر · علامة صح
  static const Duration fast = Duration(milliseconds: 150);

  /// الافتراضي — أي تغيير حالة
  static const Duration base = Duration(milliseconds: 220);

  /// فتح/قفل · تلاشي بين حالتين
  static const Duration slow = Duration(milliseconds: 300);

  /// دخول أول مرة (اللوجو)
  static const Duration entrance = Duration(milliseconds: 400);

  /// المنحنى الافتراضي — بيبدأ بسرعة ويهدى، وده اللي بيحس طبيعي.
  static const Curve standard = Curves.easeOutCubic;

  /// نطّة صغيرة — للعناصر اللي بتتحدد بس، مش لأي حاجة.
  static const Curve emphasis = Curves.easeOutBack;

  static const Curve exit = Curves.easeInCubic;
}
