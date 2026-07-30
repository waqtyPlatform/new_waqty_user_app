import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';

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
  final String imagePath;

  /// الخدمات اللي في الحجز — **مش خدمة واحدة**.
  ///
  /// الحقول القديمة `serviceName` و`employeeName` و`startAt` و`price`
  /// كانت نصوص وأرقام مفردة، وده كان بيخفي حجز بتلات خدمات ويعرضه
  /// كواحدة. بقت كلها **مشتقة** من الليستة دي عشان مايبقاش فيه مصدرين
  /// للحقيقة يتفرّقوا عن بعض.
  final List<BookingItemUiModel> items;

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
    required this.imagePath,
    required this.items,
    required this.status,
    this.branchAddress = '',
    this.paymentStatus = PaymentStatus.payAtVenue,
    this.notes = '',
    this.cancellationReason = '',
    this.canCancel = false,
    this.myRating = 0,
  }) : assert(items.length > 0, 'الحجز لازم يكون فيه خدمة واحدة على الأقل');

  // ── مشتقات ───────────────────────────────────────────────────────────
  // نفس اللي السيرفر بيعمله: أعمدة الحجز الأب (`booking_date`،
  // `start_time`، `price`) ملخّص للعناصر مش مصدر مستقل.

  /// بداية أول خدمة.
  DateTime get startAt =>
      items.map((i) => i.startAt).reduce((a, b) => a.isBefore(b) ? a : b);

  /// نهاية آخر خدمة.
  DateTime get endAt =>
      items.map((i) => i.endAt).reduce((a, b) => a.isAfter(b) ? a : b);

  /// مجموع أسعار الخدمات.
  double get price => items.fold<double>(0, (sum, i) => sum + i.price);

  /// **مجموع مدد الخدمات، مش الفرق بين أول وآخر ميعاد.**
  ///
  /// الفرق بيبقى غلط في حجز بزيارتين في يومين — بيطلع «٤٨ ساعة» بدل
  /// «ساعة ونص». العميل بيسأل «هاقعد قد إيه»، مش «الحجز مفرود على قد إيه».
  int get durationMinutes =>
      items.fold<int>(0, (sum, i) => sum + i.durationMinutes);

  /// الخدمات مجمّعة **بالزيارة زي ما السيرفر خزّنها**، مرتبة زمنيًا.
  ///
  /// التجميع بيتاخد من `visitUuid` مش من التاريخ. الفرق بيبان في حالة
  /// واحدة بس، وهي بالظبط الحالة اللي بتكسر: يومين خدمات في نفس اليوم
  /// بفارق كبير (صبغة ١٠ص وحمام كريم ٨م) بيتحجزوا **زيارتين** — والتجميع
  /// باليوم كان هيعرضهم زيارة واحدة بتمتد عشر ساعات.
  List<List<BookingItemUiModel>> get visits {
    final grouped = <String, List<BookingItemUiModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.visitUuid, () => <BookingItemUiModel>[]).add(item);
    }

    final visits = grouped.values.toList();
    for (final visit in visits) {
      visit.sort((a, b) => a.startAt.compareTo(b.startAt));
    }
    visits.sort((a, b) => a.first.startAt.compareTo(b.first.startAt));

    return visits;
  }

  bool get isMultiService => items.length > 1;

  /// «قص شعر» أو «قص شعر و٢ غيرها» — للصف المختصر في القوايم.
  String get serviceName => items.length == 1
      ? items.first.serviceName
      : '${items.first.serviceName} و${AppFormat.digits(items.length - 1)} غيرها';

  /// اسم الأخصائي لو كله مع واحد، وإلا «٣ أخصائيين».
  ///
  /// عرض أول اسم بس في حجز متعدد بيكدب على العميل — بيقول له إن مصطفى
  /// هيعمل له كل حاجة وهو مش كده.
  String get employeeName {
    final names = items.map((i) => i.employeeName).toSet();
    if (names.length == 1) return names.first;
    return '${AppFormat.digits(names.length)} أخصائيين';
  }
}
