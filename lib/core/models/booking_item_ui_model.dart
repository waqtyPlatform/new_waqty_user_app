import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة تقييم خدمة واحدة.
///
/// **`pending` مش تفصيلة إدارية.** السيرفر بيعمل التقييم
/// `status: 'pending', active: false` (`BookingRatingService`) وبيفضل
/// **مخفي** لحد ما حد يراجعه. من غير الحالة دي، العميل بيقيّم وبيشوف
/// لا شيء ويستنتج إن التقييم ما اتسجّلش، فيقيّم تاني.
enum RatingStatus { none, pending, published }

extension RatingStatusLabel on RatingStatus {
  String get label => switch (this) {
    RatingStatus.none => '',
    RatingStatus.pending => 'قيد المراجعة',
    RatingStatus.published => 'تم النشر',
  };

  bool get canRate => this == RatingStatus.none;

  static RatingStatus fromApi(String? value) => switch (value) {
    'published' => RatingStatus.published,
    'pending' || 'reported' || 'hidden' || 'rejected' => RatingStatus.pending,
    _ => RatingStatus.none,
  };
}

/// خدمة واحدة جوه حجز.
///
/// ده الـ `booking_items` بتاع السيرفر. الحجز الواحد ممكن يشيل لحد ٥٠
/// خدمة موزّعين على لحد ٢٠ زيارة، وكل خدمة ليها **أخصائي وميعاد
/// مستقلين** — مش بس اسم في سطر.
///
/// السعر هنا للخدمة دي لوحدها. إجمالي الحجز = مجموع العناصر، وبيتحسب
/// في [BookingUiModel] مش متخزّن مرتين.
class BookingItemUiModel {
  /// `booking_items.uuid` — **مفتاح التقييم**.
  ///
  /// التقييمات مربوطة بـ `booking_item_id` بـ unique constraint، والقديم
  /// `ratings_booking_id_unique` **اتشال** بالفعل من السيرفر. يعني حجز
  /// بتلات خدمات = تلات تقييمات مستقلة، وكل واحد محتاج مفتاحه.
  final String uuid;

  /// الزيارة اللي العنصر ده تابع ليها — `booking_visits.uuid` في السيرفر.
  ///
  /// **مش مشتق من التاريخ.** الرحلة الواحدة يوم واحد، بس اليوم الواحد
  /// ممكن يكون رحلتين (صبغة الصبح وحمام كريم بالليل) — والسيرفر بيخزّنهم
  /// زيارتين فعلاً. لو اشتققنا التجميع باليوم هنا، الحجز ده هيتعرض
  /// كزيارة واحدة مع إنه اتحجز زيارتين.
  final String visitUuid;

  /// بيخلي «احجز نفس الخدمة تاني» ممكن من غير دوران بالاسم.
  final String serviceUuid;

  final String serviceName;

  /// الأخصائي **بعد** ما السيرفر يحدده. لو العميل اختار «أي أخصائي
  /// متاح» بيبقى ده اللي اتوزّع عليه فعلاً، مش النص العام.
  final String employeeName;

  final DateTime startAt;
  final DateTime endAt;
  final double price;

  /// السعر قبل خصم مجموعة العميل — `null` يعني مفيش خصم.
  ///
  /// السيرفر **بيحسبه وبيخزّنه** (`original_price` على `booking_items`
  /// من `CustomerGroupPricingService`) بس **مابيكشفهوش في أي resource**.
  /// من غيره العميل بيشوف رقم أقل من اللي في القايمة من غير أي تفسير.
  final double? originalPrice;

  /// التقييم اللي العميل اداه للخدمة دي. `null` = لسه ما قيّمش.
  ///
  /// **مش final** — العميل بيقيّم والشاشة لازم تعكس ده على طول من غير
  /// ما نعيد تحميل الحجز كله.
  int? rating;

  RatingStatus ratingStatus;

  /// اللي العميل كتبه مع النجوم. فاضي = ماكتبش حاجة.
  ///
  /// **مش final** لنفس سبب [rating].
  ///
  /// ⚠ **مواصفة الـ endpoint دلوقتي بتاخد `booking_item_id` والنجوم بس.**
  /// إضافة الحقل ده للعقد **طلب للباك إند مش عائق** — الحقل بيتكتب محليًا
  /// وبيتعرض، وبيتقرا من الرد لو السيرفر بعته. اللي مكانش ينفع يفضل هو إن
  /// الأبلكيشن **يسأل العميل يكتب** وبعدين يرمي اللي كتبه.
  String ratingComment;

  BookingItemUiModel({
    required this.uuid,
    required this.visitUuid,
    required this.serviceUuid,
    required this.serviceName,
    required this.employeeName,
    required this.startAt,
    required this.endAt,
    required this.price,
    this.originalPrice,
    this.rating,
    this.ratingStatus = RatingStatus.none,
    this.ratingComment = '',
  });

  /// من رد `GET /api/user/bookings/{uuid}` — عنصر جوه `visits[].items[]`.
  factory BookingItemUiModel.fromJson(Map<String, dynamic> json) {
    final start = JsonParse.dateValue(json['start_at']);
    final rating = JsonParse.mapValue(json['rating']);

    return BookingItemUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      visitUuid: JsonParse.stringValue(json['visit_uuid']),
      serviceUuid: JsonParse.stringValue(
        JsonParse.mapValue(json['service'])['uuid'] ?? json['service_uuid'],
      ),
      serviceName: JsonParse.stringValue(
        JsonParse.mapValue(json['service'])['name'] ?? json['service_name'],
      ),
      employeeName: JsonParse.stringValue(
        JsonParse.mapValue(json['employee'])['name'] ?? json['employee_name'],
      ),
      startAt: start,
      // مدة الخدمة أدق من `end_at` لو السيرفر ما بعتهاش — العنصر بيحمل
      // `duration_minutes` دايمًا، و`end_at` ساعات بتبقى محسوبة.
      endAt:
          JsonParse.dateOrNull(json['end_at']) ??
          start.add(
            Duration(minutes: JsonParse.intValue(json['duration_minutes'])),
          ),
      // `booked_price` هو الاسم في `booking_items`، و`price` في الحجز الأب.
      price: JsonParse.doubleValue(json['booked_price'] ?? json['price']),
      originalPrice: JsonParse.doubleOrNull(json['original_price']),
      rating: JsonParse.intOrNull(rating['rating'] ?? rating['stars']),
      ratingStatus: RatingStatusLabel.fromApi(
        JsonParse.stringValue(rating['status'], fallback: 'none'),
      ),
      ratingComment: JsonParse.stringValue(
        rating['comment'] ?? rating['review'],
      ),
    );
  }

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  /// اليوم من غير ساعة — مفتاح تجميع العناصر في زيارات.
  DateTime get day => DateTime(startAt.year, startAt.month, startAt.day);

  /// فيه خصم فعلي؟ (`originalPrice` أعلى من المدفوع)
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
}
