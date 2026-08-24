import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';

/// زيارة واحدة جوه حجز — ده `booking_visits` في السيرفر.
///
/// ## ليه الحالة هنا مش على الحجز بس
///
/// السيرفر بيخزّن `status` على **التلاتة**: `bookings` و`booking_visits`
/// و`booking_items`. والداشبورد بقى بيحرّك الزيارة لوحدها — زرار «وصل»
/// بينادي `BookingExecutionService::checkInVisit($visitUuid)` وبيكتب
/// `arrived_at` على **صف الزيارة**.
///
/// الأبلكيشن كان بيقرا حالة الحجز الأب بس. الفرق مالوش أثر في حجز بزيارة
/// واحدة، وبيكسر في حجز بزيارتين: صبغة ١١ص وسشوار ٧م حجز واحد. الفرع
/// بيعمل check-in الساعة ١١، حالة الحجز بتبقى `arrived`، والأبلكيشن
/// بيعرض «إنت في الفرع» **من الصبح لحد بالليل** — بما فيهم الست ساعات
/// اللي العميل يكون فيهم في بيته بين الزيارتين.
class BookingVisitUiModel {
  /// `booking_visits.uuid` في السيرفر.
  final String uuid;

  /// حالة الزيارة دي لوحدها.
  ///
  /// في حجز بزيارة واحدة بتساوي حالة الحجز دايمًا. في حجز بزيارتين ممكن
  /// تختلف: زيارة ١ `completed` وزيارة ٢ `confirmed`.
  final BookingStatus status;

  /// خدمات الزيارة دي، مرتّبة زمنيًا.
  final List<BookingItemUiModel> items;

  const BookingVisitUiModel({
    required this.uuid,
    required this.status,
    required this.items,
  }) : assert(items.length > 0, 'الزيارة لازم يكون فيها خدمة واحدة على الأقل');

  /// عنصر من `visits[]` في `GET /api/user/bookings/{uuid}`:
  ///
  /// ```json
  /// {"uuid":"01K…","status":"confirmed","items":[{…}]}
  /// ```
  ///
  /// ⚠ **`booking_visits.status` عمود حقيقي مستقل عن حالة الحجز الأب** —
  /// الداشبورد بيحرّكه لوحده (زيارة اتعملت وزيارة لسه). الافتراضي
  /// `confirmed` عشان الليستة اللي مابتحمّلش `visits` ماتقعش.
  factory BookingVisitUiModel.fromJson(Map<String, dynamic> json) =>
      BookingVisitUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        status: BookingStatusLabel.fromApi(
          JsonParse.stringValue(json['status'], fallback: 'confirmed'),
        ),
        items: JsonParse.mapListValue(
          json['items'],
        ).map(BookingItemUiModel.fromJson).toList(),
      );

  /// بداية أول خدمة في الزيارة.
  DateTime get startAt =>
      items.map((i) => i.startAt).reduce((a, b) => a.isBefore(b) ? a : b);

  /// نهاية آخر خدمة في الزيارة.
  DateTime get endAt =>
      items.map((i) => i.endAt).reduce((a, b) => a.isAfter(b) ? a : b);

  /// مجموع مدد خدمات الزيارة.
  int get durationMinutes =>
      items.fold<int>(0, (sum, i) => sum + i.durationMinutes);

  double get price => items.fold<double>(0, (sum, i) => sum + i.price);

  /// الوقت ده واقع جوه شباك الزيارة؟
  ///
  /// **البداية داخلة والنهاية بره** — عشان زيارتين متلاصقتين (واحدة
  /// بتخلص ٣:٠٠ والتانية بتبدأ ٣:٠٠) مايتطابقوش الاتنين على نفس اللحظة.
  bool containsTime(DateTime now) =>
      !now.isBefore(startAt) && now.isBefore(endAt);

  /// الزيارة خلصت — بأي نهاية من التلاتة.
  ///
  /// الفرق بين دي و`status.isUpcoming`: الملغية واللي ما حضرش **مش**
  /// قدام العميل، بس برضه مش «مكتملة». الاختيار بتاع الزيارة الحالية
  /// محتاج يعدّي على التلاتة.
  bool get isFinished =>
      status == BookingStatus.completed ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.noShow;
}
