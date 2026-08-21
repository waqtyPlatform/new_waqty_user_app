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

  /// الإزاحة في آخر نص ISO — `Z` أو `+03:00` أو `-0500`.
  ///
  /// مابتمسكش `2026-08-10`: الشكل ده آخره `-10`، رقمين بعد الإشارة،
  /// والنمط عايز أربعة.
  static final RegExp _trailingOffset = RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$');

  /// تاريخ من نص ISO 8601 — **بساعة الفرع زي ما وصلت**.
  ///
  /// توقيت الفرع هو المرجع: الصالون بيقول «ميعادك ٦» ويقصد ٦ عنده. لو
  /// حوّلنا لتوقيت الجهاز، عميل مسافر أو جهازه على منطقة غلط هيشوف
  /// ميعاد تاني لنفس الحجز.
  ///
  /// ## `DateTime.parse` لوحدها مكانتش بتعمل ده
  ///
  /// النية دي كانت مكتوبة هنا من الأول، بس الكود مكانش بيحققها.
  /// `DateTime.parse('2026-08-10T18:00:00+03:00')` بترجّع **UTC** —
  /// `hour` بتساوي **١٥** و`isUtc` بتساوي `true`. و`AppFormat.time`
  /// بتقرا `.hour` على طول، فالعميل كان هيشوف **٣:٠٠ م** لميعاد الساعة
  /// **٦:٠٠ م**.
  ///
  /// يعني القديم مكانش بيعرض ساعة الفرع ولا ساعة الجهاز — كان بيعرض
  /// **UTC**. ومخفي دلوقتي لأن الـ mock بيبني `DateTime` محلي، فالباج
  /// كان هيطلع أول يوم الربط على كل تاريخ في الأبلكيشن.
  ///
  /// الحل: نشيل الإزاحة ونقرا ساعة الحائط كما هي. `+03:00` بتتشال
  /// فتبقى `18:00` محلية — نفس الرقم اللي في الرد، وهو نفس الرقم اللي
  /// الريسيبشن شايفه على الداشبورد.
  ///
  /// ⚠ **`Z` بتتعامل زي أي إزاحة.** السيرفر بيبعت `toIso8601String()`
  /// على وقت بمنطقة التطبيق، يعني `+03:00` مش `Z`. لو ابتدى يبعت `Z`
  /// فعلاً، الرد مابيحملش إزاحة الفرع أصلاً والقرار ده بيحتاج مراجعة.
  static DateTime? dateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      final raw = value.trim();
      // الاحتياطي بيمسك الأشكال اللي شيل الإزاحة بيخليها غير صالحة.
      return DateTime.tryParse(raw.replaceFirst(_trailingOffset, '')) ??
          DateTime.tryParse(raw);
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

  /// ⚠ **الاسم بيوصل بشكلين مختلفين حسب الـendpoint.**
  ///
  /// متحقّق منه بنداء حقيقي:
  ///
  /// | الـendpoint | `name` |
  /// |---|---|
  /// | `GET /api/public/services` | `"كشف باطنة"` — نص |
  /// | `GET /api/user/bookings` | `{"ar": "غيار جرح", "en": "Wound Dressing"}` |
  ///
  /// الفرق إن الموارد العامة بتعدّي على `detect.language` وبترجّع اللغة
  /// المطلوبة، والـsnapshot المتخزّن في الحجز بيحتفظ بالترجمتين. الشاشة
  /// عايزة نص واحد في الحالتين.
  ///
  /// [locale] بتحدد الأولوية، والاحتياطي أول قيمة موجودة — أحسن من فراغ.
  static String localizedValue(
    dynamic value, {
    String locale = 'ar',
    String fallback = '',
  }) {
    if (value is String) return value;

    if (value is Map) {
      final preferred = value[locale];
      if (preferred is String && preferred.isNotEmpty) return preferred;

      for (final entry in value.values) {
        if (entry is String && entry.isNotEmpty) return entry;
      }
    }

    return fallback;
  }
}
