import 'package:waqty_user_application/core/models/usage_transaction_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// حالة الباقة — **محسوبة على السيرفر، بتتقرا هنا وبس**.
///
/// `CustomerPackagePurchase::effectiveStatus()` بيحسب الانتهاء والاستهلاك
/// من التواريخ والأرصدة. لو الموبايل حسبها تاني، ساعة الجهاز الغلط أو
/// منطقة زمنية مختلفة بيخلّوا باقة شغّالة تبان منتهية — ودي خسارة فلوس
/// حقيقية في عين العميلة.
enum PackageStatus { active, completed, expired, cancelled }

extension PackageStatusLabel on PackageStatus {
  String get label => switch (this) {
    PackageStatus.active => '',
    PackageStatus.completed => 'خلصت',
    PackageStatus.expired => 'انتهت',
    PackageStatus.cancelled => 'اتلغت',
  };

  /// الحالات اللي الكارت بيتعرض فيها باهت من غير أي فعل.
  bool get isTerminal => this != PackageStatus.active;

  static PackageStatus fromApi(String? value) => switch (value) {
    'active' => PackageStatus.active,
    'completed' => PackageStatus.completed,
    'expired' => PackageStatus.expired,
    'cancelled' => PackageStatus.cancelled,
    _ => PackageStatus.active,
  };
}

/// باقة اشترتها العميلة من الفرع.
///
/// ## ليه `sealed` بنوعين
///
/// الباقات تلات أنواع على السيرفر (`multi_session` · `single_visit` ·
/// `usage_based`) بس **شكلين داتا مختلفين تمامًا**: الأولين بيتعدّوا
/// بالجلسات، والتالت ببركة وحدات ليها دفتر وخدمات مسموحة.
///
/// النوعين لو اتلمّوا في كلاس واحد بحقول nullable، هيبقى ممكن — بل سهل —
/// إن كارت الوحدات يقول «فاضل ٤ جلسات» أو كارت الجلسات يقول «وحدات».
/// الـ`sealed` بيخلّي ده **مستحيل يتكتب** بدل ما يبقى غلطة تتلقط في
/// المراجعة.
///
/// ⚠ **مافيش `provider` ولا `branch` هنا — ومش سهو.**
/// `UserEntitlementController::packages()` مابيبعتش ولا واحد فيهم في أي صف
/// (اتقرا كامل ٢٠٢٦-٠٨-٢١). والقاعدة إن الشاشة ترسم من غير الحقل الناقص،
/// مش إننا نخترعه. النتيجة العملية: الكارت مابيقولش اسم المحل، و**الحجز
/// متعطّل** لأن `/public/bookings/available-slots` محتاج `branch_uuid`.
/// TODO(api): BE-A1.
sealed class PackageEntitlementUiModel {
  const PackageEntitlementUiModel({
    required this.uuid,
    required this.packageName,
    required this.status,
    required this.canBook,
    this.purchasedAt,
    this.expiresAt,
  });

  final String uuid;
  final String packageName;
  final PackageStatus status;

  /// السيرفر بيقول تقدر تحجز ولا لأ.
  ///
  /// ⚠ **مش كفاية لوحده عشان الزرار يشتغل.** حتى لما بيبقى `true`،
  /// التطبيق مايقدرش يجيب مواعيد من غير `branch_uuid` (BE-A1). شوف
  /// [isBookableFromApp].
  final bool canBook;

  final DateTime? purchasedAt;
  final DateTime? expiresAt;

  /// **الحجز من التطبيق مقفول للباقات كلها.**
  ///
  /// دي مش قاعدة منتج — دي حدود العقد الحالي. `bookSessionForUser` بيقرا
  /// المزوّد والفرع من الشراء **على السيرفر**، فالسيرفر عارف؛ هو بس
  /// مابيقولش للعميل. ومن غير الفرع مفيش `available-slots`، ومن غير
  /// مواعيد مفيش شاشة حجز.
  ///
  /// جرّبنا نطلّعه من حتة تانية وماينفعش: `allowed_services` بيدّي
  /// `service_uuid` بس، و`PublicServiceDetailResource` بيرجّع **`branches`
  /// جمع** — يعني الخدمة في أكتر من فرع، واختيار واحد منهم تخمين.
  ///
  /// TODO(api): BE-A1 — أول ما ينزل، ده بيرجع [canBook].
  bool get isBookableFromApp => false;

  /// السبب اللي بيتعرض تحت الزرار المتعطّل.
  String get blockedReason =>
      'حجز جلسات الباقة من التطبيق لسه مش متاح — كلّم الفرع عشان يظبطلك ميعاد';

  /// باقي على الانتهاء كام يوم؟ `null` = مفيش تاريخ انتهاء (باقة دائمة).
  int? daysUntilExpiry({DateTime? now}) {
    final expiry = expiresAt;
    if (expiry == null) return null;
    final current = now ?? DateTime.now();
    return expiry.difference(current).inDays;
  }

  /// تنتهي قريب؟ — التحذير بيبان من ٧ أيام.
  bool expiresSoon({DateTime? now}) {
    if (status != PackageStatus.active) return false;
    final days = daysUntilExpiry(now: now);
    return days != null && days >= 0 && days <= 7;
  }

  /// بيفرز الصف للنوع الصح.
  ///
  /// `package_type` هو المفتاح — و`usage_based` هو الوحيد اللي شكله مختلف.
  factory PackageEntitlementUiModel.fromJson(Map<String, dynamic> json) {
    final type = JsonParse.stringValue(json['package_type']);
    if (type == 'usage_based') return UsagePackageEntitlement.fromJson(json);
    return SessionPackageEntitlement.fromJson(json);
  }
}

/// `multi_session` و`single_visit` — **بتتعدّ بالجلسات**.
class SessionPackageEntitlement extends PackageEntitlementUiModel {
  const SessionPackageEntitlement({
    required super.uuid,
    required super.packageName,
    required super.status,
    required super.canBook,
    required this.serviceName,
    required this.totalSessions,
    required this.completedSessions,
    required this.reservedSessions,
    required this.availableSessions,
    this.isSingleVisit = false,
    super.purchasedAt,
    super.expiresAt,
  });

  final String serviceName;
  final int totalSessions;
  final int completedSessions;

  /// جلسات **محجوزة لمواعيد جاية** — مش متاحة ومش مستهلكة.
  ///
  /// ⚠ الشريط لازم يوريها **شريحة تالتة**. لو اتلمّت مع المتاح، العميلة
  /// بتشوف جلسة تقدر تحجزها وهي محجوزة أصلاً؛ ولو اتلمّت مع المستهلك،
  /// بتشوف جلسة ضاعت وهي لسه ليها.
  final int reservedSessions;

  final int availableSessions;

  /// `single_visit` = زيارة واحدة فيها كذا خدمة. السؤال بتاعها «إيه اللي
  /// جواها» مش «فاضل كام».
  final bool isSingleVisit;

  factory SessionPackageEntitlement.fromJson(Map<String, dynamic> json) =>
      SessionPackageEntitlement(
        uuid: JsonParse.stringValue(json['uuid']),
        packageName: JsonParse.stringValue(json['package_name']),
        serviceName: JsonParse.stringValue(json['service_name']),
        totalSessions: JsonParse.intValue(json['total_sessions']),
        completedSessions: JsonParse.intValue(json['completed_sessions']),
        reservedSessions: JsonParse.intValue(json['reserved_sessions']),
        availableSessions: JsonParse.intValue(json['available_sessions']),
        status: PackageStatusLabel.fromApi(
          JsonParse.stringValue(json['status']),
        ),
        canBook: JsonParse.boolValue(json['can_book']),
        isSingleVisit:
            JsonParse.stringValue(json['package_type']) == 'single_visit',
        purchasedAt: JsonParse.dateOrNull(json['purchased_at']),
        expiresAt: JsonParse.dateOrNull(json['expires_at']),
      );
}

/// `usage_based` — **بركة وحدات مجمّعة عبر كذا شرا**.
///
/// السيرفر بيلمّ الشراءات بـ`package_id` وبيرجّع صف واحد بمجاميعها،
/// وبيسيب التفاصيل في [purchases] عشان كل شرا ليه تاريخ انتهاء لوحده.
class UsagePackageEntitlement extends PackageEntitlementUiModel {
  const UsagePackageEntitlement({
    required super.uuid,
    required super.packageName,
    required super.status,
    required super.canBook,
    required this.unitName,
    required this.totalUnitsPurchased,
    required this.totalUnitsConsumed,
    required this.availableUnits,
    required this.expiredUnits,
    required this.purchaseCount,
    this.unitCode = '',
    this.purchases = const <UsagePurchaseUiModel>[],
    this.allowedServices = const <AllowedServiceUiModel>[],
    this.usageHistory = const <UsageTransactionUiModel>[],
    super.purchasedAt,
    super.expiresAt,
  });

  final String unitCode;
  final String unitName;
  final int totalUnitsPurchased;
  final int totalUnitsConsumed;

  /// المتاح **دلوقتي** — السيرفر شايل منه المنتهي خلاص.
  final int availableUnits;

  /// وحدات اتدفعت وضاعت بانتهاء الصلاحية.
  ///
  /// ⚠ **عمرها ما تدخل الرقم الأساسي.** بتتعرض كسطر ثانوي — ضمّها للمتاح
  /// كدب، وضمّها للمستهلك بيخفي إن العميلة خسرت حاجة.
  final int expiredUnits;

  final int purchaseCount;
  final List<UsagePurchaseUiModel> purchases;
  final List<AllowedServiceUiModel> allowedServices;
  final List<UsageTransactionUiModel> usageHistory;

  factory UsagePackageEntitlement.fromJson(Map<String, dynamic> json) =>
      UsagePackageEntitlement(
        uuid: JsonParse.stringValue(json['uuid']),
        packageName: JsonParse.stringValue(json['package_name']),
        unitCode: JsonParse.stringValue(json['unit_code']),
        unitName: JsonParse.stringValue(json['unit_name']),
        totalUnitsPurchased: JsonParse.intValue(json['total_units_purchased']),
        totalUnitsConsumed: JsonParse.intValue(json['total_units_consumed']),
        availableUnits: JsonParse.intValue(json['available_units']),
        expiredUnits: JsonParse.intValue(json['expired_units']),
        purchaseCount: JsonParse.intValue(json['purchase_count']),
        purchases: <UsagePurchaseUiModel>[
          for (final row in JsonParse.mapListValue(json['purchases']))
            UsagePurchaseUiModel.fromJson(row),
        ],
        allowedServices: <AllowedServiceUiModel>[
          for (final row in JsonParse.mapListValue(json['allowed_services']))
            AllowedServiceUiModel.fromJson(row),
        ],
        usageHistory: <UsageTransactionUiModel>[
          for (final row in JsonParse.mapListValue(json['usage_history']))
            UsageTransactionUiModel.fromJson(row),
        ],
        status: PackageStatusLabel.fromApi(
          JsonParse.stringValue(json['status'], fallback: 'active'),
        ),
        canBook: JsonParse.boolValue(json['can_book']),
      );
}

/// شرا واحد جوه بركة الوحدات — بتاريخ انتهاء لوحده.
class UsagePurchaseUiModel {
  final String uuid;
  final int unitsPurchased;
  final int unitsConsumed;
  final int remainingUnits;
  final num price;
  final String currency;
  final DateTime? purchasedAt;
  final DateTime? expiresAt;
  final PackageStatus status;

  const UsagePurchaseUiModel({
    required this.uuid,
    required this.unitsPurchased,
    required this.unitsConsumed,
    required this.remainingUnits,
    this.price = 0,
    this.currency = 'EGP',
    this.purchasedAt,
    this.expiresAt,
    this.status = PackageStatus.active,
  });

  factory UsagePurchaseUiModel.fromJson(Map<String, dynamic> json) =>
      UsagePurchaseUiModel(
        uuid: JsonParse.stringValue(json['uuid']),
        unitsPurchased: JsonParse.intValue(json['units_purchased']),
        unitsConsumed: JsonParse.intValue(json['units_consumed']),
        remainingUnits: JsonParse.intValue(json['remaining_units']),
        price: JsonParse.doubleValue(json['price']),
        currency: JsonParse.stringValue(json['currency'], fallback: 'EGP'),
        purchasedAt: JsonParse.dateOrNull(json['purchased_at']),
        expiresAt: JsonParse.dateOrNull(json['expires_at']),
        status: PackageStatusLabel.fromApi(
          JsonParse.stringValue(json['status']),
        ),
      );
}

/// خدمة مسموح تصرف عليها وحدات من البركة.
class AllowedServiceUiModel {
  final String serviceUuid;
  final String name;
  final int durationMinutes;

  const AllowedServiceUiModel({
    required this.serviceUuid,
    required this.name,
    this.durationMinutes = 0,
  });

  factory AllowedServiceUiModel.fromJson(Map<String, dynamic> json) =>
      AllowedServiceUiModel(
        // السيرفر بيبعت `uuid` و`service_uuid` بنفس القيمة — بناخد
        // `service_uuid` لأن اسمه بيقول هو إيه.
        serviceUuid: JsonParse.stringValue(json['service_uuid']),
        name: JsonParse.stringValue(json['name']),
        durationMinutes: JsonParse.intValue(json['duration']),
      );
}
