import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للخدمة.
///
/// [isCategory] بيفرّق بين صف تصنيف (بيفتح قايمة تحته) وصف خدمة حقيقية
/// (بيفتح الحجز). دلوقتي في التصميم القديم الاتنين شكلهم واحد، فالعميل
/// مش عارف أنهي واحد فيهم بيحجز.
class ServiceUiModel {
  final String uuid;
  final String name;
  final double price;
  final int durationMinutes;
  final bool isCategory;

  /// التصنيف اللي الخدمة دي تحته — `null` يعني خدمة من المستوى الأول.
  ///
  /// **من غير الحقل ده كان التصنيف بيكدب.** «صبغة · 11 خدمة» كانت
  /// بتفتح مختار الخدمات على **كل** خدمات المحل، لأن مكانش فيه أي رابط
  /// بين التصنيف وولاده — الـ 11 كانت رقم مكتوب بالإيد ومالوش وجود.
  final String? parentUuid;

  const ServiceUiModel({
    required this.uuid,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.isCategory = false,
    this.parentUuid,
  });

  /// `GET /api/public/services?provider_uuid=&branch_uuid=` — الشكل الحقيقي:
  ///
  /// ```json
  /// {"uuid":"01K…","name":"كشف باطنة","description":"…","image_url":null,
  ///  "sub_category_uuid":null,"sub_category_name":null,"category":null,
  ///  "providers":[{"uuid":"01K…","name":"مجمع الفيل","default_price":null,
  ///                "estimated_duration_minutes":30, …}]}
  /// ```
  ///
  /// ⚠ **السعر والمدة جوّه `providers[]` مش على الخدمة.** نفس الخدمة عند
  /// مقدّمين مختلفين بسعر مختلف، فالمورد بيرجّعها مرة واحدة بقايمة عروض.
  /// [providerUuid] بيختار العرض الصح؛ من غيره بناخد أول واحد.
  ///
  /// ⚠ **`default_price` بيرجع `null` كتير** — السعر الحقيقي بيتحلّ من
  /// `GET /api/public/service-pricing/services/{uuid}/price` لأنه بيعتمد
  /// على الفرع والأخصائي (مجموعات التسعير). فالسعر هنا مبدئي.
  factory ServiceUiModel.fromJson(
    Map<String, dynamic> json, {
    String? providerUuid,
    double? resolvedPrice,
  }) {
    final offers = JsonParse.mapListValue(json['providers']);
    final offer = offers.isEmpty
        ? const <String, dynamic>{}
        : offers.firstWhere(
            (o) =>
                providerUuid == null ||
                JsonParse.stringValue(o['uuid']) == providerUuid,
            orElse: () => offers.first,
          );

    return ServiceUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      // الاسم ممكن يتغطّى من العرض (`service_name`) لو المقدّم سمّاها بنفسه.
      name: JsonParse.localizedValue(
        offer['service_name'] ?? json['name'],
        fallback: JsonParse.localizedValue(json['name']),
      ),
      price: resolvedPrice ?? JsonParse.doubleValue(offer['default_price']),
      durationMinutes: JsonParse.intValue(
        offer['estimated_duration_minutes'],
      ),
      parentUuid: JsonParse.stringValue(json['sub_category_uuid']).isEmpty
          ? null
          : JsonParse.stringValue(json['sub_category_uuid']),
    );
  }
}
