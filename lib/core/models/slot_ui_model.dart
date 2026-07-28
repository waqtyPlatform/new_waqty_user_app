/// موديل عرض للميعاد المتاح.
enum SlotPeriod { morning, afternoon, evening }

class SlotUiModel {
  /// «١٨:٠٠» بصيغة ٢٤ ساعة — ده اللي بيتبعت للسيرفر.
  /// الشكل اللي بيتعرض للعميل بيتولّد من [DateTime] في الـ formatter.
  final DateTime startAt;
  final DateTime endAt;
  final double price;

  /// اسم الأخصائي اللي هيتحدد لو العميل مختار «أي أخصائي متاح».
  final String employeeName;

  const SlotUiModel({
    required this.startAt,
    required this.endAt,
    required this.price,
    this.employeeName = '',
  });

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  SlotPeriod get period {
    if (startAt.hour < 12) return SlotPeriod.morning;
    if (startAt.hour < 17) return SlotPeriod.afternoon;
    return SlotPeriod.evening;
  }
}

extension SlotPeriodLabel on SlotPeriod {
  String get label => switch (this) {
    SlotPeriod.morning => 'صباحًا',
    SlotPeriod.afternoon => 'بعد الظهر',
    SlotPeriod.evening => 'مساءً',
  };
}
