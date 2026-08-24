import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للمكان (صالون/عيادة).
///
/// ملحوظة مقصودة: **مفيش حقل تقييم هنا.** التقييمات مش راجعة من الـ API،
/// وحطّ رقم ثابت زي 4.8 على كل كارت أوحش من إننا منعرضش حاجة — لأن لما
/// التقييم الحقيقي ييجي الناس هتكون اتعلمت إن الرقم ده مالوش لازمة.
///
/// ومفيش حقل «موثّق» كمان: كل المحلات اللي بتظهر في الأبلكيشن متوثّقة
/// أصلاً (السيرفر مابيرجّعش غير المعتمدة)، فشارة على الكل مابتفرّقش حاجة
/// عن حاجة — بتاخد مساحة وبتشوّش من غير ما تضيف معلومة.
class ProviderUiModel {
  final String uuid;
  final String name;
  final String categoryName;
  final String areaName;
  final String imagePath;

  /// بالكيلومتر. بتتحسب في الموبايل من إحداثيات الفرع — مش محتاجة شغل سيرفر.
  final double distanceKm;

  /// أقل سعر خدمة في المكان.
  final double priceFrom;

  final int servicesCount;

  /// نص جاهز للعرض، زي «النهاردة ٤:٣٠ م». فاضي = مفيش مواعيد قريبة.
  final String nextAvailableLabel;

  const ProviderUiModel({
    required this.uuid,
    required this.name,
    required this.categoryName,
    required this.areaName,
    required this.imagePath,
    // ⚠ التلاتة دول بقوا اختياريين — `PublicProviderResource` مابيبعتهمش.
    // الصفر معناه «مش معروف»، و`ProviderRowWidget` بيطوي الجزء بدل ما
    // يعرض «من ٠ ج.م». الفكسشرز الوهمية بتملاهم فبتفضل شغالة زي ما هي.
    this.distanceKm = 0,
    this.priceFrom = 0,
    this.servicesCount = 0,
    this.nextAvailableLabel = '',
  });

  /// `GET /api/public/providers` — الشكل الحقيقي:
  ///
  /// ```json
  /// {"uuid":"01K…","name":"مجمع الفيل",
  ///  "category":{"uuid":"01K…","name":"مجمع عيادات"},
  ///  "main_branch":{"uuid":"01K…","city_name":"المعادي",
  ///                 "latitude":"29.9601000","longitude":"31.2569000",
  ///                 "logo_url":null}}
  /// ```
  ///
  /// ⚠ الإحداثيات **نصوص** مش أرقام — `JsonParse.doubleValue` بيلمّها.
  ///
  /// ⚠ [distanceKm] بتتحسب في الأبلكيشن من إحداثيات الفرع مقابل موقع
  /// العميل. الحساب ده مكانه الـservice (محتاج الموقع الحالي)، فالموديل
  /// بياخدها جاهزة عشان يفضل خالي من أي حالة.
  factory ProviderUiModel.fromJson(
    Map<String, dynamic> json, {
    double distanceKm = 0,
  }) {
    final branch = JsonParse.mapValue(json['main_branch']);
    final category = JsonParse.mapValue(json['category']);

    return ProviderUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      name: JsonParse.localizedValue(json['name']),
      categoryName: JsonParse.localizedValue(category['name']),
      // المنطقة اسمها `city_name` جوّه الفرع الرئيسي، مش على المقدّم.
      areaName: JsonParse.stringValue(branch['city_name']),
      imagePath: JsonParse.stringValue(
        json['logo_url'] ?? branch['logo_url'],
      ),
      distanceKm: distanceKm,
    );
  }

  /// إحداثيات الفرع الرئيسي — بترجّع `null` لو الفرع مالوش موقع.
  ///
  /// بتتستخدم في الـservice عشان يحسب [distanceKm] قبل ما يبني الموديل.
  static ({double latitude, double longitude})? coordinatesOf(
    Map<String, dynamic> json,
  ) {
    final branch = JsonParse.mapValue(json['main_branch']);
    final lat = JsonParse.doubleOrNull(branch['latitude']);
    final lng = JsonParse.doubleOrNull(branch['longitude']);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }
}
