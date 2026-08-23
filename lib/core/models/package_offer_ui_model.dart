import 'package:waqty_user_application/core/utils/json_parse.dart';

/// شكل الباقة — نفس تقسيمة السيرفر (`package_type`).
enum PackageOfferType { singleVisit, multiSession, usageBased }

extension PackageOfferTypeParse on PackageOfferType {
  static PackageOfferType fromApi(String? value) => switch (value) {
    'multi_session' => PackageOfferType.multiSession,
    'usage_based' => PackageOfferType.usageBased,
    _ => PackageOfferType.singleVisit,
  };
}

/// خدمة جوّه باقة معروضة — الاسم والمدة وبس.
class PackageOfferServiceUiModel {
  const PackageOfferServiceUiModel({
    required this.uuid,
    required this.name,
    this.durationMinutes = 0,
  });

  final String uuid;
  final String name;
  final int durationMinutes;

  factory PackageOfferServiceUiModel.fromJson(Map<String, dynamic> json) =>
      PackageOfferServiceUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        name: JsonParse.stringValue(json['name']),
        durationMinutes: JsonParse.intValue(json['duration_minutes']),
      );
}

/// **باقة معروضة للبيع** عند فرع — مش باقة العميلة.
///
/// ## ليه دي كلاس لوحدها مش [PackageEntitlementUiModel]
///
/// الاتنين اسمهم «باقة» وبس. اللي العميلة **شارياها** عنده عدّادات:
/// متاح ومحجوز ومستخدم وتاريخ انتهاء بدأ يعدّ. اللي **معروضة** مالهاش
/// ولا واحدة منهم — لسه محدش اشتراها.
///
/// ⚠ **ولا فيه sealed split هنا.** الاستحقاق اتقسم `Session` و`Usage`
/// لأن العدّادات نفسها مختلفة (جلسات مقابل وحدات) والشريط بيرسمهم
/// مختلفين. هنا الشكل بيغيّر **سطر واحد** — «إيه اللي بتاخده» — فالتقسيم
/// كان هيدّي نوعين متطابقين إلا في `switch` واحدة. والسطر ده بيتكتب في
/// الـwidget لأنه عرض، و`AppFormat` عايش هناك.
///
/// ماينفعش يترسم بكارت الاستحقاق: الكارت بيقرا `availableSessions`،
/// وباقة معروضة هتقول «فاضل ٨ جلسات» لحاجة محدش دفع فيها.
class PackageOfferUiModel {
  const PackageOfferUiModel({
    required this.uuid,
    required this.name,
    required this.type,
    this.description = '',
    this.imageUrl,
    this.basePrice = 0,
    this.effectivePrice = 0,
    this.hasOffer = false,
    this.offerEndsAt,
    this.sessionsIncluded,
    this.durationMinutes,
    this.unitName,
    this.initialUnits,
    this.validityDays,
    this.availableUntil,
    this.services = const <PackageOfferServiceUiModel>[],
    this.providerUuid = '',
    this.providerName = '',
    this.branchUuid = '',
    this.branchName = '',
  });

  final String uuid;
  final String name;
  final String description;
  final PackageOfferType type;
  final String? imageUrl;

  /// السعر قبل أي عرض.
  final num basePrice;

  /// السعر اللي هتدفعه دلوقتي — نفس [basePrice] لو مفيش عرض.
  final num effectivePrice;

  final bool hasOffer;

  /// آخر يوم في العرض. **بيتقال دايمًا لما يبقى فيه عرض** — خصم من غير
  /// تاريخ بيقرا دايم، واللي ترجع الشهر الجاي تلاقي رقم تاني.
  final DateTime? offerEndsAt;

  /// `multi_session` بس. `null` على الأشكال التانية — مش صفر، عشان
  /// الواجهة ماتقولش «٠ جلسات» على بركة.
  final int? sessionsIncluded;

  final int? durationMinutes;

  /// `usage_based` بس — «دقيقة» / «جلسة».
  final String? unitName;

  final int? initialUnits;

  final int? validityDays;

  /// آخر يوم الباقة معروضة فيه (`date_range`). `null` = معروضة على طول.
  final DateTime? availableUntil;

  final List<PackageOfferServiceUiModel> services;

  final String providerUuid;
  final String providerName;
  final String branchUuid;
  final String branchName;

  /// وفّرت كام. صفر = مفيش عرض.
  num get savings =>
      hasOffer && basePrice > effectivePrice ? basePrice - effectivePrice : 0;

  factory PackageOfferUiModel.fromJson(Map<String, dynamic> json) {
    final provider = JsonParse.mapValue(json['provider']);
    final branch = JsonParse.mapValue(json['branch']);

    return PackageOfferUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      name: JsonParse.stringValue(json['name']),
      description: JsonParse.stringValue(json['description']),
      type: PackageOfferTypeParse.fromApi(
        JsonParse.stringValue(json['package_type']),
      ),
      imageUrl: JsonParse.stringValue(json['image_url']).isEmpty
          ? null
          : JsonParse.stringValue(json['image_url']),
      basePrice: JsonParse.doubleValue(json['base_price']),
      effectivePrice: JsonParse.doubleValue(json['effective_price']),
      hasOffer: JsonParse.boolValue(json['has_offer']),
      offerEndsAt: JsonParse.dateOrNull(json['offer_ends_at']),
      sessionsIncluded: JsonParse.intOrNull(json['sessions_included']),
      durationMinutes: JsonParse.intOrNull(json['duration_minutes']),
      unitName: JsonParse.stringValue(json['unit_name']).isEmpty
          ? null
          : JsonParse.stringValue(json['unit_name']),
      initialUnits: JsonParse.intOrNull(json['initial_units']),
      validityDays: JsonParse.intOrNull(json['validity_days']),
      availableUntil: JsonParse.dateOrNull(json['available_until']),
      services: JsonParse.mapListValue(
        json['services'],
      ).map(PackageOfferServiceUiModel.fromJson).toList(),
      providerUuid: JsonParse.stringValue(provider['uuid']),
      providerName: JsonParse.stringValue(provider['name']),
      branchUuid: JsonParse.stringValue(branch['uuid']),
      branchName: JsonParse.stringValue(branch['name']),
    );
  }
}
