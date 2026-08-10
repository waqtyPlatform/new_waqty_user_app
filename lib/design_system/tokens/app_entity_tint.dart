import 'package:flutter/widgets.dart';

import 'app_semantic_colors.dart';

/// لون الكيان — **الحرف هو الهوية**.
///
/// الأبلكيشنين مافيهمش ولا صورة فوتوغرافية، فالبديل مش «مربع رمادي فيه
/// حرف» — البديل **لون ثابت لكل اسم**. نفس المحل بياخد نفس اللون في كل
/// شاشة، فالعين بتتعرّف عليه قبل ما تقرا.
class AppEntityTint {
  AppEntityTint._();

  /// الأرضية والحبر لاسم معيّن.
  ///
  /// ⚠ **الفهرسة `sum(codeUnits)` مش `String.hashCode`.** الـ `hashCode`
  /// بتاع النصوص في Dart **مش مستقر بين إصدارات الـ SDK** ولا بين
  /// الـ runs في بعض الإعدادات — يعني المحل ممكن يغيّر لونه بعد ترقية.
  static ({Color ground, Color ink}) of(String name) {
    final grounds = AppSemanticColors.palette.entityGrounds;
    final inks = AppSemanticColors.palette.entityInks;
    if (grounds.isEmpty) {
      return (
        ground: AppSemanticColors.surfaceSunken,
        ink: AppSemanticColors.textSecondary,
      );
    }

    var sum = 0;
    for (final unit in name.codeUnits) {
      sum += unit;
    }
    final index = sum % grounds.length;
    return (ground: grounds[index], ink: inks[index]);
  }

  /// الحرف اللي بيتعرض.
  ///
  /// ⚠ بيمشي على [String.runes] وبيتخطى **التطويل والتشكيل ومحارف
  /// التحكّم في الاتجاه**. «الـﻣـﺤـﻞ» بتطويل بتدي `ـ` لو أخدنا أول حرف
  /// على عماه، و«‏محل» بمحرف bidi بتدي محرف مش مرئي.
  static String initialOf(String name) {
    for (final rune in name.runes) {
      // تطويل
      if (rune == 0x0640) continue;
      // تشكيل عربي
      if (rune >= 0x064B && rune <= 0x065F) continue;
      if (rune == 0x0670) continue;
      // محارف اتجاه ومسافات صفرية
      if (rune >= 0x200B && rune <= 0x200F) continue;
      if (rune >= 0x202A && rune <= 0x202E) continue;
      if (rune == 0x20) continue;

      return String.fromCharCode(rune);
    }
    return '؟';
  }
}
