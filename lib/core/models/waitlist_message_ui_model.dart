import 'package:waqty_user_application/core/utils/json_parse.dart';

/// مين كاتب الرسالة.
///
/// السيرفر بيبعت `sender_type` خام، والقيم اللي بتوصل للعميل تلاتة:
/// هو، والفرع، والنظام. التالتة دي مش «حد» — دي أحداث دورة الحياة
/// (العرض اتبعت، المهلة عدّت) والفرع بيسجّلها في نفس الخيط.
enum WaitlistMessageSender { customer, branch, system }

extension WaitlistMessageSenderLabel on WaitlistMessageSender {
  /// **مفيش «إنت» هنا** — الاسم بيتحط في الـ widget مش في الموديل، عشان
  /// الموديل مايعرفش مين اللي فاتح الشاشة.
  bool get isMine => this == WaitlistMessageSender.customer;

  bool get isSystem => this == WaitlistMessageSender.system;

  static WaitlistMessageSender fromApi(String? value) => switch (value) {
    'user' || 'customer' => WaitlistMessageSender.customer,
    'system' || 'automation' => WaitlistMessageSender.system,
    // الموظف والفرع والمزود كلهم «الفرع» عند العميل — التفرقة بينهم
    // تفصيلة إدارية مالهاش معنى في شاشة الزبون.
    _ => WaitlistMessageSender.branch,
  };
}

/// رسالة واحدة في خيط قايمة الانتظار.
///
/// ده `booking_waitlist_messages` في السيرفر، والخيط ده هو **أول قناة
/// اتنين في اتنين** بين العميل والفرع في المنتج كله: قبل كده كل حاجة كانت
/// إما مكالمة تليفون أو حالة بتتغيّر من غير كلام.
class WaitlistMessageUiModel {
  final String uuid;
  final WaitlistMessageSender sender;

  /// اسم اللي كتب — snapshot وقت الكتابة، فمابيتغيّرش لو الموظف مشي.
  final String senderName;

  final String body;
  final DateTime createdAt;

  /// حدث دورة حياة مالوش نص — زي «العرض اتبعت» أو «المهلة عدّت».
  ///
  /// `body` بيبقى فاضي فيها، و[displayBody] بيترجم الحدث لجملة.
  final String eventType;

  const WaitlistMessageUiModel({
    required this.uuid,
    required this.sender,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.eventType = '',
  });

  factory WaitlistMessageUiModel.fromJson(Map<String, dynamic> json) {
    return WaitlistMessageUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      sender: WaitlistMessageSenderLabel.fromApi(
        JsonParse.stringValue(json['sender_type']),
      ),
      senderName: JsonParse.stringValue(json['sender_name']),
      body: JsonParse.stringValue(json['body']),
      createdAt: JsonParse.dateValue(json['created_at']),
      eventType: JsonParse.stringValue(
        JsonParse.mapValue(json['metadata'])['event'] ?? json['type'],
      ),
    );
  }

  /// النص المعروض — الرسالة، أو ترجمة الحدث لما تبقى فاضية.
  ///
  /// الداشبورد بيعرض `metadata.event` خام (`offer_sent`) لأن اللي بيقراه
  /// موظف. العميل لازم يقرا جملة.
  String get displayBody {
    if (body.trim().isNotEmpty) return body;

    return switch (eventType) {
      'offer_sent' => 'الفرع عرض عليك ميعاد',
      'offer_accepted' => 'قبلت الميعاد',
      'offer_expired' => 'المهلة عدّت والميعاد راح',
      'change_requested' => 'طلبت ميعاد تاني',
      'rejected' => 'الفرع اعتذر عن الطلب',
      'booked' => 'الطلب اتحوّل لحجز',
      'cancelled' => 'خرجت من القايمة',
      // حدث جديد من السيرفر مالوش ترجمة **مابيتعرضش** — عرض
      // `some_new_event` للعميل أوحش من إن السطر مايبانش.
      _ => '',
    };
  }

  /// يتعرض أصلاً؟ — الحدث اللي مالوش ترجمة ولا نص مالوش لازمة.
  bool get isVisible => displayBody.isNotEmpty;
}
