import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة الدفعة — من ألفاظ السيرفر.
enum PaymentStatusUi { pending, completed, failed, refunded, unknown }

extension PaymentStatusUiLabel on PaymentStatusUi {
  static PaymentStatusUi fromApi(String? value) => switch (value) {
    'pending' => PaymentStatusUi.pending,
    'completed' => PaymentStatusUi.completed,
    'failed' => PaymentStatusUi.failed,
    'refunded' => PaymentStatusUi.refunded,
    _ => PaymentStatusUi.unknown,
  };

  String get label => switch (this) {
    PaymentStatusUi.pending => 'مستنية',
    PaymentStatusUi.completed => 'اتدفعت',
    PaymentStatusUi.failed => 'فشلت',
    PaymentStatusUi.refunded => 'اترجّعت',
    PaymentStatusUi.unknown => '—',
  };
}

/// دفعة على حجز.
///
/// ⚠ **للقراية بس.** `/api/user/payments` فيه `index` و`show` وخلاص —
/// **مفيش `create`**. الأبلكيشن مايقدرش ياخد فلوس؛ الدفع بيتسجّل من الفرع.
/// أي دفع داخل الأبلكيشن مشروع PSP مستقل.
class PaymentUiModel {
  final String uuid;
  final String method;
  final double amount;
  final PaymentStatusUi status;
  final String transactionId;
  final String notes;
  final DateTime createdAt;

  final String bookingUuid;
  final DateTime? bookingDate;

  const PaymentUiModel({
    required this.uuid,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.method = '',
    this.transactionId = '',
    this.notes = '',
    this.bookingUuid = '',
    this.bookingDate,
  });

  /// اسم طريقة الدفع بالعربي — السيرفر بيبعت المفتاح الإنجليزي.
  String get methodLabel => switch (method) {
    'cash' => 'كاش',
    'card' => 'كارت',
    'online' => 'أونلاين',
    'paymob' => 'أونلاين',
    _ => method.isEmpty ? '—' : method,
  };

  /// `GET /api/user/payments` — الشكل الحقيقي:
  ///
  /// ```json
  /// {"uuid":"01K…","payment_method":"cash","amount":"96.00",
  ///  "status":"completed","transaction_id":null,"notes":"…",
  ///  "booking":{"uuid":"01K…","booking_date":"2026-08-10",
  ///             "start_time":"09:00:00","status":"confirmed"},
  ///  "created_at":"2026-08-08T22:57:38+03:00"}
  /// ```
  ///
  /// ⚠ `amount` **نص** `"96.00"`، و`transaction_id` بيرجع `null` كتير.
  factory PaymentUiModel.fromJson(Map<String, dynamic> json) {
    final booking = JsonParse.mapValue(json['booking']);

    return PaymentUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      method: JsonParse.stringValue(json['payment_method']),
      amount: JsonParse.doubleValue(json['amount']),
      status: PaymentStatusUiLabel.fromApi(
        JsonParse.stringValue(json['status']),
      ),
      transactionId: JsonParse.stringValue(json['transaction_id']),
      notes: JsonParse.stringValue(json['notes']),
      createdAt: JsonParse.dateValue(json['created_at']),
      bookingUuid: JsonParse.stringValue(booking['uuid']),
      bookingDate: JsonParse.dateOrNull(booking['booking_date']),
    );
  }
}
