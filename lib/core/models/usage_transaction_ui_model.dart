import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حركة واحدة في دفتر الوحدات — **دفتر أستاذ مش سجل أحداث**.
///
/// كل صف بيحمل الرصيد قبله وبعده، فالعميلة تقدر تتابع الحسبة سطر بسطر
/// من غير ما تجمع بإيدها. ودي الحاجة اللي بتخلي «فاضل ١٢٠ دقيقة» قابلة
/// للتصديق: الرقم مش بيظهر لوحده، بيظهر وراه من فين جه.
class UsageTransactionUiModel {
  final String uuid;

  /// نوع الحركة زي ما السيرفر كاتبها (`consume` · `refund` · `expire` …).
  final String type;

  /// الوحدات اللي اتحرّكت — **موجبة دايمًا**، والاتجاه من [type].
  final int units;

  final int balanceBefore;
  final int balanceAfter;

  /// سبب حر من الموظف. ممكن يبقى فاضي.
  final String reason;

  final DateTime? createdAt;

  const UsageTransactionUiModel({
    required this.uuid,
    required this.type,
    required this.units,
    this.balanceBefore = 0,
    this.balanceAfter = 0,
    this.reason = '',
    this.createdAt,
  });

  /// الرصيد نقص؟ — بنقارن الرصيدين بدل ما نفسّر [type]، عشان أي نوع جديد
  /// السيرفر يضيفه يتعرض صح من غير تعديل هنا.
  bool get isDebit => balanceAfter < balanceBefore;

  factory UsageTransactionUiModel.fromJson(Map<String, dynamic> json) =>
      UsageTransactionUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        type: JsonParse.stringValue(json['type']),
        units: JsonParse.intValue(json['units']),
        balanceBefore: JsonParse.intValue(json['balance_before']),
        balanceAfter: JsonParse.intValue(json['balance_after']),
        reason: JsonParse.stringValue(json['reason']),
        createdAt: JsonParse.dateOrNull(json['created_at']),
      );
}
