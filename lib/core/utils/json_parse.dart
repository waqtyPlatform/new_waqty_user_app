/// أدوات قراءة الـ JSON الجاي من السيرفر.
///
/// ## ليه ملف كامل لحاجة زي دي
///
/// السيرفر **مش بيبعت أنواع نضيفة**. `bookings.price` عمود `decimal(10,2)`
/// وLaravel بيعمله cast بـ `decimal:2`، يعني بيوصل نص `"150.00"` مش رقم.
/// و`json['price'] as double` على نص بيرمي `TypeError` — على شاشة ليستة
/// الحجوزات، أول شاشة أي حد بيفتحها.
///
/// والمفاتيح كلها `snake_case` (`effective_price`، `available_employees_count`)
/// لأن `ApiResponse` مابيعملش أي تحويل للأسماء.
///
/// فبدل ما كل موديل يحاول يتعامل مع ده لوحده، الدوال دي بتقبل الرقم
/// كنص أو كرقم، والتاريخ كنص ISO، وبترجّع قيمة آمنة بدل ما ترمي.
library;

class JsonParse {
  JsonParse._();

  /// رقم عشري من `double` أو `int` أو نص زي `"150.00"`.
  static double? doubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static double doubleValue(dynamic value, {double fallback = 0}) =>
      doubleOrNull(value) ?? fallback;

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final trimmed = value.trim();
      return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round();
    }
    return null;
  }

  static int intValue(dynamic value, {int fallback = 0}) =>
      intOrNull(value) ?? fallback;

  static String stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static bool boolValue(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return fallback;
  }

  /// تاريخ من نص ISO 8601.
  ///
  /// **بيرجّع الوقت زي ما وصل من غير تحويل لتوقيت الجهاز.** توقيت الفرع
  /// هو المرجع — لو حوّلنا للمحلي، عميل مسافر أو جهازه على منطقة غلط
  /// هيشوف مواعيد غلط. اللي بيتعرض هو ساعة الفرع.
  static DateTime? dateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static DateTime dateValue(dynamic value, {DateTime? fallback}) =>
      dateOrNull(value) ?? fallback ?? DateTime.now();

  /// خريطة جوّة خريطة — بترجّع فاضية بدل `null` عشان الاستدعاء يفضل بسيط.
  static Map<String, dynamic> mapValue(dynamic value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  /// ليستة خرايط — بتتجاهل أي عنصر مش خريطة بدل ما ترمي على كل الرد.
  static List<Map<String, dynamic>> mapListValue(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}
