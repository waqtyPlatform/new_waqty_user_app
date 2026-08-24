import 'package:waqty_user_application/core/models/entitlement_owner_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// قاعدة الأخصائي في المتابعة — بتيجي من `services.follow_up_employee_rule`.
enum FollowUpEmployeeRule {
  /// أي حد متاح.
  any,

  /// **نفس الأخصائي إجباري** — مفيش اختيار، والصف بيتقفل.
  sameRequired,

  /// نفس الأخصائي مفضّل بس مش إجباري.
  samePreferred,
}

extension FollowUpEmployeeRuleParse on FollowUpEmployeeRule {
  static FollowUpEmployeeRule fromApi(String? value) => switch (value) {
    'same_employee_required' => FollowUpEmployeeRule.sameRequired,
    'same_employee_preferred' => FollowUpEmployeeRule.samePreferred,
    _ => FollowUpEmployeeRule.any,
  };
}

/// متابعة مستحقة — **مش باقة**.
///
/// بتتولد لوحدها لما خدمة تخلص، لو الخدمة مفعّل عليها `follow_up_enabled`.
/// يعني العميلة ماشترتهاش — استحقّتها. وده بيغيّر النبرة: الكارت بيقول
/// «ليكي متابعة» مش «عندك رصيد».
///
/// ## الحجز
///
/// من BE-A1 الصف نفسه بيقول `provider` و`branch` و`service_uuid`، فالمواعيد
/// بتتجاب على طول. قبل كده كان لازم نداء زيادة على
/// `GET /user/bookings/{original_booking_uuid}` عشان نطلّع الفرع من snapshots
/// الحجز — النداء ده اتشال.
class FollowUpEntitlementUiModel {
  final String uuid;
  final String serviceName;

  /// الحجز اللي ولّد المتابعة — بيربطها بأصلها في الواجهة. **مابقاش الطريق
  /// للفرع**؛ الفرع في [owner].
  final String originalBookingUuid;

  /// المزوّد والفرع اللي ولّدوا المتابعة.
  final EntitlementOwnerUiModel owner;

  /// الخدمة اللي المواعيد بتتجاب لها.
  final String serviceUuid;

  final int durationMinutes;

  final DateTime? validFrom;
  final DateTime? validUntil;

  final int allowedCount;
  final int completedCount;
  final int reservedCount;
  final int availableCount;

  /// `free` أو `discounted` أو `full`.
  final String priceType;

  /// السعر الفعلي بعد الخصم. صفر = مجانية.
  final num effectivePrice;

  final FollowUpEmployeeRule employeeRule;

  /// الأخصائي المربوطة بيه. `null` = مفيش، أو ساب الشغل.
  final FollowUpEmployeeUiModel? employee;

  final PackageStatus status;

  const FollowUpEntitlementUiModel({
    required this.uuid,
    required this.serviceName,
    required this.status,
    this.originalBookingUuid = '',
    this.owner = EntitlementOwnerUiModel.unknown,
    this.serviceUuid = '',
    this.durationMinutes = 0,
    this.validFrom,
    this.validUntil,
    this.allowedCount = 0,
    this.completedCount = 0,
    this.reservedCount = 0,
    this.availableCount = 0,
    this.priceType = 'free',
    this.effectivePrice = 0,
    this.employeeRule = FollowUpEmployeeRule.any,
    this.employee,
  });

  bool get isFree => effectivePrice <= 0;

  bool get isDiscounted => priceType == 'discounted' && effectivePrice > 0;

  /// الأخصائي إجباري وهو **مش موجود**.
  ///
  /// السيرفر بيرجّع `employee: null` لما الأخصائي يمشي (`employment_status`
  /// مابقاش `active`). ساعتها القاعدة بتقول «نفس الأخصائي» والأخصائي
  /// مالوش وجود — يعني الشرط مستحيل يتحقق.
  ///
  /// ## BE-A5 اتقفل: **تفضل متعطّلة والعميلة تتوجّه للفرع**
  ///
  /// وده مش تحفّظ من الواجهة — ده اللي السيرفر بيفرضه أصلاً.
  /// `FollowUpService::bookFromEntitlement` **بيتجاهل** `employee_uuid` اللي
  /// في الطلب لما القاعدة `same_employee_required`، وبياخد بتاع الاستحقاق
  /// نفسه — ولو `null` بيرمي 422 «The original employee is required for this
  /// follow-up».
  ///
  /// يعني ترخية الزرار من عندنا كانت هتخلّي العميلة تختار يوم وميعاد وتاخد
  /// خطأ سيرفر في آخر خطوة. المنع هنا **بيقول الحقيقة بدري**.
  bool get isOrphaned =>
      employeeRule == FollowUpEmployeeRule.sameRequired && employee == null;

  /// المتابعة قابلة للحجز من التطبيق؟
  ///
  /// نفس شرط الباقة: فرع وخدمة نجيب بيهم المواعيد — زائد إن الأخصائي
  /// المطلوب موجود لو القاعدة بتلزمه.
  bool get isBookableFromApp =>
      status == PackageStatus.active &&
      availableCount > 0 &&
      owner.canResolveSlots &&
      serviceUuid.isNotEmpty &&
      !isOrphaned;

  /// السبب اللي بيتعرض لما الحجز مقفول ومفيش زرار.
  ///
  /// ⚠ **زرار متعطّل من غير سبب أوحش من مفيش زرار** — العميلة بتدوس وتدوس
  /// وتفتكر إن التطبيق باظ. فالقاعدة: أي منع **مش باين في الكارت** لازم
  /// يتقال بالنص.
  ///
  /// `null` = المنع باين أصلاً. الحالة النهائية شارتها بتتكلم،
  /// و`available_count == 0` الكارت بيقول عليها «اتستخدمت».
  String? get blockedReason {
    if (status.isTerminal) return null;
    if (isBookableFromApp) return null;
    if (isOrphaned) {
      return 'الأخصائي بتاع المتابعة مابقاش متاح — كلّم الفرع عشان يظبطلك ميعاد';
    }
    if (!owner.canResolveSlots || serviceUuid.isEmpty) {
      return 'مش قادرين نجيب مواعيد الفرع دلوقتي — كلّم الفرع للحجز';
    }
    return null;
  }

  /// باقي على انتهاء الصلاحية كام يوم؟
  int? daysUntilExpiry({DateTime? now}) {
    final until = validUntil;
    if (until == null) return null;
    return until.difference(now ?? DateTime.now()).inDays;
  }

  factory FollowUpEntitlementUiModel.fromJson(Map<String, dynamic> json) {
    final employee = JsonParse.mapValue(json['employee']);

    return FollowUpEntitlementUiModel(
      uuid: JsonParse.stringValue(json['uuid']),
      serviceName: JsonParse.stringValue(json['service_name']),
      originalBookingUuid: JsonParse.stringValue(json['original_booking_uuid']),
      owner: EntitlementOwnerUiModel.fromJson(json),
      serviceUuid: JsonParse.stringValue(json['service_uuid']),
      durationMinutes: JsonParse.intValue(json['duration_minutes']),
      validFrom: JsonParse.dateOrNull(json['valid_from']),
      validUntil: JsonParse.dateOrNull(json['valid_until']),
      allowedCount: JsonParse.intValue(json['allowed_count']),
      completedCount: JsonParse.intValue(json['completed_count']),
      reservedCount: JsonParse.intValue(json['reserved_count']),
      availableCount: JsonParse.intValue(json['available_count']),
      priceType: JsonParse.stringValue(json['price_type'], fallback: 'free'),
      effectivePrice: JsonParse.doubleValue(json['effective_price']),
      employeeRule: FollowUpEmployeeRuleParse.fromApi(
        JsonParse.stringValue(json['employee_rule']),
      ),
      employee: employee.isEmpty
          ? null
          : FollowUpEmployeeUiModel.fromJson(employee),
      status: PackageStatusLabel.fromApi(JsonParse.stringValue(json['status'])),
    );
  }
}

/// الأخصائي المربوطة بيه المتابعة — اسم و uuid وبس، ده كل اللي السيرفر
/// بيبعته.
class FollowUpEmployeeUiModel {
  final String uuid;
  final String name;

  const FollowUpEmployeeUiModel({required this.uuid, required this.name});

  factory FollowUpEmployeeUiModel.fromJson(Map<String, dynamic> json) =>
      FollowUpEmployeeUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        name: JsonParse.stringValue(json['name']),
      );
}
