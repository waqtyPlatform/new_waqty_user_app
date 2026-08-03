/// تنسيق الأرقام والتواريخ والفلوس للسوق المصري.
///
/// بنكتب أسماء الأيام والشهور بإيدينا بدل ما نعتمد على `intl` بلوكال عربي،
/// لأن ده كان محتاج `initializeDateFormatting` والأبلكيشن مش بيناديها ولا مرة
/// و `Intl.defaultLocale` مش متظبطة — فكل التواريخ كانت بتطلع إنجليزي.
/// الطريقة دي مضمونة ومفيهاش إعداد.
class AppFormat {
  AppFormat._();

  static const List<String> _months = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// الترتيب من الاثنين (weekday = 1) لحد الأحد (weekday = 7).
  static const List<String> _days = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> _shortDays = <String>[
    'إثن',
    'ثلا',
    'أرب',
    'خم',
    'جم',
    'سبت',
    'أحد',
  ];

  /// **الأرقام غربية (1234) — مش عربية هندية (١٢٣٤).**
  ///
  /// الدالة دي كانت بتحوّل لعربي هندي، وبقت بتسيب الرقم زي ما هو.
  ///
  /// ## ليه
  ///
  /// السوق المصري بيقرا الاتنين، بس **واجهات الموبايل في مصر غربية**:
  /// طلبات، فودافون، إنستاباي، فوري، أوبر — كلهم أرقام غربية للأسعار
  /// والمواعيد. العربي الهندي عايش في المطبوعات والمستندات الرسمية أكتر
  /// من الشاشات.
  ///
  /// وفيه سبب تاني عملي: الأسعار والمواعيد بتتقارن بالعين بسرعة
  /// («٦:٤٥ ولا 6:45؟»)، والعميل المصري متعوّد على شكل الأرقام الغربية
  /// في السياق ده تحديدًا. الاتساق مع باقي التليفون أهم من الاتساق مع
  /// اللغة.
  ///
  /// **الدالة بتفضل موجودة** مش بتتشال: هي البوابة الوحيدة اللي كل رقم
  /// معروض بيعدّي عليها، فلو القرار اتغيّر بكرة بيتغيّر من هنا بس.
  static String digits(Object value) => value.toString();

  /// «٢٥٠ ج.م» — الرقم الأول والعملة بعده.
  ///
  /// العملة جاية من هنا بس، عشان ما تتكتبش hardcoded في أي widget.
  static String money(num amount) {
    final rounded = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '${digits(rounded)} ج.م';
  }

  /// «٦:٠٠ م» — نظام ١٢ ساعة بـ ص/م.
  static String time(DateTime dt) {
    final isPm = dt.hour >= 12;
    var hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${digits(hour)}:${digits(minute)} ${isPm ? 'م' : 'ص'}';
  }

  /// «٦:٠٠ م – ٦:٤٥ م»
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  /// «الخميس»
  static String dayName(DateTime dt) => _days[dt.weekday - 1];

  /// «خم» — للشريط الأفقي بتاع التواريخ.
  static String shortDayName(DateTime dt) => _shortDays[dt.weekday - 1];

  /// «أغسطس»
  static String monthName(DateTime dt) => _months[dt.month - 1];

  /// «أغسطس ٢٠٢٦»
  static String monthYear(DateTime dt) => '${monthName(dt)} ${digits(dt.year)}';

  /// «الخميس ١٣ أغسطس»
  static String fullDate(DateTime dt) =>
      '${dayName(dt)} ${digits(dt.day)} ${monthName(dt)}';

  /// «النهاردة» / «بكرة» / «الخميس ١٣ أغسطس»
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'النهاردة';
    if (diff == 1) return 'بكرة';
    if (diff == -1) return 'إمبارح';
    return fullDate(dt);
  }

  /// «النهاردة ٤:٣٠ م»
  static String relativeDateTime(DateTime dt) =>
      '${relativeDate(dt)} ${time(dt)}';

  /// «٤٥ دقيقة» / «ساعة ونص»
  static String duration(int minutes) {
    if (minutes < 60) return '${digits(minutes)} دقيقة';

    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    final hoursLabel = switch (hours) {
      1 => 'ساعة',
      2 => 'ساعتين',
      _ => '${digits(hours)} ساعات',
    };

    if (rest == 0) return hoursLabel;
    if (rest == 30) return '$hoursLabel ونص';
    return '$hoursLabel و${digits(rest)} دقيقة';
  }

  /// «١٫٢ كم»
  static String distance(double km) =>
      '${digits(km.toStringAsFixed(1))} كم';

  /// «2026-07-28T18:00:00+02:00» — الصيغة اللي السيرفر بيقبلها في
  /// `visits.*.items.*.start_at` (`Y-m-d\TH:i:sP` في Laravel).
  ///
  /// مش `toIso8601String()`: دي بتطلع `...T18:00:00.000` من غير offset
  /// للتوقيت المحلي، والسيرفر بيرفضها بـ 422.
  ///
  /// **دي fallback للـ mock بس.** لما الـ API يترتبط، النص الخام الراجع
  /// من السيرفر بيتحفظ في `SlotUiModel.startAtRaw` وبيتبعت زي ما هو —
  /// إعادة التنسيق بتخاطر بإزاحة في المنطقة الزمنية.
  static String serverDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');

    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absolute = offset.abs();

    return '${dt.year}-${two(dt.month)}-${two(dt.day)}'
        'T${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}'
        '$sign${two(absolute.inHours)}:${two(absolute.inMinutes % 60)}';
  }
}
