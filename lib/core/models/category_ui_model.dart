import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للتصنيف.
class CategoryUiModel {
  final String uuid;
  final String name;
  final String imagePath;
  final int servicesCount;

  const CategoryUiModel({
    required this.uuid,
    required this.name,
    required this.imagePath,
    this.servicesCount = 0,
  });

  /// `GET /api/public/categories` — الشكل الحقيقي:
  ///
  /// ```json
  /// {"uuid":"01K…","name":"عيادة طبية","image_url":null,
  ///  "requires_specialty":true,"has_subcategories":false,
  ///  "subcategories_count":0,"specialties_count":10,"specialties":[…]}
  /// ```
  ///
  /// ⚠ **مفيش `services_count` في الرد.** الموجود `specialties_count` و
  /// `subcategories_count`، والاتنين بيعدّوا حاجة تانية خالص. فبنسيب
  /// [servicesCount] صفر — والكارت بيطوي سطر العدد لما يبقى صفر.
  factory CategoryUiModel.fromJson(Map<String, dynamic> json) =>
      CategoryUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        name: JsonParse.localizedValue(json['name']),
        // `image_url` بيرجع `null` كتير في الداتا الحالية — الـwidget
        // بيقع على أيقونة التصنيف لما المسار فاضي.
        imagePath: JsonParse.stringValue(json['image_url']),
        servicesCount: JsonParse.intValue(json['services_count']),
      );
}
