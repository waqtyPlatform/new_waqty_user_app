import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_visit_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالات الحجز اللي العميل بيشوفها.
///
/// **القايمة دي مطابقة لـ `BookingStatus::lifecycleCases()` في السيرفر
/// بالظبط** — لا زيادة ولا نقصان. اللي اتشال وليه:
///
///  • `pending` — مابقاش موجود. `Booking::STATUS_PENDING = 'confirmed'`
///    و`@deprecated`، وفيه migration نقل كل الصفوف. الحجز بيتعمل مؤكد
///    على طول. شاشة «بانتظار التأكيد» كانت بتختبر حالة محدش هيشوفها.
///  • `expired` — دي حالة **قائمة انتظار** (`BookingWaitlistEntry`)
///    مش حالة حجز.
///  • `cancelledByUser` / `cancelledByProvider` / `cancelledByPlatform` —
///    السيرفر بيسجّل `cancelled` واحدة ومفيش عمود `cancelled_by` خالص.
///    التلاتة دول كانوا بيوعدوا بمعلومة الأبلكيشن **مايقدرش** يعرفها.
///    النية سليمة وهي مسجّلة كـ backend ask، بس الحالة لازم تفضل صادقة.
///
/// واللي اتضاف: `arrived` و`waiting` — دول حرفيًا الحالتين اللي العميل
/// بيبقى فيهم **وهو واقف في الفرع**، والداشبورد بيطلّعهم كل يوم من زرار
/// «وصل»، والأبلكيشن عمره ما رسمهم.
///
/// الألفاظ منقولة حرف بحرف من `backend/lang/ar/status.php` — عشان لما
/// العميل يقول «التطبيق كاتب في الخدمة» الريسيبشن يشوف نفس الكلمة.
enum BookingStatus {
  confirmed,
  arrived,
  waiting,
  inProgress,
  completed,
  cancelled,
  noShow,
}

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
    BookingStatus.confirmed => 'مؤكد',
    BookingStatus.arrived => 'في انتظار بدء الخدمة',
    BookingStatus.waiting => 'في الانتظار',
    BookingStatus.inProgress => 'في الخدمة',
    BookingStatus.completed => 'مكتمل',
    BookingStatus.cancelled => 'ملغي',
    BookingStatus.noShow => 'لم يحضر',
  };

  bool get isCancelled => this == BookingStatus.cancelled;

  /// الحجز لسه قدام العميل — بما فيه وهو واقف في الفرع.
  bool get isUpcoming =>
      this == BookingStatus.confirmed ||
      this == BookingStatus.arrived ||
      this == BookingStatus.waiting ||
      this == BookingStatus.inProgress;

  /// العميل **جوه الفرع دلوقتي**.
  ///
  /// التلاتة دول بيتعاملوا مع بعض في الشاشة: الحجز بقى حاصل في اللحظة دي
  /// مش بكرة، والمعروض لازم يتغيّر من «تفاصيل حجز» لـ«إنت فين في الدور».
  bool get isInBranch =>
      this == BookingStatus.arrived ||
      this == BookingStatus.waiting ||
      this == BookingStatus.inProgress;

  /// التقييم مسموح بعد ما الخدمة تخلص بس.
  bool get canRate => this == BookingStatus.completed;

  static BookingStatus fromApi(String? value) => switch (value) {
    'arrived' => BookingStatus.arrived,
    'waiting' => BookingStatus.waiting,
    'in_progress' => BookingStatus.inProgress,
    'completed' => BookingStatus.completed,
    'cancelled' => BookingStatus.cancelled,
    'no_show' => BookingStatus.noShow,
    // `pending` و`scheduled` أسماء قديمة، والسيرفر نفسه بينقلهم لـ
    // `confirmed` في migration. بنعمل نفس الحاجة بدل ما نطلّع حالة تانية.
    _ => BookingStatus.confirmed,
  };
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

  static PaymentStatus fromApi(String? value) => switch (value) {
    'paid' => PaymentStatus.paid,
    'refunded' => PaymentStatus.refunded,
    _ => PaymentStatus.payAtVenue,
  };
}

class BookingUiModel {
  /// ULID بـ٢٦ حرف — ده `bookings.uuid` في السيرفر رغم الاسم.
  final String uuid;

  /// هوية المزود — **مطلوبة عشان «احجز تاني»**.
  ///
  /// الاسم لوحده مش كفاية: `CreateBookingSheet` بيفتح بـ `providerUuid`،
  /// والدوران على الاسم بيكسر أول ما محلين يتسمّوا نفس الاسم. السيرفر
  /// بيحمّل علاقة `provider` على `GET /user/bookings` أصلاً.
  final String providerUuid;

  final String providerName;

  /// هوية الفرع — عشان «احجز تاني» يرجع لنفس الفرع مش لأول واحد.
  final String branchUuid;

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

  /// عملة الحجز — السيرفر بيكشفها في `UserBookingResource`.
  ///
  /// الافتراضي جنيه مصري. (السيرفر نفسه متناقض: الـ migration default
  /// `SAR` وفيه `'SAR'` مكتوبة بالإيد في `QuickSaleService`، بينما
  /// `branchCurrency()` و`Money.php` كلهم EGP. متسجّل كـ backend ask.)
  final String currency;

  final String notes;
  final String cancellationReason;

  /// جاي من السيرفر — **مش بنحسبه في الموبايل.**
  ///
  /// `Booking::getCanCancelAttribute()` بيقفله لما الميعاد **يعدّي**.
  /// التعليق هنا كان بيقول «حجز النهاردة عمره ما ينفع يتلغي» — وده غلط:
  /// حجز النهاردة ٦م وإنت بتبصّ ٢ظ `can_cancel: true`.
  ///
  /// ⚠ **بوليان واحد من غير سبب.** لو السيرفر قفل الإلغاء لسبب تاني
  /// (سياسة المحل، حالة دفع، حجز بدأ فعلاً)، الأبلكيشن هيقول للعميل إن
  /// الميعاد بدأ وهو مش بدأ. الحل كود سبب في الرد — طلب للباك إند.
  final bool canCancel;

  /// حالة كل زيارة لوحدها — `visitUuid` → الحالة.
  ///
  /// **الغايب هنا معناه «زي الحجز»، مش «مالوش حالة».** الحجز بزيارة واحدة
  /// عمره ما هيحتاج الخريطة دي، وكل الـ fixtures القديمة شغّالة من غير
  /// تعديل. اللي بيحتاجها هو الحجز اللي زياراته اتفرقت فعلاً — زيارة
  /// خلصت وزيارة لسه.
  ///
  /// ⚠️ **مش مصدر حقيقة تاني لحالة الحجز.** الحجز الأب بيفضل بيجي من
  /// السيرفر زي ما هو (`recalculateBookingStatus()` هو اللي بيلمّه من
  /// زياراته هناك). إحنا بنقرا مش بنحسب.
  final Map<String, BookingStatus> visitStatuses;

  const BookingUiModel({
    required this.uuid,
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.imagePath,
    required this.items,
    required this.status,
    this.branchAddress = '',
    this.paymentStatus = PaymentStatus.payAtVenue,
    this.currency = 'EGP',
    this.notes = '',
    this.cancellationReason = '',
    this.canCancel = false,
    this.visitStatuses = const <String, BookingStatus>{},
  }) : assert(items.length > 0, 'الحجز لازم يكون فيه خدمة واحدة على الأقل');

  /// من رد `GET /api/user/bookings/{uuid}`.
  ///
  /// **العناصر بتتقرا من `visits[].items[]`**، مش من `items` المسطّحة —
  /// عشان `visit_uuid` يوصل صح ومنستنتجش الزيارات من التاريخ.
  ///
  /// ⚠️ `visits` بيتحمّل على `GET /user/bookings/{uuid}` بس. ليستة
  /// `GET /user/bookings` مابتحمّلهاش (`BookingRepository::paginateUser`)،
  /// فبنقع على `items` المسطّحة وقتها.
  factory BookingUiModel.fromJson(Map<String, dynamic> json) {
    final visits = JsonParse.mapListValue(json['visits']);

    final items = visits.isNotEmpty
        ? <BookingItemUiModel>[
            for (final visit in visits)
              for (final item in JsonParse.mapListValue(visit['items']))
                BookingItemUiModel.fromJson(<String, dynamic>{
                  ...item,
                  'visit_uuid': visit['uuid'],
                }),
          ]
        : JsonParse.mapListValue(
            json['items'],
          ).map(BookingItemUiModel.fromJson).toList();

    // `booking_visits.status` — عمود حقيقي، والداشبورد بيحرّكه لوحده عن
    // الحجز الأب. بيوصل مع `visits` بس، يعني على شاشة التفاصيل. ليستة
    // `GET /user/bookings` مابتحمّلش `visits` (backend ask BE-13)، وساعتها
    // الخريطة بتفضل فاضية وكل زيارة بتاخد حالة الحجز — نفس سلوك النهاردة.
    final visitStatuses = <String, BookingStatus>{
      for (final visit in visits)
        if (visit['status'] != null)
          JsonParse.stringValue(visit['uuid']): BookingStatusLabel.fromApi(
            JsonParse.stringValue(visit['status']),
          ),
    };

    // ⚠️ **الـ snapshots فيها `uuid` و`name` وبس.**
    //
    // `provider_snapshot` و`branch_snapshot` بيتبنوا في
    // `BookingCreationService::buildProviderSnapshot/buildBranchSnapshot`
    // والاتنين بيرجّعوا حقلين بس. يعني **مفيش عنوان الفرع ولا صورة
    // المزود** في رد الحجز خالص.
    //
    // الشاشة بتعرض الاتنين: `booking_details_info_widget` بيرسم سطر
    // «العنوان»، وصف القايمة بيرسم صورة. يوم الربط هيفضلوا فاضيين —
    // والسطر بيختفي لوحده (`branchAddress.isNotEmpty`) بس ده إخفاء
    // معلومة العميل محتاجها وهو رايح المحل.
    //
    // متسجّل كـ backend ask: زوّدوا `address` و`image` في الـ snapshots،
    // أو حمّلوا العلاقات في الـ resource.
    final provider = JsonParse.mapValue(json['provider']);
    final branch = JsonParse.mapValue(json['branch']);

    return BookingUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      providerUuid: JsonParse.stringValue(provider['uuid']),
      providerName: JsonParse.stringValue(provider['name']),
      branchUuid: JsonParse.stringValue(branch['uuid']),
      branchName: JsonParse.stringValue(branch['name']),
      // بنقراهم برضه عشان لو الـ snapshots اتوسّعت الكود يشتغل من غير
      // تعديل — بس مايتحسبوش موجودين النهاردة.
      branchAddress: JsonParse.stringValue(branch['address']),
      imagePath: JsonParse.stringValue(provider['image']),
      items: items,
      status: BookingStatusLabel.fromApi(
        JsonParse.stringValue(json['status'], fallback: 'confirmed'),
      ),
      paymentStatus: PaymentStatusLabel.fromApi(
        JsonParse.stringValue(json['payment_status'], fallback: 'unpaid'),
      ),
      currency: JsonParse.stringValue(json['currency'], fallback: 'EGP'),
      notes: JsonParse.stringValue(json['notes']),
      cancellationReason: JsonParse.stringValue(json['cancellation_reason']),
      canCancel: JsonParse.boolValue(json['can_cancel']),
      visitStatuses: visitStatuses,
    );
  }

  // ── مشتقات ───────────────────────────────────────────────────────────
  // نفس اللي السيرفر بيعمله: أعمدة الحجز الأب (`booking_date`،
  // `start_time`، `price`) ملخّص للعناصر مش مصدر مستقل.

  /// الرقم اللي العميل بيقوله في التليفون.
  ///
  /// **أول ٨ حروف من الـ ULID، من غير `#`.** ده اللي الداشبورد بيعرضه
  /// بالحرف: `substr($booking->uuid, 0, 8)` في `EditBooking.php` وفي
  /// داشبورد الأدمن — **من غير أي بادئة**. `WQ-10428` القديمة مكانش
  /// ليها عمود في السيرفر أصلاً، فالعميل اللي كان بيقراها في التليفون
  /// كان بيقابله سكوت.
  ///
  /// بيتعرض `dir: ltr` — نص لاتيني جوه واجهة عربي.
  String get reference => uuid.length >= 8 ? uuid.substring(0, 8) : uuid;

  /// بداية أول خدمة.
  DateTime get startAt =>
      items.map((i) => i.startAt).reduce((a, b) => a.isBefore(b) ? a : b);

  /// نهاية آخر خدمة.
  DateTime get endAt =>
      items.map((i) => i.endAt).reduce((a, b) => a.isAfter(b) ? a : b);

  /// مجموع أسعار الخدمات.
  double get price => items.fold<double>(0, (sum, i) => sum + i.price);

  /// المجموع قبل خصم مجموعة العميل — `null` لو مفيش خصم على أي خدمة.
  double? get originalPrice {
    if (!items.any((i) => i.hasDiscount)) return null;
    return items.fold<double>(
      0,
      (sum, i) => sum + (i.originalPrice ?? i.price),
    );
  }

  bool get hasDiscount => originalPrice != null;

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
  List<BookingVisitUiModel> get visits {
    final grouped = <String, List<BookingItemUiModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.visitUuid, () => <BookingItemUiModel>[]).add(item);
    }

    final visits = grouped.entries.map((entry) {
      final items = entry.value
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
      return BookingVisitUiModel(
        uuid: entry.key,
        // الغايب = زي الحجز. في حجز بزيارة واحدة ده صح دايمًا.
        status: visitStatuses[entry.key] ?? status,
        items: items,
      );
    }).toList();
    visits.sort((a, b) => a.startAt.compareTo(b.startAt));

    return visits;
  }

  /// الزيارة اللي العميل عايش فيها **دلوقتي**.
  ///
  /// الترتيب مقصود:
  ///  ١. الزيارة اللي [now] واقع جوه شباكها — دي أوضح إجابة.
  ///  ٢. لو مفيش، أول زيارة لسه ماخلصتش. ده بيمسك الحالتين اللي الشباك
  ///     مابيمسكهمش: العميل جه بدري (لسه قبل البداية) والزيارة اتأخرت
  ///     (عدّت النهاية وهي لسه `in_progress`).
  ///  ٣. لو كله خلص، آخر زيارة — عشان الشاشة تعرض النهاية مش تفضى.
  ///
  /// **بياخد [now] كمعامل مش بيقراه من `DateTime.now()`** — الاختيار ده
  /// هو اللي بيخلي السلوك قابل للاختبار من غير ما نزوّر ساعة الجهاز.
  BookingVisitUiModel currentVisit(DateTime now) {
    final all = visits;

    for (final visit in all) {
      if (visit.containsTime(now)) return visit;
    }
    for (final visit in all) {
      if (!visit.isFinished) return visit;
    }

    return all.last;
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

  // ── التقييم ──────────────────────────────────────────────────────────
  // **التقييم بقى على العنصر مش على الحجز.** حجز بتلات خدمات = تلات
  // تقييمات، وكل واحدة ليها نجومها وحالتها. `myRating` القديمة كانت رقم
  // واحد لكل ده — شكل غلط مش رقم غلط.

  /// الخدمات اللي لسه ينفع تتقيّم.
  List<BookingItemUiModel> get rateableItems => status.canRate
      ? items.where((i) => i.ratingStatus.canRate).toList()
      : const <BookingItemUiModel>[];

  bool get hasPendingRatings => rateableItems.isNotEmpty;
}
