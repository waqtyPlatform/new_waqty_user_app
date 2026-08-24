import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة طلب إعادة التوزيع — **من ألفاظ السيرفر**.
///
/// نفس اللي بيبان على `/employees/{uuid}/affected-bookings` في الداشبورد،
/// فلما العميل يكلّم الفرع الاتنين بيتكلموا نفس اللغة.
enum ReassignmentStatus {
  /// الفرع اقترح بديل والعميل هو اللي عليه الدور.
  awaitingCustomer,

  /// العميل قال «الميعاد ده مش مناسب» والفرع بيدوّر على غيره.
  changeRequested,

  /// خلاص — الحجز اتنقل.
  applied,

  /// الحجز اتلغى (العميل رفض، أو الفرع مالقاش بديل).
  cancelled,

  /// تلات محاولات وما اتفقناش — الفرع هيتصرّف بره الأبلكيشن.
  noAgreement,

  /// حالة مش معروفة — بتتعرض كمعلومة مش كخطأ.
  unknown,
}

extension ReassignmentStatusLabel on ReassignmentStatus {
  static ReassignmentStatus fromApi(String? value) => switch (value) {
    'awaiting_customer' => ReassignmentStatus.awaitingCustomer,
    'change_requested' => ReassignmentStatus.changeRequested,
    'applied' => ReassignmentStatus.applied,
    'cancelled' => ReassignmentStatus.cancelled,
    'no_agreement' => ReassignmentStatus.noAgreement,
    _ => ReassignmentStatus.unknown,
  };

  String get label => switch (this) {
    ReassignmentStatus.awaitingCustomer => 'مستني ردك',
    ReassignmentStatus.changeRequested => 'الفرع بيدوّر على ميعاد تاني',
    ReassignmentStatus.applied => 'الحجز اتنقل',
    ReassignmentStatus.cancelled => 'الحجز اتلغى',
    ReassignmentStatus.noAgreement => 'الفرع هيتواصل معاك',
    ReassignmentStatus.unknown => '—',
  };

  /// الحالات اللي لسه فيها شغل للعميل — بتتعرض في القايمة وبشارة.
  bool get isOpen =>
      this == ReassignmentStatus.awaitingCustomer ||
      this == ReassignmentStatus.changeRequested;
}

/// مين كاتب الرسالة في المحادثة.
enum ReassignmentSender { system, branch, customer }

/// رسالة واحدة في محادثة إعادة التوزيع.
class ReassignmentMessageUiModel {
  final String uuid;
  final ReassignmentSender sender;
  final String body;
  final DateTime createdAt;

  const ReassignmentMessageUiModel({
    required this.uuid,
    required this.sender,
    required this.body,
    required this.createdAt,
  });

  bool get isMine => sender == ReassignmentSender.customer;

  factory ReassignmentMessageUiModel.fromJson(Map<String, dynamic> json) =>
      ReassignmentMessageUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        sender: switch (JsonParse.stringValue(json['sender_type'])) {
          'customer' || 'user' => ReassignmentSender.customer,
          'branch' || 'provider' || 'employee' => ReassignmentSender.branch,
          _ => ReassignmentSender.system,
        },
        body: JsonParse.stringValue(json['body']),
        createdAt: JsonParse.dateValue(json['created_at']),
      );
}

/// الاقتراح الشغّال — **الميعاد البديل اللي الفرع محجزه للعميل دلوقتي**.
class ReassignmentProposalUiModel {
  final String uuid;
  final int attemptNumber;
  final String employeeName;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final String reason;
  final String branchMessage;

  /// ⚠ **لحظة الانتهاء المطلقة — مش عدد ثواني.**
  ///
  /// `hold_remaining_seconds` في الرد **لقطة** وقت النداء. لو اعتمدنا
  /// عليها، الأبلكيشن يرجع من الخلفية بعد عشر دقايق وهو لسه فاكر إن
  /// فاضل ١٤ دقيقة. اللحظة المطلقة صح دايمًا.
  final DateTime holdExpiresAt;

  const ReassignmentProposalUiModel({
    required this.uuid,
    required this.attemptNumber,
    required this.employeeName,
    required this.startAt,
    required this.endAt,
    required this.holdExpiresAt,
    this.price = 0,
    this.reason = '',
    this.branchMessage = '',
  });

  /// المهلة لسه شغّالة؟
  bool isHoldActive(DateTime now) => holdExpiresAt.isAfter(now);

  /// الفاضل بالثواني — صفر لو خلصت.
  int remainingSeconds(DateTime now) {
    final seconds = holdExpiresAt.difference(now).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  factory ReassignmentProposalUiModel.fromJson(Map<String, dynamic> json) {
    final start = JsonParse.dateValue(json['start_at']);

    return ReassignmentProposalUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      attemptNumber: JsonParse.intValue(json['attempt_number'], fallback: 1),
      employeeName: JsonParse.localizedValue(json['employee']),
      startAt: start,
      endAt: JsonParse.dateOrNull(json['end_at']) ?? start,
      // ⚠ لو `hold_expires_at` ناقصة بنحسبها من `hold_remaining_seconds`
      // كاحتياطي — أحسن من مهلة منتهية بالغلط توري «راح» على اقتراح شغّال.
      holdExpiresAt:
          JsonParse.dateOrNull(json['hold_expires_at']) ??
          DateTime.now().add(
            Duration(
              seconds: JsonParse.intValue(json['hold_remaining_seconds']),
            ),
          ),
      price: JsonParse.doubleValue(json['price']),
      reason: JsonParse.stringValue(json['reason']),
      branchMessage: JsonParse.stringValue(json['branch_message']),
    );
  }
}

/// طلب إعادة توزيع حجز.
///
/// ## الفلو
///
/// الموظف بيخرج إجازة أو بيسيب الشغل → الفرع بيلاقي حجوزاته الجاية →
/// بيقترح **بديل بمهلة ١٥ دقيقة** → العميل يقبل أو يطلب تغيير أو يلغي.
/// تلات محاولات كحد أقصى.
///
/// ⚠ **بيشتغل للحجوزات اللي اتعملت من الأبلكيشن بس** (`booking_source =
/// 'mobile_app'`). أي حجز تاني الفرع بينقله من غير ما يسأل.
class ReassignmentUiModel {
  final String uuid;
  final ReassignmentStatus status;
  final int attempts;
  final int maxAttempts;

  final String bookingUuid;
  final String serviceName;
  final String originalEmployeeName;
  final DateTime? originalStartAt;
  final DateTime? originalEndAt;

  /// `null` معناها مفيش اقتراح شغّال دلوقتي — الفرع بيدوّر، أو خلصت.
  final ReassignmentProposalUiModel? activeProposal;

  final List<ReassignmentMessageUiModel> conversation;

  const ReassignmentUiModel({
    required this.uuid,
    required this.status,
    required this.bookingUuid,
    this.attempts = 0,
    this.maxAttempts = 3,
    this.serviceName = '',
    this.originalEmployeeName = '',
    this.originalStartAt,
    this.originalEndAt,
    this.activeProposal,
    this.conversation = const <ReassignmentMessageUiModel>[],
  });

  /// آخر محاولة؟ — الشاشة بتنبّه لأن الرفض بعدها معناه الفرع هيتصرّف بره.
  bool get isLastAttempt => attempts >= maxAttempts - 1;

  bool get needsMyAnswer =>
      activeProposal != null && status == ReassignmentStatus.awaitingCustomer;

  bool isHoldActive(DateTime now) =>
      activeProposal?.isHoldActive(now) ?? false;

  factory ReassignmentUiModel.fromJson(Map<String, dynamic> json) {
    final booking = JsonParse.mapValue(json['booking']);
    final original = JsonParse.mapValue(booking['original']);
    final proposal = json['active_proposal'];

    return ReassignmentUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      status: ReassignmentStatusLabel.fromApi(
        JsonParse.stringValue(json['status']),
      ),
      attempts: JsonParse.intValue(json['attempts']),
      maxAttempts: JsonParse.intValue(json['max_attempts'], fallback: 3),
      bookingUuid: JsonParse.stringValue(booking['uuid']),
      serviceName: JsonParse.localizedValue(original['service']),
      originalEmployeeName: JsonParse.localizedValue(original['employee']),
      originalStartAt: JsonParse.dateOrNull(original['start_at']),
      originalEndAt: JsonParse.dateOrNull(original['end_at']),
      activeProposal: proposal is Map<String, dynamic>
          ? ReassignmentProposalUiModel.fromJson(proposal)
          : null,
      conversation: JsonParse.mapListValue(
        json['conversation'],
      ).map(ReassignmentMessageUiModel.fromJson).toList(),
    );
  }
}
