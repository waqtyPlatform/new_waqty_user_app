/// خدمة واحدة جوه حجز.
///
/// ده الـ `booking_items` بتاع السيرفر. الحجز الواحد ممكن يشيل لحد ٥٠
/// خدمة موزّعين على لحد ٢٠ زيارة، وكل خدمة ليها **أخصائي وميعاد
/// مستقلين** — مش بس اسم في سطر.
///
/// السعر هنا للخدمة دي لوحدها. إجمالي الحجز = مجموع العناصر، وبيتحسب
/// في [BookingUiModel] مش متخزّن مرتين.
class BookingItemUiModel {
  /// الزيارة اللي العنصر ده تابع ليها — `booking_visits.uuid` في السيرفر.
  ///
  /// **مش مشتق من التاريخ.** الرحلة الواحدة يوم واحد، بس اليوم الواحد
  /// ممكن يكون رحلتين (صبغة الصبح وحمام كريم بالليل) — والسيرفر بيخزّنهم
  /// زيارتين فعلاً. لو اشتققنا التجميع باليوم هنا، الحجز ده هيتعرض
  /// كزيارة واحدة مع إنه اتحجز زيارتين.
  final String visitUuid;

  final String serviceName;

  /// الأخصائي **بعد** ما السيرفر يحدده. لو العميل اختار «أي أخصائي
  /// متاح» بيبقى ده اللي اتوزّع عليه فعلاً، مش النص العام.
  final String employeeName;

  final DateTime startAt;
  final DateTime endAt;
  final double price;

  const BookingItemUiModel({
    required this.visitUuid,
    required this.serviceName,
    required this.employeeName,
    required this.startAt,
    required this.endAt,
    required this.price,
  });

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  /// اليوم من غير ساعة — مفتاح تجميع العناصر في زيارات.
  DateTime get day => DateTime(startAt.year, startAt.month, startAt.day);
}
