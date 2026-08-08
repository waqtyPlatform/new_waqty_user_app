import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة إدخال في قائمة الانتظار.
///
/// الأسماء من `BookingWaitlistEntry` في السيرفر بالحرف.
enum WaitlistStatus {
  /// مستني — الفرع لسه ما عرضش حاجة.
  pending,

  /// الفرع عرض ميعاد وحاجزه **٥ دقايق**.
  offered,

  /// الحجز الـ٥ دقايق عدّى.
  expired,

  /// اتحوّل لحجز فعلي.
  accepted,

  /// العميل أو الفرع لغاه.
  cancelled,
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
    WaitlistStatus.pending => 'في قايمة الانتظار',
    WaitlistStatus.offered => 'ميعاد فضي من قايمة الانتظار',
    WaitlistStatus.expired => 'الميعاد راح',
    WaitlistStatus.accepted => 'اتحوّل لحجز',
    WaitlistStatus.cancelled => 'ملغي',
  };

  bool get isLive =>
      this == WaitlistStatus.pending || this == WaitlistStatus.offered;

  /// ينفع يخرج من القائمة دلوقتي؟ — **مستني بس**.
  ///
  /// ⚠ **مش [isLive].** الخروج كان ظاهر في الحالتين، يعني الزرار كان قابل
  /// للدوس **وسط عدّاد الـ٥ دقايق** ومن غير أي تأكيد. والدوسة الغلط هناك
  /// مش رجوع فيها: الميعاد بيروح لحد تاني فورًا، وهو بالظبط اللي كان
  /// مستني منه رد.
  ///
  /// وقت العرض الشغّال الفرع بيتصل بيه — الخروج مش نية معقولة في اللحظة
  /// دي أصلاً. الإخفاء أرخص وأأمن من sheet تأكيد لطريق مالوش لازمة.
  bool get canLeaveQueue => this == WaitlistStatus.pending;

  static WaitlistStatus fromApi(String? value) => switch (value) {
    'offered' => WaitlistStatus.offered,
    'expired' => WaitlistStatus.expired,
    'accepted' => WaitlistStatus.accepted,
    'cancelled' || 'rejected' => WaitlistStatus.cancelled,
    _ => WaitlistStatus.pending,
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

  final DateTime preferredAt;

  /// ترتيبي في قائمة انتظار الفرع — بيتحسب في السيرفر.
  final int position;

  /// إمتى الحجز المؤقت بيقع. `null` لما مفيش عرض شغّال.
  final DateTime? holdExpiresAt;

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
  });

  factory WaitlistUiModel.fromJson(Map<String, dynamic> json) {
    final holdSeconds = JsonParse.intOrNull(json['hold_remaining_seconds']);

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
    WaitlistStatus.pending =>
      'لما ميعاد يفضى في اليوم ده، الفرع هيتصل بيك',
    // **الصدق هنا مقصود.** العميل مايقدرش يقبل بنفسه — مفيش endpoint.
    WaitlistStatus.offered =>
      'الفرع هيتصل بيك يأكّد — خلّي التليفون معاك. '
          'لو الوقت خلص، الميعاد هيروح لحد تاني',
    WaitlistStatus.expired =>
      'الميعاد اترجّع للناس التانية. تقدر تدخل القائمة تاني',
    WaitlistStatus.accepted => 'الحجز بقى مؤكد — هتلاقيه في مواعيدك',
    WaitlistStatus.cancelled => 'مش في القائمة دلوقتي',
  };
}
