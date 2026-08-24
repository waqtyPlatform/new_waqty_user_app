import 'package:waqty_user_application/core/utils/json_parse.dart';

/// **صاحب الاستحقاق** — المزوّد والفرع اللي باعوا الباقة أو ولّدوا المتابعة.
///
/// ## ليه ده أهم حقل في الرد كله
///
/// `/public/bookings/available-slots` مفتاحه (فرع، خدمة). من غير الفرع
/// مفيش مواعيد، ومن غير مواعيد مفيش شاشة حجز — يعني باقة العميلة تتعرض
/// وخلاص. الرد كان بيرجّع الصفوف من غير مزوّد ولا فرع، ومكانش فيه أي طريق
/// نستنتجهم بيه من الموبايل: مطابقة الخدمة مش صالحة لأن `Service` مشترك
/// بين مزوّدين بـbelongsToMany.
///
/// نزلوا في BE-A1، ومعاهم `service_uuid` — واللي بيكمّل المفتاح.
class EntitlementOwnerUiModel {
  final String providerUuid;
  final String providerName;
  final String providerLogoUrl;

  final String branchUuid;
  final String branchName;
  final String branchCityName;

  const EntitlementOwnerUiModel({
    this.providerUuid = '',
    this.providerName = '',
    this.providerLogoUrl = '',
    this.branchUuid = '',
    this.branchName = '',
    this.branchCityName = '',
  });

  static const EntitlementOwnerUiModel unknown = EntitlementOwnerUiModel();

  /// عندنا فرع نقدر نجيب مواعيده؟ ده الشرط الوحيد للحجز من التطبيق.
  bool get canResolveSlots => branchUuid.isNotEmpty;

  /// «فرع المعادي · المعادي» — والمدينة بتتشال لو الاسمين واحد، عشان
  /// مايبقاش «المعادي · المعادي».
  String get branchLabel {
    if (branchName.isEmpty) return branchCityName;
    if (branchCityName.isEmpty || branchCityName == branchName) {
      return branchName;
    }
    return '$branchName · $branchCityName';
  }

  factory EntitlementOwnerUiModel.fromJson(Map<String, dynamic> json) {
    final provider = JsonParse.mapValue(json['provider']);
    final branch = JsonParse.mapValue(json['branch']);

    return EntitlementOwnerUiModel(
      providerUuid: JsonParse.stringValue(provider['uuid']),
      providerName: JsonParse.stringValue(provider['name']),
      providerLogoUrl: JsonParse.stringValue(provider['logo_url']),
      branchUuid: JsonParse.stringValue(branch['uuid']),
      branchName: JsonParse.stringValue(branch['name']),
      branchCityName: JsonParse.stringValue(branch['city_name']),
    );
  }
}
