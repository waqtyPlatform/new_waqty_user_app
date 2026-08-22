import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/entitlement_owner_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/usage_transaction_ui_model.dart';

/// MOCK — يتشال عند ربط:
///   GET /api/user/entitlements/packages
///   GET /api/user/entitlements/follow-ups
///
/// ## الفكسشرز دي **مرآة للعقد الحقيقي مش اقتراح**
///
/// كل حقل هنا اتقرا من `UserEntitlementController` (سطور ٢٧–١٢٢). يعني لو
/// الـmock بيرسم صح، الحقيقي بيرسم صح — والعكس. أي حقل مش في الكونترولر
/// **مش موجود هنا**، وأهمهم `provider` و`branch`: مالهمش وجود في الرد،
/// فمالهمش وجود في الفكسشر، فالشاشة اتصمّمت من غيرهم من أول لحظة بدل ما
/// تتصمّم عليهم وتتكسر يوم الربط.
class MockEntitlements {
  MockEntitlements._();

  static DateTime get _now => DateTime(2026, 8, 21, 12);

  /// نفس المزوّد والفرع اللي في `MockProviders` — عشان تذكرة الباقات على
  /// صفحة المزوّد تلاقي نفسها فعلاً، والحجز يجيب مواعيد فرع موجود.
  static const EntitlementOwnerUiModel _captain = EntitlementOwnerUiModel(
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
    branchCityName: 'المعادي',
  );

  /// مزوّد تاني — عشان الفلترة على صفحة المزوّد يبقى ليها معنى.
  static const EntitlementOwnerUiModel _relax = EntitlementOwnerUiModel(
    providerUuid: 'prv-4',
    providerName: 'مركز ريلاكس',
    branchUuid: 'brn-prv-4',
    branchName: 'الفرع الرئيسي',
    branchCityName: 'الدقي',
  );

  // ── باقات ──────────────────────────────────────────────────────────────

  /// ٨ جلسات: ٤ خلصوا · **١ محجوزة** · ٣ متاحة.
  ///
  /// الجلسة المحجوزة هي سبب وجود الفكسشر ده. لو الشريط رسم شريحتين بس،
  /// العميلة بتشوف ٤ متاحين وهي عندها ٣.
  static SessionPackageEntitlement get multiSession => SessionPackageEntitlement(
    uuid: 'pkg-multi-1',
    packageName: 'باقة قص الشعر',
    serviceName: 'قص شعر رجالي',
    serviceUuid: 'srv-1',
    durationMinutes: 45,
    owner: _captain,
    totalSessions: 8,
    completedSessions: 4,
    reservedSessions: 1,
    availableSessions: 3,
    status: PackageStatus.active,
    canBook: true,
    purchasedAt: _now.subtract(const Duration(days: 60)),
    expiresAt: _now.add(const Duration(days: 120)),
  );

  /// زيارة واحدة فيها كذا خدمة — السؤال «إيه اللي جواها» مش «فاضل كام».
  static SessionPackageEntitlement get singleVisit => SessionPackageEntitlement(
    uuid: 'pkg-single-1',
    packageName: 'يوم العروسة',
    serviceName: 'مكياج + تسريح + مانيكير',
    serviceUuid: 'srv-1',
    durationMinutes: 45,
    owner: _captain,
    totalSessions: 1,
    completedSessions: 0,
    reservedSessions: 0,
    availableSessions: 1,
    isSingleVisit: true,
    status: PackageStatus.active,
    canBook: true,
    purchasedAt: _now.subtract(const Duration(days: 10)),
    expiresAt: _now.add(const Duration(days: 80)),
  );

  /// تنتهي بعد ٥ أيام وفيها جلستين — بتختبر شكل التحذير.
  static SessionPackageEntitlement get expiringSoon =>
      SessionPackageEntitlement(
        uuid: 'pkg-soon-1',
        packageName: 'باقة الحمام المغربي',
        serviceName: 'حمام مغربي',
        serviceUuid: 'srv-1',
        durationMinutes: 45,
        owner: _captain,
        totalSessions: 4,
        completedSessions: 2,
        reservedSessions: 0,
        availableSessions: 2,
        status: PackageStatus.active,
        canBook: true,
        purchasedAt: _now.subtract(const Duration(days: 85)),
        expiresAt: _now.add(const Duration(days: 5)),
      );

  /// **انتهت وفيها جلستين لسه — أصعب حالة.**
  ///
  /// العميلة دفعت وضاع منها. الشاشة لازم تقول كده بوضوح ومن غير ما تدّعي
  /// إن فيه حاجة تتعمل من التطبيق.
  static SessionPackageEntitlement get expired => SessionPackageEntitlement(
    uuid: 'pkg-expired-1',
    packageName: 'باقة الفيشل',
    serviceName: 'تنظيف بشرة',
    serviceUuid: 'srv-1',
    durationMinutes: 45,
    owner: _captain,
    totalSessions: 6,
    completedSessions: 4,
    reservedSessions: 0,
    availableSessions: 2,
    status: PackageStatus.expired,
    canBook: false,
    purchasedAt: _now.subtract(const Duration(days: 200)),
    expiresAt: _now.subtract(const Duration(days: 40)),
  );

  /// خلصت — كل الجلسات اتستهلكت.
  static SessionPackageEntitlement get completed => SessionPackageEntitlement(
    uuid: 'pkg-done-1',
    packageName: 'باقة الحلاقة الشهرية',
    serviceName: 'حلاقة ذقن',
    serviceUuid: 'srv-1',
    durationMinutes: 45,
    owner: _captain,
    totalSessions: 4,
    completedSessions: 4,
    reservedSessions: 0,
    availableSessions: 0,
    status: PackageStatus.completed,
    canBook: false,
    purchasedAt: _now.subtract(const Duration(days: 120)),
    expiresAt: _now.add(const Duration(days: 30)),
  );

  /// بركة ١٢٠ دقيقة متاحة · ١٥ انتهت صلاحيتها · تلات خدمات مسموحة.
  static UsagePackageEntitlement get usageBased => UsagePackageEntitlement(
    uuid: 'pkg-usage-1',
    packageName: 'رصيد المساج',
    unitCode: 'min',
    unitName: 'دقيقة',
    owner: _relax,
    totalUnitsPurchased: 300,
    totalUnitsConsumed: 165,
    availableUnits: 120,
    expiredUnits: 15,
    purchaseCount: 1,
    status: PackageStatus.active,
    canBook: true,
    purchasedAt: _now.subtract(const Duration(days: 45)),
    expiresAt: _now.add(const Duration(days: 60)),
    purchases: <UsagePurchaseUiModel>[
      UsagePurchaseUiModel(
        uuid: 'buy-1',
        unitsPurchased: 300,
        unitsConsumed: 165,
        remainingUnits: 135,
        price: 1500,
        purchasedAt: _now.subtract(const Duration(days: 45)),
        expiresAt: _now.add(const Duration(days: 60)),
      ),
    ],
    allowedServices: const <AllowedServiceUiModel>[
      AllowedServiceUiModel(
        serviceUuid: 'srv-massage-relax',
        name: 'مساج استرخاء',
        durationMinutes: 60,
      ),
      AllowedServiceUiModel(
        serviceUuid: 'srv-massage-deep',
        name: 'مساج عميق',
        durationMinutes: 90,
      ),
      AllowedServiceUiModel(
        serviceUuid: 'srv-massage-foot',
        name: 'مساج قدم',
        durationMinutes: 30,
      ),
    ],
    usageHistory: <UsageTransactionUiModel>[
      UsageTransactionUiModel(
        uuid: 'txn-3',
        type: 'consume',
        units: 60,
        balanceBefore: 195,
        balanceAfter: 135,
        reason: 'مساج استرخاء',
        createdAt: _now.subtract(const Duration(days: 7)),
      ),
      UsageTransactionUiModel(
        uuid: 'txn-2',
        type: 'consume',
        units: 90,
        balanceBefore: 285,
        balanceAfter: 195,
        reason: 'مساج عميق',
        createdAt: _now.subtract(const Duration(days: 25)),
      ),
      UsageTransactionUiModel(
        uuid: 'txn-1',
        type: 'purchase',
        units: 300,
        balanceBefore: 0,
        balanceAfter: 300,
        reason: 'شرا الباقة',
        createdAt: _now.subtract(const Duration(days: 45)),
      ),
    ],
  );

  /// **بركة واحدة من تلات شراءات بتواريخ انتهاء مختلفة.**
  ///
  /// الرقم الكبير واحد، بس ورا الرقم تلات صلاحيات — واللي هيخلص الأول مش
  /// اللي اتشرى الأول بالضرورة. الأكورديون جوه الكارت هو اللي بيوضّح ده.
  static UsagePackageEntitlement get usageMultiplePurchases =>
      UsagePackageEntitlement(
        uuid: 'pkg-usage-multi',
        packageName: 'رصيد الليزر',
        unitCode: 'session',
        unitName: 'جلسة ليزر',
        owner: _relax,
        totalUnitsPurchased: 30,
        totalUnitsConsumed: 12,
        availableUnits: 18,
        expiredUnits: 0,
        purchaseCount: 3,
        status: PackageStatus.active,
        canBook: true,
        purchasedAt: _now.subtract(const Duration(days: 150)),
        expiresAt: _now.add(const Duration(days: 20)),
        purchases: <UsagePurchaseUiModel>[
          UsagePurchaseUiModel(
            uuid: 'buy-a',
            unitsPurchased: 10,
            unitsConsumed: 10,
            remainingUnits: 0,
            price: 2000,
            purchasedAt: _now.subtract(const Duration(days: 150)),
            expiresAt: _now.add(const Duration(days: 20)),
            status: PackageStatus.completed,
          ),
          UsagePurchaseUiModel(
            uuid: 'buy-b',
            unitsPurchased: 10,
            unitsConsumed: 2,
            remainingUnits: 8,
            price: 2000,
            purchasedAt: _now.subtract(const Duration(days: 60)),
            expiresAt: _now.add(const Duration(days: 120)),
          ),
          UsagePurchaseUiModel(
            uuid: 'buy-c',
            unitsPurchased: 10,
            unitsConsumed: 0,
            remainingUnits: 10,
            price: 2200,
            purchasedAt: _now.subtract(const Duration(days: 5)),
            expiresAt: _now.add(const Duration(days: 175)),
          ),
        ],
        allowedServices: const <AllowedServiceUiModel>[
          AllowedServiceUiModel(
            serviceUuid: 'srv-laser-full',
            name: 'ليزر كامل',
            durationMinutes: 60,
          ),
        ],
        usageHistory: <UsageTransactionUiModel>[
          UsageTransactionUiModel(
            uuid: 'txn-l2',
            type: 'consume',
            units: 2,
            balanceBefore: 20,
            balanceAfter: 18,
            reason: 'ليزر كامل',
            createdAt: _now.subtract(const Duration(days: 30)),
          ),
        ],
      );

  // ── متابعات ────────────────────────────────────────────────────────────

  /// متابعة مجانية · **نفس الأخصائي إجباري**.
  static FollowUpEntitlementUiModel get followUpFree =>
      FollowUpEntitlementUiModel(
        uuid: 'fu-free-1',
        serviceName: 'تنظيف بشرة',
        serviceUuid: 'srv-1',
        durationMinutes: 45,
        owner: _captain,
        // «صالون كابتن · تنظيف بشرة» — حجز مكتمل حقيقي في الفكسشرز،
        // فالتنبيه في تفاصيله بيظهر فعلاً.
        originalBookingUuid: MockBookings.ulid('H3P8'),
        validFrom: _now.subtract(const Duration(days: 3)),
        validUntil: _now.add(const Duration(days: 22)),
        allowedCount: 1,
        completedCount: 0,
        reservedCount: 0,
        availableCount: 1,
        priceType: 'free',
        effectivePrice: 0,
        employeeRule: FollowUpEmployeeRule.sameRequired,
        employee: const FollowUpEmployeeUiModel(
          uuid: 'emp-1',
          name: 'سارة محمود',
        ),
        status: PackageStatus.active,
      );

  /// متابعة بخصم ٥٠٪ · أي أخصائي.
  static FollowUpEntitlementUiModel get followUpDiscounted =>
      FollowUpEntitlementUiModel(
        uuid: 'fu-disc-1',
        serviceName: 'جلسة ليزر',
        serviceUuid: 'srv-1',
        durationMinutes: 45,
        owner: _captain,
        // «مركز ريلاكس» — تاني حجز مكتمل.
        originalBookingUuid: MockBookings.ulid('F7S2'),
        validFrom: _now.subtract(const Duration(days: 1)),
        validUntil: _now.add(const Duration(days: 29)),
        allowedCount: 1,
        completedCount: 0,
        reservedCount: 0,
        availableCount: 1,
        priceType: 'discounted',
        effectivePrice: 150,
        employeeRule: FollowUpEmployeeRule.any,
        status: PackageStatus.active,
      );

  /// **الأخصائي ساب الشغل والمتابعة مربوطة بيه — BE-A5.**
  ///
  /// `employee: null` مع `same_employee_required` = شرط مستحيل يتحقق.
  /// التطبيق **مابيرخّيهوش من عنده**: في متابعة طبية ده معناه نحط مريضة
  /// مع دكتور تاني بقرار من الموبايل.
  static FollowUpEntitlementUiModel get followUpEmployeeLeft =>
      FollowUpEntitlementUiModel(
        uuid: 'fu-orphan-1',
        serviceName: 'تنظيف أسنان',
        serviceUuid: 'srv-1',
        durationMinutes: 45,
        owner: _captain,
        // مش مربوطة بحجز في الفكسشرز بالقصد — الحالة دي بتتجرّب من
        // «باقاتي» مش من تفاصيل حجز.
        originalBookingUuid: MockBookings.ulid('ORPH'),
        validFrom: _now.subtract(const Duration(days: 5)),
        validUntil: _now.add(const Duration(days: 25)),
        allowedCount: 1,
        completedCount: 0,
        reservedCount: 0,
        availableCount: 1,
        priceType: 'free',
        effectivePrice: 0,
        employeeRule: FollowUpEmployeeRule.sameRequired,
        employee: null,
        status: PackageStatus.active,
      );

  // ── اللي بيتعرض حسب السيناريو ──────────────────────────────────────────

  static List<PackageEntitlementUiModel> get packages =>
      switch (MockConfig.scenario) {
        MockScenario.packageMultiSession => <PackageEntitlementUiModel>[
          multiSession,
          singleVisit,
        ],
        MockScenario.packageUsageBased => <PackageEntitlementUiModel>[
          usageBased,
        ],
        MockScenario.packageExpiringSoon => <PackageEntitlementUiModel>[
          expiringSoon,
        ],
        MockScenario.packageExpired => <PackageEntitlementUiModel>[
          expired,
          completed,
        ],
        MockScenario.packageMultiplePurchases => <PackageEntitlementUiModel>[
          usageMultiplePurchases,
        ],
        // الحالتين الفاضيتين نصهم بيتفرّع على تأكيد الرقم مش على الليستة —
        // شوف `MockAccount._verifiedAt`.
        MockScenario.entitlementsEmptyUnlinked ||
        MockScenario.entitlementsEmptyGenuine =>
          const <PackageEntitlementUiModel>[],
        // الافتراضي: مزيج بيوري الأنواع التلاتة مع بعض — ده اللي بيمسك
        // «كارت الوحدات بيقول جلسات».
        _ => <PackageEntitlementUiModel>[multiSession, usageBased, expired],
      };

  static List<FollowUpEntitlementUiModel> get followUps =>
      switch (MockConfig.scenario) {
        MockScenario.followUpFree => <FollowUpEntitlementUiModel>[followUpFree],
        MockScenario.followUpDiscounted => <FollowUpEntitlementUiModel>[
          followUpDiscounted,
        ],
        MockScenario.followUpEmployeeLeft => <FollowUpEntitlementUiModel>[
          followUpEmployeeLeft,
        ],
        MockScenario.entitlementsEmptyUnlinked ||
        MockScenario.entitlementsEmptyGenuine =>
          const <FollowUpEntitlementUiModel>[],
        MockScenario.packageMultiSession ||
        MockScenario.packageUsageBased ||
        MockScenario.packageExpiringSoon ||
        MockScenario.packageExpired ||
        MockScenario.packageMultiplePurchases =>
          const <FollowUpEntitlementUiModel>[],
        _ => <FollowUpEntitlementUiModel>[followUpFree, followUpDiscounted],
      };
}
