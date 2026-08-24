import 'package:flutter/animation.dart';

/// المدد والمنحنيات.
///
/// الملف ده **استيراد صافي من user-app** — employee-app مالوش motion tokens
/// نبقى أمناء ليها. كل حركة فيه مكتوبة بالإيد عند موضعها.
class AppMotion {
  AppMotion._();

  /// تغيّر حالة صغير: شيب اتضغط، توجل اتقلب.
  static const Duration fast = Duration(milliseconds: 150);

  /// الافتراضي — أي انتقال حالة عادي.
  static const Duration base = Duration(milliseconds: 220);

  /// حاجة بتتفتح أو بتتقفل: sheet، accordion.
  static const Duration slow = Duration(milliseconds: 300);

  /// ظهور عنصر لأول مرة على الشاشة.
  static const Duration entrance = Duration(milliseconds: 400);

  /// الافتراضي — بيبدأ بسرعة وبيهدى. الحركة الطبيعية للواجهات.
  static const Curve standard = Curves.easeOutCubic;

  /// بيعدّي الهدف شوية وبيرجع — للحاجة اللي عايزين العين تمسكها.
  static const Curve emphasis = Curves.easeOutBack;

  /// للخروج بس. الخروج المفروض يبقى أسرع من الدخول.
  static const Curve exit = Curves.easeInCubic;
}
