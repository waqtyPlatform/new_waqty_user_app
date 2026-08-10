import 'package:waqty_user_application/core/models/waitlist_message_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة إدخال في قائمة الانتظار.
///
/// **القايمة دي مطابقة لـ `BookingWaitlistEntry::STATUSES` بالظبط** — لا
/// زيادة ولا نقصان، نفس قاعدة [BookingStatus]. الأسماء منقولة بالحرف.
///
/// ## الأسامي دي اتغيّرت كلها في waitlist v2
///
/// migration `2026_08_08_120000_upgrade_booking_waitlist_to_v2` غيّر
/// **قيم النصوص نفسها**: `pending` بقى `waiting`، و`offered` بقى
/// `awaiting_customer_response`، و`booked` بقى `converted`. الثوابت
/// القديمة لسه في السيرفر بس كـ aliases بتشاور على القيم الجديدة —
/// و`BookingWaitlistResource` بيبعت `$this->status` **خام** من غير أي
/// تحويل.
///
/// يعني كل حالة تحت كانت بتقع على `pending` في الأبلكيشن، بما فيها
/// العرض اللي عليه عدّاد شغّال والإدخال اللي بقى حجز مؤكد.
enum WaitlistStatus {
  /// `waiting` — في الطابور، الفرع لسه ما عرضش حاجة.
  waiting,

  /// `under_review` — **ميعاد فضي والفرع بيراجع مين ياخده.**
  ///
  /// `markAvailabilityForReleasedBooking()` بيقلب الإدخالات المطابقة
  /// عليها وبيحط `availability_detected_at` أول ما حجز يتلغي. مش حالة
  /// إدارية داخلية — دي اللحظة اللي طلب العميل بقى فيها قريب من الحقيقة.
  underReview,

  /// `awaiting_customer_response` — الفرع عرض ميعاد وحاجزه، والدور على
  /// العميل يرد.
  awaitingResponse,

  /// `change_requested` — **العميل رد وقال الميعاد ده مش مناسب.**
  ///
  /// حالة جديدة في v2 ومالهاش مقابل قديم. العرض اتقفل والإدخال رجع
  /// للطابور مستني عرض تاني — فهي **شغّالة** مش نهاية. السيرفر بيعاملها
  /// كده: بيسمح بـ`review` و`offer` و`suggest` عليها زي `waiting`.
  changeRequested,

  /// `converted` — اتحوّل لحجز فعلي وموجود في «مواعيدي».
  converted,

  /// `cancelled_by_customer` — العميل خرج من القايمة بنفسه.
  ///
  /// ⚠ **منفصلة عن [rejectedByBranch] عن قصد.** الاتنين كانوا `cancelled`
  /// واحدة، وده كان مقبول لما السيرفر مكانش بيفرّق. بقى بيفرّق، و«إنت
  /// خرجت» و«الفرع ماقدرش يستوعبك» رسالتين مختلفتين تمامًا.
  cancelledByCustomer,

  /// `rejected_by_branch` — الفرع رفض الطلب.
  rejectedByBranch,

  /// `response_expired` — العرض عدّى من غير رد.
  ///
  /// **مش نهاية.** السيرفر بيحطها جنب `waiting` في كل قايمة بيسمح فيها
  /// بعرض جديد — يعني الفرع يقدر يعرض تاني على نفس الإدخال.
  responseExpired,

  /// `no_suitable_time` — الفرع عرض `MAX_OFFERS` مرة ومفيش واحد ناسب.
  ///
  /// نهاية، بس نهاية **محايدة**: محدش رفض حد، الأوقات هي اللي ما اتقابلتش.
  noSuitableTime,

  /// `request_period_expired` — اليوم اللي العميل كان مستنيه عدّى.
  ///
  /// بيتحط بـsweep مجدول (`ExpireWaitlistHolds`) على كل إدخال لسه شغّال
  /// بعد ما فترة الطلب تفوت.
  requestPeriodExpired,
}

extension WaitlistStatusLabel on WaitlistStatus {
  /// **اللابل بيقول من فين جه الكارت، مش بس هو إيه.**
  ///
  /// كان «فيه ميعاد فاضي ليك» — جملة صح ومفهومة لوحدها، بس العميل اللي
  /// بيفتح الأبلكيشن ولاقاها مش فاكر إنه دخل قائمة انتظار من يومين،
  /// فبتقرا **إعلان** مش رد على طلبه. وأول ما تقرا إعلان، العدّاد اللي
  /// تحتها بيقرا ضغط مبيعات.
  ///
  /// ذكر «قايمة الانتظار» بالاسم بيربط الكارت بالفعل اللي هو عمله.
  String get label => switch (this) {
    WaitlistStatus.waiting => 'في قايمة الانتظار',
    // **مابيقولش «دورك جه»** — الفرع بيراجع مين ياخده، وممكن مايبقاش
    // إنت. الوعد بميعاد لسه ماتحجزش أسوأ من الانتظار نفسه.
    WaitlistStatus.underReview => 'فيه ميعاد فضي — الفرع بيراجع',
    WaitlistStatus.awaitingResponse => 'ميعاد فضي من قايمة الانتظار',
    WaitlistStatus.changeRequested => 'طلبت ميعاد تاني',
    WaitlistStatus.converted => 'اتحوّل لحجز',
    WaitlistStatus.cancelledByCustomer => 'خرجت من القايمة',
    WaitlistStatus.rejectedByBranch => 'الفرع اعتذر',
    WaitlistStatus.responseExpired => 'الميعاد راح',
    WaitlistStatus.noSuitableTime => 'مفيش ميعاد ناسب',
    WaitlistStatus.requestPeriodExpired => 'اليوم عدّى',
  };

  /// لسه في القايمة وممكن ييجي عرض.
  ///
  /// `changeRequested` جوّاها لأن السيرفر بيعاملها كده حرفيًا — بيسمح
  /// بـ`review` و`offer` و`suggest` عليها زي `waiting` بالظبط.
  bool get isLive =>
      this == WaitlistStatus.waiting ||
      this == WaitlistStatus.underReview ||
      this == WaitlistStatus.awaitingResponse ||
      this == WaitlistStatus.changeRequested;

  /// خلص بنتيجة، وماينفعش يرجع منها.
  ///
  /// ⚠ **مش عكس [isLive].** `responseExpired` مش في الاتنين: العرض راح،
  /// بس السيرفر لسه بيسمح بعرض تاني على نفس الإدخال — فهي مش نهاية،
  /// وفي نفس الوقت مفيش حاجة شغّالة دلوقتي.
  bool get isSettled =>
      this == WaitlistStatus.converted ||
      this == WaitlistStatus.cancelledByCustomer ||
      this == WaitlistStatus.rejectedByBranch ||
      this == WaitlistStatus.noSuitableTime ||
      this == WaitlistStatus.requestPeriodExpired;

  /// ينفع يخرج من القائمة دلوقتي؟ — **مستني بس**.
  ///
  /// ⚠ **مش [isLive].** الخروج كان ظاهر في الحالتين، يعني الزرار كان قابل
  /// للدوس **وسط عدّاد الـ٥ دقايق** ومن غير أي تأكيد. والدوسة الغلط هناك
  /// مش رجوع فيها: الميعاد بيروح لحد تاني فورًا، وهو بالظبط اللي كان
  /// مستني منه رد.
  ///
  /// وقت العرض الشغّال الفرع بيتصل بيه — الخروج مش نية معقولة في اللحظة
  /// دي أصلاً. الإخفاء أرخص وأأمن من sheet تأكيد لطريق مالوش لازمة.
  ///
  /// ⚠ **الحسبة دي اتشالت من الشاشة.** بقت `WaitlistUiModel.canCancel`
  /// اللي جاية من السيرفر — نفس القاعدة اللي `BookingUiModel.canCancel`
  /// ماشية عليها: بوليان واحد بيتقرا، مش شرط بيتحسب في مكانين.
  ///
  /// السبب اللي فوق كمان **مابقاش قايم**: كان الخروج بيتخفي وقت العرض
  /// لأن العميل مكانش يقدر يعمل أي حاجة تانية، فالدوسة الغلط كانت خسارة
  /// صافية. waitlist v2 ضاف له «أقبل» و«اطلب ميعاد تاني»، فالخروج بقى
  /// اختيار تالت جنب اتنين معقولين مش الفعل الوحيد المتاح.
  @Deprecated('اقرا WaitlistUiModel.canCancel من السيرفر')
  bool get canLeaveQueue =>
      this == WaitlistStatus.waiting ||
      this == WaitlistStatus.underReview ||
      this == WaitlistStatus.changeRequested ||
      this == WaitlistStatus.responseExpired;

  /// ⚠ **الأسامي القديمة متسيبة عن قصد.**
  ///
  /// `pending`/`offered`/`booked`/`rejected` مابقوش بيتكتبوا من السيرفر
  /// خالص — الـ migration حوّل الصفوف والخدمة بتكتب القيم الجديدة. بس
  /// صف قديم نجا من الترحيل، أو رد متخزّن في كاش، لازم يفضل مقروء.
  /// السطور دي بتتشال لما نتأكد إن مفيش قيم قديمة في أي داتابيز شغّالة.
  ///
  /// و`_` بيقع على [waiting] مش على حاجة تانية: أي حالة مش معروفة معناها
  /// «إحنا مش عارفين وصلت لفين»، وأقل ضرر إننا نقول إنه في الطابور بدل
  /// ما نقول إنه خلص أو إن فيه عرض مستنيه.
  static WaitlistStatus fromApi(String? value) => switch (value) {
    // v2 — القيم اللي السيرفر بيبعتها فعلاً.
    'waiting' => WaitlistStatus.waiting,
    'under_review' => WaitlistStatus.underReview,
    'awaiting_customer_response' => WaitlistStatus.awaitingResponse,
    'change_requested' => WaitlistStatus.changeRequested,
    'converted' => WaitlistStatus.converted,
    'cancelled_by_customer' => WaitlistStatus.cancelledByCustomer,
    'rejected_by_branch' => WaitlistStatus.rejectedByBranch,
    'response_expired' => WaitlistStatus.responseExpired,
    'no_suitable_time' => WaitlistStatus.noSuitableTime,
    'request_period_expired' => WaitlistStatus.requestPeriodExpired,
    // v1 — صفوف ما اتحوّلتش.
    'pending' => WaitlistStatus.waiting,
    'reviewing' => WaitlistStatus.underReview,
    'offered' => WaitlistStatus.awaitingResponse,
    'booked' || 'accepted' => WaitlistStatus.converted,
    'rejected' => WaitlistStatus.rejectedByBranch,
    'cancelled' => WaitlistStatus.cancelledByCustomer,
    'expired' => WaitlistStatus.responseExpired,
    _ => WaitlistStatus.waiting,
  };
}

/// إدخال واحد في قائمة انتظار فرع.
///
/// ## اللي السيرفر عنده فعلاً
///
/// `POST /user/waitlist` و`GET /user/waitlist` **موجودين وشغالين**
/// (`routes/api.php:642-645`). والحجز الـ٥ دقايق حقيقي:
/// `BookingWaitlistService::HOLD_MINUTES = 5`، و`hold_remaining_seconds`
/// و`is_hold_active` مكشوفين في `BookingWaitlistResource`.
///
/// ## اللي **مش** موجود — وده أهم نتيجة في البند ده
///
/// **العميل مايقدرش يقبل العرض.** `offer` و`accept` الاتنين
/// `PATCH /provider/waitlist/{uuid}/...` — يعني **الموظف** هو اللي
/// بيقبل نيابة عن العميل، جوه حجز العميل نفسه مش شايفه.
///
/// فالشاشة دي بتعرض العدّاد بصدق وبتقول للعميل إن الفرع هو اللي هيأكّد.
/// لما ناس تشوف عدّاد وتحاول تدوس عليه، ده بيبقى الدليل اللي بنروح بيه
/// نطلب `PATCH /user/waitlist/{uuid}/accept`.
class WaitlistUiModel {
  final String uuid;
  final WaitlistStatus status;

  final String providerName;
  final String branchName;
  final String serviceName;

  /// `null` = العميل مافرقتش معاه — زي «أي أخصائي متاح» في الحجز.
  final String? employeeName;

  /// **الميعاد اللي العميل طلبه**، مش اللي الفرع عرضه.
  final DateTime preferredAt;

  /// ترتيبي في قائمة انتظار الفرع — بيتحسب في السيرفر.
  final int position;

  /// إمتى الحجز المؤقت بيقع. `null` لما مفيش عرض شغّال.
  final DateTime? holdExpiresAt;

  /// **بداية الميعاد اللي الفرع عارضه فعلاً.** `null` لما مفيش عرض.
  ///
  /// ⚠ **ده مش [preferredAt]، ولا المفروض يبقى زيه.**
  ///
  /// العرض بيحصل أصلاً عشان الفرع لقى ميعاد **تاني** فاضي — لو كان
  /// الميعاد المطلوب متاح، العميل كان حجزه من الأول ومكانش دخل قايمة
  /// انتظار. يعني الاتنين مختلفين **بحكم التعريف** في الحالة الوحيدة
  /// اللي بيهم فيها عرض.
  ///
  /// الكارت كان بيعرض [preferredAt] جنب عدّاد الـ٥ دقايق — يعني العميل
  /// بيقرا ساعة مش هي المحجوزة له، ويروح المحل في الميعاد الغلط. والباج
  /// ده بيبان معقول تمامًا، عشان كده عاش.
  final DateTime? offeredStartAt;

  final DateTime? offeredEndAt;

  /// الأخصائي في العرض — ممكن يختلف عن [employeeName] اللي العميل طلبه.
  final String? offeredEmployeeName;

  /// رسالة الفرع مع العرض. `null` = ماكتبش حاجة.
  final String? offerMessage;

  // ── صلاحيات السيرفر ──────────────────────────────────────────────────
  //
  // **بتتقرا مابتتحسبش.** نفس قاعدة `BookingUiModel.canCancel`: الشرط
  // الحقيقي عايش في `BookingWaitlistResource` جنب الحالة والمهلة، وأي
  // نسخة منه في الأبلكيشن بتفترق عنه أول ما السيرفر يعدّل قاعدة.
  //
  // waitlist v2 كشفهم كلهم: `can_accept` · `can_request_change` ·
  // `can_cancel` — وقبلها كان العميل **مايقدرش** يعمل أي واحدة منهم.

  /// يقبل العرض بنفسه. `POST /user/waitlist/{uuid}/accept`
  final bool canAccept;

  /// يطلب ميعاد تاني. `POST /user/waitlist/{uuid}/request-change`
  final bool canRequestChange;

  /// يخرج من القايمة. `POST /user/waitlist/{uuid}/cancel`
  final bool canCancel;

  // ── المحادثة ─────────────────────────────────────────────────────────

  /// خيط الرسايل بينه وبين الفرع.
  ///
  /// بيوصل على `GET /user/waitlist/{uuid}` بس — الليستة مابتحملهوش،
  /// فبيفضل فاضي في كارت الرئيسية.
  final List<WaitlistMessageUiModel> messages;

  /// الخيط مقفول — الطلب خلص فمفيش رد بعد كده.
  final bool conversationReadOnly;

  /// كام عرض اتبعت، ومن كام. `attempt_count` و`MAX_OFFERS` في السيرفر.
  ///
  /// بيتعرض للعميل عشان «الفرع جرّب معاك تلات مرات» تفسّر ليه الطلب
  /// خلص بـ`noSuitableTime` بدل ما تبان نهاية عشوائية.
  final int attemptCount;

  final int maxAttempts;

  const WaitlistUiModel({
    required this.uuid,
    required this.status,
    required this.providerName,
    required this.branchName,
    required this.serviceName,
    required this.preferredAt,
    required this.position,
    this.employeeName,
    this.holdExpiresAt,
    this.offeredStartAt,
    this.offeredEndAt,
    this.offeredEmployeeName,
    this.offerMessage,
    this.canAccept = false,
    this.canRequestChange = false,
    this.canCancel = false,
    this.messages = const <WaitlistMessageUiModel>[],
    this.conversationReadOnly = true,
    this.attemptCount = 0,
    this.maxAttempts = 3,
  });

  /// فيه فعل واحد على الأقل متاح للعميل دلوقتي؟
  ///
  /// الكارت بيرسم منطقة الأزرار على أساسها — منطقة فاضية بحدود بتقرا
  /// كأنها معطّلة، وأوحش من إنها ماتبانش.
  bool get hasActions => canAccept || canRequestChange || canCancel;

  /// فيه ميعاد معروض يتعرض للعميل؟
  bool get hasOffer => offeredStartAt != null;

  /// الميعاد اللي **يتعرض على الكارت** — المعروض لو موجود، وإلا المطلوب.
  ///
  /// الاختيار ده هو الإصلاح كله: أي حتة بتعرض وقت لازم تعدّي من هنا،
  /// عشان محدش يكتب `preferredAt` بالغلط في سياق فيه عرض.
  DateTime get displayAt => offeredStartAt ?? preferredAt;

  /// الأخصائي اللي يتعرض — بنفس المنطق.
  String? get displayEmployeeName =>
      hasOffer ? (offeredEmployeeName ?? employeeName) : employeeName;

  /// العرض على ميعاد غير اللي العميل طلبه؟ — لو أيوة لازم يتقال صراحة.
  bool get offerDiffersFromPreferred =>
      offeredStartAt != null && !offeredStartAt!.isAtSameMomentAs(preferredAt);

  factory WaitlistUiModel.fromJson(Map<String, dynamic> json) {
    final holdSeconds = JsonParse.intOrNull(json['hold_remaining_seconds']);
    final offer = JsonParse.mapValue(json['current_offer']);

    return WaitlistUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      status: WaitlistStatusLabel.fromApi(
        JsonParse.stringValue(json['status'], fallback: 'pending'),
      ),
      providerName: JsonParse.stringValue(
        JsonParse.mapValue(json['provider'])['name'],
      ),
      branchName: JsonParse.stringValue(
        JsonParse.mapValue(json['branch'])['name'],
      ),
      serviceName: JsonParse.stringValue(
        JsonParse.mapValue(json['service'])['name'],
      ),
      employeeName: JsonParse.mapValue(json['employee'])['name'] as String?,
      preferredAt:
          JsonParse.dateOrNull(json['preferred_at']) ??
          JsonParse.dateValue(json['preferred_date']),
      position: JsonParse.intValue(json['position']),
      // السيرفر بيبعت **ثواني متبقية** مش وقت انتهاء — بنحوّلها لوقت
      // مطلق مرة واحدة عشان العدّاد مايعتمدش على وقت وصول الرد.
      holdExpiresAt: holdSeconds == null || holdSeconds <= 0
          ? null
          : DateTime.now().add(Duration(seconds: holdSeconds)),
      // **`current_offer` هو المصدر، والحقول المسطّحة احتياطي.**
      //
      // waitlist v2 نقل العروض لجدول `booking_waitlist_offers` بمحاولات
      // مرقّمة، و`current_offer` هو الصف النشط منها. الحقول المسطّحة
      // (`offered_start_at`…) نسخة على الإدخال الأب، وممكن تبقى بايتة من
      // محاولة قديمة لو الصف اتقفل من غير ما تتمسح.
      offeredStartAt:
          JsonParse.dateOrNull(offer['start_at']) ??
          JsonParse.dateOrNull(json['offered_start_at']),
      offeredEndAt:
          JsonParse.dateOrNull(offer['end_at']) ??
          JsonParse.dateOrNull(json['offered_end_at']),
      offeredEmployeeName:
          offer['employee_name'] as String? ??
          JsonParse.mapValue(json['offered_employee'])['name'] as String?,
      offerMessage: offer['message'] as String?,
      canAccept: JsonParse.boolValue(json['can_accept']),
      canRequestChange: JsonParse.boolValue(json['can_request_change']),
      canCancel: JsonParse.boolValue(json['can_cancel']),
      // الأحداث اللي مالهاش ترجمة بتتشال هنا مش في الـ widget — عشان
      // «المحادثة فاضية» تبقى صادقة بدل ما تعد سطور مش هتترسم.
      messages: JsonParse.mapListValue(json['messages'])
          .map(WaitlistMessageUiModel.fromJson)
          .where((message) => message.isVisible)
          .toList(),
      // الافتراضي `true`: خيط مقفول بيخفي خانة الكتابة، وده أأمن من إننا
      // نوري خانة على طلب خلص فيرمي الرد ٤٢٢.
      conversationReadOnly: JsonParse.boolValue(
        json['conversation_read_only'],
        fallback: true,
      ),
      attemptCount: JsonParse.intValue(json['attempt_count']),
    );
  }

  /// الثواني الفاضلة في الحجز المؤقت — صفر لو خلص أو مفيش عرض.
  int remainingSeconds(DateTime now) {
    final expiry = holdExpiresAt;
    if (expiry == null) return 0;
    final left = expiry.difference(now).inSeconds;
    return left < 0 ? 0 : left;
  }

  bool isHoldActive(DateTime now) => remainingSeconds(now) > 0;

  /// «4:32» — دقايق ونقطتين وثواني.
  String countdownLabel(DateTime now) {
    final total = remainingSeconds(now);
    return '${AppFormat.digits(total ~/ 60)}:${_twoDigits(total % 60)}';
  }

  /// الثواني لازم تبقى خانتين دايمًا — «4:5» بتتقرا غلط.
  static String _twoDigits(int value) {
    final digits = AppFormat.digits(value);
    return value < 10 ? '0$digits' : digits;
  }

  /// السطر اللي بيقول للعميل **يعمل إيه**، مش اللي بيوصف الحالة.
  ///
  /// ## المشكلة اللي كانت في سطر العرض
  ///
  /// كان «الفرع بيأكّد الحجز ده دلوقتي — استنى مكالمة». الجملة صادقة
  /// (العميل فعلاً مايقدرش يقبل بنفسه)، بس بتتناقض مع العدّاد اللي فوقها
  /// على بعد سطر: **لو الفرع بيأكّد خلاص، أنا مستعجل ليه؟**
  ///
  /// عدّاد من غير فعل بيقرا قلق من غير مخرج. والعميل بيفضل يبص على رقم
  /// بينزل وهو مش عارف هو المفروض يعمل إيه — وده أوحش من إن العدّاد
  /// مايبانش أصلاً.
  ///
  /// الفعل الحقيقي موجود، بس مكانش مكتوب: **يردّ على التليفون**.
  /// والسطر الجديد بيحط النتيجة كمان، عشان الرقم يبقى ليه معنى: لو
  /// الوقت خلص، الميعاد بيروح لحد تاني فعلاً — دي مش تهديد، دي اللي
  /// `BookingWaitlistService` بيعمله لما الحجز المؤقت ينتهي.
  String get explanation => switch (status) {
    // كان «هنبلّغك أول ما ميعاد يفضى» — **وعد بإشعار مفيش transport ليه.**
    // `app_device_tokens` بيتكتب فيه ومحدش بيقراه: مفيش sender ولا job ولا
    // listener ولا package. يعني الجملة دي كانت بتقول للعميل «سيبها علينا»
    // وهو مش هيوصله حاجة أبدًا.
    //
    // نفس نبرة `offered` تحتها بالظبط — الفرع هو اللي بيتحرّك، وده اللي
    // بيحصل فعلاً. ترجع أول ما حاجة تقرا `app_device_tokens`.
    WaitlistStatus.waiting => 'لما ميعاد يفضى في اليوم ده، الفرع هيتصل بيك',
    // **مافيش وعد هنا.** الميعاد فضي فعلاً، بس القائمة فيها ناس تانية
    // والفرع هو اللي بيرتّب. الجملة بتقول اللي حصل وبتوقف — أي «دورك
    // قرّب» هنا بتبقى وعد إحنا مش ضامنينه.
    WaitlistStatus.underReview =>
      'فضي ميعاد والفرع بيشوف مين ياخده. لو اختارك هيتصل بيك',
    // ⚠ **الجملة دي بقت ناقصة، مش غلط.**
    //
    // كانت مكتوبة عشان العميل **مايقدرش** يقبل بنفسه: `accept` كان تحت
    // `/provider/` بس. waitlist v2 ضاف `POST /user/waitlist/{uuid}/accept`
    // و`request-change` و`cancel` — يعني الفعل بقى في إيده.
    //
    // الجملة متسيبة صادقة (الفرع فعلاً بيتصل) لحد ما الأزرار نفسها
    // تتبني. تغييرها دلوقتي بيوعد بزرار مش موجود على الشاشة، وده أوحش
    // من إنها ناقصة. متسجّلة في اللي بعده مباشرة.
    WaitlistStatus.awaitingResponse =>
      'الفرع هيتصل بيك يأكّد — خلّي التليفون معاك. '
          'لو الوقت خلص، الميعاد هيروح لحد تاني',
    WaitlistStatus.changeRequested =>
      'قلت إن الميعاد ده مش مناسب. الفرع هيدوّر على واحد تاني',
    WaitlistStatus.responseExpired =>
      'الميعاد اترجّع للناس التانية. لسه في القايمة وممكن ييجي عرض تاني',
    WaitlistStatus.converted => 'الحجز بقى مؤكد — هتلاقيه في مواعيدك',
    WaitlistStatus.cancelledByCustomer => 'خرجت من القايمة دي',
    // **مش «مرفوض».** الرفض بيتقري كأن العميل عمل حاجة غلط.
    WaitlistStatus.rejectedByBranch => 'الفرع ما قدرش يستوعب الطلب ده',
    // نهاية محايدة — محدش رفض حد، الأوقات هي اللي ما اتقابلتش.
    WaitlistStatus.noSuitableTime =>
      'جرّبنا كذا ميعاد ومفيش واحد ناسب. تقدر تحجز يوم تاني',
    WaitlistStatus.requestPeriodExpired =>
      'اليوم اللي كنت مستنيه عدّى. تقدر تدخل قايمة انتظار ليوم تاني',
  };
}
