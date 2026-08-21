import 'package:waqty_user_application/core/utils/json_parse.dart';

/// نتيجة تأكيد الرقم — **اللي ظهر فعلاً، بأرقام السيرفر**.
///
/// ## ليه الموديل ده موجود
///
/// تأكيد الرقم مش إجراء أمني بس — ده **الفعل اللي بيوصّل العميلة بالسجلات
/// اللي الريسبشن عملها من رقم تليفون**. `verify-phone` بينادي
/// `LinkProviderCustomersToPlatformUserAction` جوه ترانزاكشن، واللي بيعمل
/// تلات حاجات:
///
///  1. بيدوّر على كل `provider_customers` بنفس `normalized_phone` وبيحط
///     `platform_user_id` بتاعها → [linked]
///  2. بيرجّع الحجوزات القديمة للحساب ده → [relinkedBookings]
///  3. بيعطّل الحسابات الوهمية اللي كانت ماسكة الرقم → [superseded]
///
/// فالرد **مش `{success: true}`** — الرد بيقول كام سجل اتحرّك. وده اللي
/// بيخلّي الباند بعد النجاح يقول حاجة حقيقية بدل «تم التأكيد» الفاضية.
///
/// ⚠ **[linked] بيعدّ سجلات عملاء مش باقات.** عميلة واحدة عند مزوّد واحد
/// معاها تلات باقات = `linked: 1`. عشان كده عدد الباقات بييجي من **إعادة
/// تحميل** الـentitlements بعد النجاح، مش من هنا.
class PhoneClaimResultUiModel {
  /// سجلات `provider_customers` اللي اترّبطت بالحساب.
  final int linked;

  /// حجوزات قديمة رجعت للحساب.
  final int relinkedBookings;

  /// حسابات وهمية اتعطّلت عشان كانت ماسكة الرقم.
  final int superseded;

  /// تعارضات — الرقم على حساب **حقيقي** تاني.
  ///
  /// لما بيبقى > 0 السيرفر بيرمي 422 **قبل** ما يربط أي حاجة، فالموديل ده
  /// مابيوصلش أصلاً في الحالة دي. موجود عشان الشكل يفضل كامل ولو الباك إند
  /// قرّر يرجّعه بدل ما يرمي.
  final int conflicts;

  const PhoneClaimResultUiModel({
    this.linked = 0,
    this.relinkedBookings = 0,
    this.superseded = 0,
    this.conflicts = 0,
  });

  /// اتحرّك أي حاجة أصلاً؟
  ///
  /// `false` = التأكيد نجح بس **مالقاش سجلات**. الحالة دي شرعية تمامًا
  /// (عميلة جديدة ما اشترتش من الفرع)، ولازم يبقى ليها نص محايد — مش
  /// «ظهرلك ٠ حجوزات».
  bool get foundAnything => linked > 0 || relinkedBookings > 0;

  /// `POST /api/user/auth/verify-phone` → `data`.
  ///
  /// ```json
  /// {"linked":2,"relinked_bookings":3,"superseded":1,"conflicts":0}
  /// ```
  factory PhoneClaimResultUiModel.fromJson(Map<String, dynamic> json) =>
      PhoneClaimResultUiModel(
        linked: JsonParse.intValue(json['linked']),
        relinkedBookings: JsonParse.intValue(json['relinked_bookings']),
        superseded: JsonParse.intValue(json['superseded']),
        conflicts: JsonParse.intValue(json['conflicts']),
      );
}
