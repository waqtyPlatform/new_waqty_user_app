import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

/// لون الكيان — محسوب من اسمه، ثابت للأبد.
///
/// **الأبلكيشن مالوش صور، والقرار ده مقصود وموثّق** في `mock_providers.dart`.
/// يعني الحرف البديل مش خطة بديلة — هو **الهوية البصرية** لكل محل في
/// الأبلكيشن. وعشان كده بيستاهل يتعامل كتصميم مش كـ fallback.
///
/// التباين طلع من ~4.5:1 لـ **7–9:1**: عند 4.5 الحرف بيقرا «لابل باهت»،
/// وعند 8 بيقرا «ده اللوجو».
///
/// ## ليه مجموع الأكواد مش `hashCode`
///
/// `String.hashCode` في Dart **مش مضمون يفضل ثابت** بين التشغيلات ولا بين
/// إصدارات الـ SDK. لو اتغيّر، كل محل في الأبلكيشن بيبدّل لونه فجأة.
/// مجموع الأكواد بيدّي نفس النتيجة دايمًا.
class AppEntityTint {
  AppEntityTint._();

  /// أرضية · أرضية أغمق (للغسلة الركنية) · حبر الحرف.
  static ({Color ground, Color groundDeep, Color ink}) of(String name) {
    final index = _indexOf(name);
    return (
      ground: _grounds[index],
      groundDeep: _groundsDeep[index],
      ink: _inks[index],
    );
  }

  static int _indexOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 0;
    var sum = 0;
    for (final unit in trimmed.codeUnits) {
      sum += unit;
    }
    return sum % _grounds.length;
  }

  // أربع عائلات هادية. التشبّع منخفض عشان ماتنافسش الأخضر، والإضاءة
  // متقاربة عشان الشبكة تقرا مجموعة واحدة مش قوس قزح.
  static const List<Color> _grounds = [
    Color(0xffE3EBF2), // أزرق مغبّر
    Color(0xffF0E8DC), // رملي
    Color(0xffE4EDE7), // أخضر مغبّر
    Color(0xffEBE5F0), // بنفسجي مغبّر
  ];

  static const List<Color> _groundsDeep = [
    Color(0xffD6E1EB),
    Color(0xffE6DCCB),
    Color(0xffD5E3DA),
    Color(0xffDFD6E7),
  ];

  static const List<Color> _inks = [
    Color(0xff33475B),
    Color(0xff5C4A32),
    Color(0xff2F4A3B),
    Color(0xff473A57),
  ];

  /// أول حرف صالح للعرض من الاسم.
  ///
  /// `substring(0, 1)` كان بياخد **أول وحدة UTF-16** — ممكن تطلع تطويل
  /// (ـ) أو علامة تشكيل أو نص زوج بديل. عند ١٨sp محدش بيلاحظ؛ عند ١٤٤px
  /// دي الشاشة كلها.
  static String? initialOf(String name) {
    for (final rune in name.trim().runes) {
      if (_isSkippable(rune)) continue;
      return String.fromCharCode(rune);
    }
    return null;
  }

  static bool _isSkippable(int rune) {
    // مسافات
    if (rune <= 0x20) return true;
    // تطويل
    if (rune == 0x0640) return true;
    // علامات التشكيل العربية
    if (rune >= 0x064B && rune <= 0x065F) return true;
    if (rune >= 0x0610 && rune <= 0x061A) return true;
    // علامات الاتجاه والتحكم غير المرئية
    if (rune >= 0x200B && rune <= 0x200F) return true;
    if (rune >= 0x202A && rune <= 0x202E) return true;
    return false;
  }
}
