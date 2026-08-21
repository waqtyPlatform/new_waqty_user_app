import 'package:waqty_user_application/core/utils/json_parse.dart';

/// اللي الأبلكيشن لازم يعمله قبل ما يكمّل.
enum AppGateAction {
  /// كمّل عادي.
  none,

  /// السيرفر تحت الصيانة — **حاجز مايتقفلش**.
  maintenance,

  /// تحديث إجباري — **حاجز مايتقفلش**.
  forceUpdate,

  /// تحديث اختياري — بيتعرض ويتقفل.
  optionalUpdate,

  /// بانر إعلاني — بيتعرض ومابيوقفش حاجة.
  banner,
}

/// رد `GET /api/v1/app/gate`.
///
/// ⚠ **بيتنادى قبل فحص الجلسة في السبلاش.** تحديث إجباري أو صيانة معناهم
/// إن الأبلكيشن مايكملش أصلاً — فمفيش لزمة نجيب توكن ولا نحمّل رئيسية.
///
/// ⚠ **فشل النداء = كمّل عادي.** لو السيرفر مردّش، إحنا مش متأكدين إن فيه
/// صيانة — والافتراض بالحاجز بيقفل الأبلكيشن على كل الناس أول ما الشبكة
/// تتهزهز. الفشل بيتبلع والأبلكيشن بيكمّل.
class AppGateUiModel {
  final AppGateAction action;

  /// عنوان ورسالة الحاجز — بالعربي لو موجود.
  final String title;
  final String message;

  /// لينك المتجر للتحديث.
  final String storeUrl;

  /// آخر نسخة متاحة — بتتعرض في نص التحديث.
  final String latestVersion;

  const AppGateUiModel({
    this.action = AppGateAction.none,
    this.title = '',
    this.message = '',
    this.storeUrl = '',
    this.latestVersion = '',
  });

  /// **الأبلكيشن مايكملش.** الحوار غير قابل للإغلاق.
  bool get isBlocking =>
      action == AppGateAction.maintenance || action == AppGateAction.forceUpdate;

  /// المستخدم لازم يشوف حاجة (حاجز أو تحديث اختياري أو بانر).
  bool get hasSomethingToShow => action != AppGateAction.none;

  /// الشكل الحقيقي من `AppGateService::evaluate`:
  ///
  /// ```json
  /// {"server_time":"…","app":"user","platform":"android",
  ///  "current_version":"1.0.0","primary_action":"none","bypassed":false,
  ///  "update":{"status":"none","latest_version":"1.0.0","store_url":null,
  ///            "release_notes":{"ar":null,"en":null}, …},
  ///  "maintenance":{"active":false,"title":{"ar":null,"en":null}, …},
  ///  "banner":{"active":false,"message":{"ar":null,"en":null},"link":null}}
  /// ```
  ///
  /// ⚠ **العناوين والرسايل خرايط `{ar, en}` بقيم `null`** — مش نصوص.
  /// `JsonParse.localizedValue` بيلمّ ده.
  factory AppGateUiModel.fromJson(Map<String, dynamic> json) {
    final maintenance = JsonParse.mapValue(json['maintenance']);
    final update = JsonParse.mapValue(json['update']);
    final banner = JsonParse.mapValue(json['banner']);

    final action = switch (JsonParse.stringValue(json['primary_action'])) {
      'maintenance' => AppGateAction.maintenance,
      'force_update' => AppGateAction.forceUpdate,
      'optional_update' => AppGateAction.optionalUpdate,
      'banner' => AppGateAction.banner,
      _ => AppGateAction.none,
    };

    final (title, message) = switch (action) {
      AppGateAction.maintenance => (
        JsonParse.localizedValue(
          maintenance['title'],
          fallback: 'الخدمة تحت الصيانة',
        ),
        JsonParse.localizedValue(
          maintenance['message'],
          fallback: 'بنظبّط حاجات، ارجعلنا كمان شوية.',
        ),
      ),
      AppGateAction.forceUpdate || AppGateAction.optionalUpdate => (
        'فيه نسخة جديدة',
        JsonParse.localizedValue(
          update['release_notes'],
          fallback: 'حدّث الأبلكيشن عشان تكمّل.',
        ),
      ),
      AppGateAction.banner => (
        '',
        JsonParse.localizedValue(banner['message']),
      ),
      AppGateAction.none => ('', ''),
    };

    return AppGateUiModel(
      action: action,
      title: title,
      message: message,
      storeUrl: JsonParse.stringValue(update['store_url']),
      latestVersion: JsonParse.stringValue(update['latest_version']),
    );
  }
}
