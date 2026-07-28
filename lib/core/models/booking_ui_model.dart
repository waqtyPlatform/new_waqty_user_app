/// حالات الحجز اللي العميل بيشوفها.
///
/// الأسماء الداخلية في السيرفر مصطلحات تقنية (`pending`, `no_show` ...)
/// ومتتعرضش زي ما هي. كل حالة هنا ليها لفظ عربي محترم.
///
/// ملحوظة: الإلغاء **مقسوم حسب مين اللي ألغى**. «ملغي» لوحدها بتسيب العميل
/// مش عارف هو اللي ألغى ولا المحل ولا المنصة — والفرق ده مهم جدًا ليه.
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelledByUser,
  cancelledByProvider,
  cancelledByPlatform,
  noShow,
  expired,
}

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
    BookingStatus.pending => 'بانتظار التأكيد',
    BookingStatus.confirmed => 'مؤكد',
    BookingStatus.inProgress => 'جارية الآن',
    BookingStatus.completed => 'منتهية',
    BookingStatus.cancelledByUser => 'قمت بالإلغاء',
    BookingStatus.cancelledByProvider => 'ألغاه المزود',
    BookingStatus.cancelledByPlatform => 'ألغته المنصة',
    BookingStatus.noShow => 'لم يتم الحضور',
    BookingStatus.expired => 'انتهت صلاحيته',
  };

  bool get isCancelled =>
      this == BookingStatus.cancelledByUser ||
      this == BookingStatus.cancelledByProvider ||
      this == BookingStatus.cancelledByPlatform;

  bool get isUpcoming =>
      this == BookingStatus.pending ||
      this == BookingStatus.confirmed ||
      this == BookingStatus.inProgress;

  /// التقييم مسموح بعد ما الخدمة تخلص بس.
  bool get canRate => this == BookingStatus.completed;
}

/// حالة الدفع.
///
/// `unpaid` بتتعرض «الدفع في الفرع» مش «غير مدفوع» — التانية بتتقري
/// كأنها مديونية على العميل، وهي مش كده.
enum PaymentStatus { payAtVenue, paid, refunded }

extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.payAtVenue => 'الدفع في الفرع',
    PaymentStatus.paid => 'مدفوع',
    PaymentStatus.refunded => 'تم استرداد المبلغ',
  };
}

class BookingUiModel {
  final String uuid;
  final String reference;
  final String providerName;
  final String branchName;
  final String branchAddress;
  final String serviceName;
  final String employeeName;
  final String imagePath;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String notes;
  final String cancellationReason;

  /// جاي من السيرفر — **مش بنحسبه في الموبايل.**
  /// حجز النهاردة عمره ما ينفع يتلغي، والقاعدة دي عند السيرفر.
  final bool canCancel;

  /// التقييم اللي العميل اداه. صفر = لسه ما قيّمش.
  final int myRating;

  const BookingUiModel({
    required this.uuid,
    required this.reference,
    required this.providerName,
    required this.branchName,
    required this.serviceName,
    required this.employeeName,
    required this.imagePath,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.status,
    this.branchAddress = '',
    this.paymentStatus = PaymentStatus.payAtVenue,
    this.notes = '',
    this.cancellationReason = '',
    this.canCancel = false,
    this.myRating = 0,
  });

  int get durationMinutes => endAt.difference(startAt).inMinutes;
}
