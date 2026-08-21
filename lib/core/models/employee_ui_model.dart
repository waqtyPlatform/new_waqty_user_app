import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للأخصائي.
///
/// السعر والمدة هنا **لكل أخصائي**، مش للخدمة — أحمد ممكن يكون أغلى من
/// محمود لنفس القصة. فالعميل لازم يشوف ده قبل ما يختار، مش بعدين.
///
/// مفيش نبذة ولا تقييم — الاتنين مش راجعين من أي endpoint عام.
class EmployeeUiModel {
  final String uuid;
  final String name;
  final String imagePath;
  final double price;
  final int durationMinutes;

  /// خيار «أي أخصائي متاح» — بيتحط أول القايمة وهو الافتراضي.
  final bool isAnyAvailable;

  const EmployeeUiModel({
    required this.uuid,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.durationMinutes,
    this.isAnyAvailable = false,
  });

  /// `GET /api/public/employees?provider_uuid=&branch_uuid=` — الشكل:
  ///
  /// ```json
  /// {"uuid":"01K…","name":"أسماء رمضان","has_app_access":true,
  ///  "logo_url":null,"provider":{…},"branch":{…},
  ///  "services":[{"uuid":"01K…","name":"…","price":"150.00"}]}
  /// ```
  ///
  /// ⚠ **المورد بيفلتر على الموظفين اللي عندهم سعر خدمة فعّال بس** — لو
  /// القايمة رجعت فاضية ده مش بالضرورة معناه مفيش موظفين، ممكن يكون
  /// التسعير ناقص. `available-employees` هو المصدر الصح وقت الحجز.
  ///
  /// [serviceUuid] بيختار السعر والمدة من قايمة خدمات الموظف.
  factory EmployeeUiModel.fromJson(
    Map<String, dynamic> json, {
    String? serviceUuid,
  }) {
    final services = JsonParse.mapListValue(json['services']);
    final match = services.isEmpty
        ? const <String, dynamic>{}
        : services.firstWhere(
            (s) =>
                serviceUuid == null ||
                JsonParse.stringValue(s['uuid']) == serviceUuid,
            orElse: () => services.first,
          );

    return EmployeeUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      name: JsonParse.localizedValue(json['name']),
      imagePath: JsonParse.stringValue(json['logo_url']),
      price: JsonParse.doubleValue(match['price']),
      durationMinutes: JsonParse.intValue(
        match['estimated_duration_minutes'],
      ),
    );
  }

  /// الخيار الافتراضي. السيرفر بيختار الأخصائي لوحده لما نبعتله فاضي.
  static const EmployeeUiModel anyAvailable = EmployeeUiModel(
    uuid: '',
    name: 'أي أخصائي متاح',
    imagePath: '',
    price: 0,
    durationMinutes: 0,
    isAnyAvailable: true,
  );
}
