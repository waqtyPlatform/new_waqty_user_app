import 'package:waqty_user_application/core/utils/app_format.dart';

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

  /// نص الـ `start_at` **الخام** زي ما رجع من السيرفر.
  ///
  /// السيرفر بيرجّع الميعاد بصيغة ISO 8601 كاملة بالـ offset، والـ
  /// `StoreBookingRequest` بيقبل نفس الصيغة بالظبط في
  /// `visits.*.items.*.start_at`. فبنمرّره زي ما هو بدل ما نفكّه لـ
  /// [DateTime] ونعيد بناءه — إعادة البناء بتخاطر بإزاحة في المنطقة
  /// الزمنية بين توقيت الفرع وتوقيت جهاز العميل.
  ///
  /// `null` في الـ mock بس، وساعتها [startAtPayload] بيولّده.
  final String? startAtRaw;

  const SlotUiModel({
    required this.startAt,
    required this.endAt,
    required this.price,
    this.employeeName = '',
    this.startAtRaw,
  });

  /// القيمة اللي بتتحط في الـ payload.
  String get startAtPayload => startAtRaw ?? AppFormat.serverDateTime(startAt);

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
