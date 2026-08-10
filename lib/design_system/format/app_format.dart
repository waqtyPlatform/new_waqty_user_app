/// تنسيق العرض — **الملف الوحيد في الكيت اللي فيه قرارات سوق**.
///
/// كل حاجة تانية في `design_system/` مالهاش علاقة بمصر ولا بالعربي: ألوان
/// وأشكال ومسافات. الملف ده هو الاستثناء، وهو مقصود ومحصور:
///
/// | القرار | القيمة | فين بيتغيّر |
/// |---|---|---|
/// | العملة | `ج.م` | [money] |
/// | الأرقام | غربية `1234` | [digits] |
/// | أسماء الأيام والشهور | عربي مكتوب بالإيد | [_days] · [_months] |
/// | صيغة الوقت | ١٢ ساعة بـ`ص`/`م` | [time] |
/// | التاريخ النسبي | «النهاردة» · «بكرة» | [relativeDate] |
///
/// **متبنّي في سوق تاني بيستبدل الملف ده وبس.**
///
/// ## ⚠ ليه مافيش `intl`
///
/// `intl` بيطلّع التواريخ **إنجليزي** لو `initializeDateFormatting` ما
/// اتنادتش، و`DateFormat` من غير locale بيرجع لـ`Intl.defaultLocale`
/// اللي غالبًا مش متظبط. employee-app واقع في ده بالظبط:
/// `AppConstant.formatDateString` بيرجّع `"Today"` و`"Yesterday"`
/// **إنجليزي متحطوط** في تطبيق عربي، والأسماء مش بتعدّي على `.tr()`.
///
/// الأسماء هنا مكتوبة بالإيد فمفيش حاجة تتهيّأ ومفيش حاجة تتنسى.
class AppFormat {
  AppFormat._();

  static const List<String> _months = [
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

  /// مفهرسة بـ `weekday - 1` — الاتنين أول اليوم في `DateTime`.
  static const List<String> _days = [
    'الاتنين',
    'التلات',
    'الأربع',
    'الخميس',
    'الجمعة',
    'السبت',
    'الحد',
  ];

  static const List<String> _shortDays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];

  static const String currency = 'ج.م';

  /// **البوابة اللي كل رقم معروض بيعدّي منها.**
  ///
  /// دلوقتي بتعدّي الرقم زي ما هو: السوق المصري بيستخدم الأرقام الغربية
  /// في الواجهات. الدالة موجودة عشان القرار ده **يترجع في مكان واحد** لو
  /// اتغيّر، بدل ما يتحوّل لبحث في مية موضع.
  static String digits(Object value) => value.toString();

  /// `250 ج.م` · `250.50 ج.م`
  ///
  /// ⚠ **المكان الوحيد اللي اسم العملة متكتوب فيه.** أي widget بيكتب
  /// عملة بإيده بيكسّر القاعدة دي.
  static String money(num value, {bool withCurrency = true}) {
    final rounded = (value * 100).round() / 100;
    final text = rounded == rounded.roundToDouble()
        ? digits(rounded.toInt())
        : digits(rounded.toStringAsFixed(2));
    return withCurrency ? '$text $currency' : text;
  }

  /// `3:45 م`
  static String time(DateTime value) {
    final hour24 = value.hour;
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final marker = hour24 < 12 ? 'ص' : 'م';
    return '${digits(hour)}:${digits(minute)} $marker';
  }

  /// `3:45 م – 4:30 م`
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  static String dayName(DateTime value) => _days[value.weekday - 1];

  static String shortDayName(DateTime value) => _shortDays[value.weekday - 1];

  static String monthName(DateTime value) => _months[value.month - 1];

  /// `أكتوبر 2026`
  static String monthYear(DateTime value) =>
      '${monthName(value)} ${digits(value.year)}';

  /// `12 أكتوبر 2026`
  static String fullDate(DateTime value) =>
      '${digits(value.day)} ${monthName(value)} ${digits(value.year)}';

  /// «النهاردة» · «بكرة» · «إمبارح» · وإلا [fullDate].
  static String relativeDate(DateTime value, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(value);
    final diff = target.difference(today).inDays;

    return switch (diff) {
      0 => 'النهاردة',
      1 => 'بكرة',
      -1 => 'إمبارح',
      _ => fullDate(value),
    };
  }

  /// «النهاردة 3:45 م»
  static String relativeDateTime(DateTime value, {DateTime? now}) =>
      '${relativeDate(value, now: now)} ${time(value)}';

  /// المثنى والجمع العربي — `ساعة` · `ساعتين` · `3 ساعات` · `ساعة ونص`.
  ///
  /// ⚠ العربي فيه **مثنى**، والصيغة `1 ساعة / 2 ساعة` غلط نحوي بيقرا
  /// كأنه ترجمة آلية.
  static String duration(int minutes) {
    if (minutes < 60) return '${digits(minutes)} دقيقة';

    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    final half = rest == 30;

    final base = switch (hours) {
      1 => 'ساعة',
      2 => 'ساعتين',
      >= 3 && <= 10 => '${digits(hours)} ساعات',
      _ => '${digits(hours)} ساعة',
    };

    if (half) return '$base ونص';
    if (rest == 0) return base;
    return '$base و${digits(rest)} دقيقة';
  }

  /// `1.2 كم` · `800 م`
  static String distance(double km) {
    if (km < 1) return '${digits((km * 1000).round())} م';
    return '${digits(km.toStringAsFixed(1))} كم';
  }

  /// `2026-08-10T15:45:00+02:00`
  ///
  /// ⚠ **مش `toIso8601String()`.** دي بتطلّع الوقت من غير إزاحة منطقة
  /// زمنية، والباك إند بيرفضها.
  static String serverDateTime(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');

    final offset = value.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final zone = '$sign${two(abs.inHours)}:${two(abs.inMinutes % 60)}';

    return '${value.year}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:${two(value.second)}$zone';
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
