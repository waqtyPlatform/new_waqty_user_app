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
/// ## الفرق الجوهري عن الباقة: **دي بتتحجز فعلاً**
///
/// الباقة مالهاش طريق للفرع (BLOCKER-1)، بس المتابعة عندها
/// [originalBookingUuid] — و`GET /user/bookings/{uuid}` بيرجّع `branch`
/// و`provider` من الـ snapshots (`BookingCreationService:72-78` بيأكّد إن
/// `branch_snapshot` فيه `uuid`). فمنها بنجيب الفرع، ومن الفرع بنجيب
/// المواعيد.
///
/// TODO(api): BE-A1 — أول ما `branch` ينزل في صف المتابعة نفسه، النداء
/// الزيادة ده يتشال.
class FollowUpEntitlementUiModel {
  final String uuid;
  final String serviceName;

  /// الحجز اللي ولّد المتابعة — **الطريق الوحيد للفرع دلوقتي**.
  final String originalBookingUuid;

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

  /// الأخصائي إجباري وهو **مش موجود** — الحالة اللي BE-A5 لسه مجاوبهاش.
  ///
  /// السيرفر بيرجّع `employee: null` لما الأخصائي يمشي (`employment_status`
  /// مابقاش `active`). ساعتها القاعدة بتقول «نفس الأخصائي» والأخصائي
  /// مالوش وجود — يعني الشرط مستحيل يتحقق.
  ///
  /// ⚠ **مابنرخّيهاش من عندنا.** لو رخّينا لأي حد، ممكن نحط مريضة مع دكتور
  /// تاني في متابعة طبية — قرار مش بتاعنا. فالحجز بيتقفل والعميلة بتتوجّه
  /// للفرع لحد ما BE-A5 يتقرر.
  bool get isOrphaned =>
      employeeRule == FollowUpEmployeeRule.sameRequired && employee == null;

  /// المتابعة قابلة للحجز من التطبيق؟
  ///
  /// على عكس الباقة، دي **بتشتغل فعلاً** — بشرط إن فيه حجز أصلي نوصل منه
  /// للفرع، والأخصائي المطلوب موجود.
  bool get isBookableFromApp =>
      status == PackageStatus.active &&
      availableCount > 0 &&
      originalBookingUuid.isNotEmpty &&
      !isOrphaned;

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
