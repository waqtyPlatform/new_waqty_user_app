import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للفرع.
///
/// العنوان والتليفون ومواعيد العمل السيرفر عنده الداتا بتاعتهم بس مش
/// بيرجّعهم في الـ payload العام لسه — فدلوقتي جايين من الـ mock.
class BranchUiModel {
  final String uuid;
  final String name;
  final String areaName;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double distanceKm;

  /// «مفتوح · يقفل ٩:٠٠ م» أو «مغلق · يفتح غدًا ٩:٠٠ ص»
  final String openStatusLabel;
  final bool isOpenNow;

  /// ٧ أيام بالترتيب من الاثنين. اليوم المقفول بيبقى فيه «مغلق».
  final List<BranchWorkingDay> workingHours;

  const BranchUiModel({
    required this.uuid,
    required this.name,
    required this.areaName,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0,
    this.openStatusLabel = '',
    this.isOpenNow = false,
    this.workingHours = const <BranchWorkingDay>[],
  });

  /// `GET /api/public/provider-branches` — الشكل الحقيقي:
  ///
  /// ```json
  /// {"uuid":"01K…","name":"المقر الرئيسي — المعادي","city_name":"المعادي",
  ///  "country_name":"مصر","latitude":"29.9601000","longitude":"31.2569000"}
  /// ```
  ///
  /// ⚠ **الإحداثيات نصوص مش أرقام.**
  ///
  /// ⚠ **ناقص من الرد: `address` و`phone` وساعات العمل.** المورد مابيبعتش
  /// أي واحدة فيهم — وساعات العمل موجودة في الباك-إند وبتحرّك المواعيد
  /// المتاحة، بس مش معروضة كنص. الحقول بتفضل فاضية والـwidgets بتطوي
  /// السطر، لحد ما `PublicProviderBranchResource` يتوسّع (شغل باك-إند).
  factory BranchUiModel.fromJson(
    Map<String, dynamic> json, {
    double distanceKm = 0,
  }) => BranchUiModel(
    uuid: JsonParse.stringValue(json['uuid']),
    name: JsonParse.localizedValue(json['name']),
    areaName: JsonParse.stringValue(json['city_name']),
    address: JsonParse.stringValue(json['address']),
    phone: JsonParse.stringValue(json['phone']),
    latitude: JsonParse.doubleValue(json['latitude']),
    longitude: JsonParse.doubleValue(json['longitude']),
    distanceKm: distanceKm,
  );
}

class BranchWorkingDay {
  final String dayName;
  final String hoursLabel;
  final bool isClosed;
  final bool isToday;

  const BranchWorkingDay({
    required this.dayName,
    required this.hoursLabel,
    this.isClosed = false,
    this.isToday = false,
  });
}
