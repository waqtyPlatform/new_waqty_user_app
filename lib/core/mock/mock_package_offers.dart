import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';

/// **الباقات المعروضة للبيع عند فرع** — كتالوج المكان، مش باقات العميلة.
///
/// الفرق عن [MockEntitlements] مش تنظيمي: دي حاجات محدش اشتراها. مافيش
/// فيها عدّاد ولا حالة ولا تاريخ انتهاء بيعدّ — فيها سعر وإيه اللي جواها.
///
/// TODO(api): بتيجي من `GET /public/provider-branches/{uuid}/packages`.
class MockPackageOffers {
  const MockPackageOffers._();

  static final DateTime _now = DateTime.now();

  // ── صالون كابتن ────────────────────────────────────────────────────────

  static PackageOfferUiModel get captainHaircut => PackageOfferUiModel(
    uuid: 'pkg-offer-captain-1',
    name: 'باقة قص الشعر',
    description: 'تمن جلسات قص شعر رجالي على مدار ستة شهور.',
    type: PackageOfferType.multiSession,
    basePrice: 1600,
    effectivePrice: 1600,
    sessionsIncluded: 8,
    durationMinutes: 45,
    validityDays: 180,
    services: const <PackageOfferServiceUiModel>[
      PackageOfferServiceUiModel(
        uuid: 'srv-1',
        name: 'قص شعر رجالي',
        durationMinutes: 45,
      ),
    ],
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
  );

  /// **عليها عرض شغّال** — السيناريو اللي بيختبر إن الخصم بيبان بتاريخ
  /// نهايته، مش كرقم أصغر من غير سياق.
  static PackageOfferUiModel get captainGrooming => PackageOfferUiModel(
    uuid: 'pkg-offer-captain-2',
    name: 'باقة العناية الكاملة',
    description: 'قص شعر وحلاقة ذقن وغسيل وتصفيف — أربع مرات.',
    type: PackageOfferType.multiSession,
    basePrice: 1800,
    effectivePrice: 1350,
    hasOffer: true,
    offerEndsAt: _now.add(const Duration(days: 9)),
    sessionsIncluded: 4,
    durationMinutes: 75,
    validityDays: 120,
    availableUntil: _now.add(const Duration(days: 40)),
    services: const <PackageOfferServiceUiModel>[
      PackageOfferServiceUiModel(
        uuid: 'srv-1',
        name: 'قص شعر رجالي',
        durationMinutes: 45,
      ),
      PackageOfferServiceUiModel(
        uuid: 'srv-2',
        name: 'حلاقة ذقن',
        durationMinutes: 20,
      ),
      PackageOfferServiceUiModel(
        uuid: 'srv-3',
        name: 'غسيل وتصفيف',
        durationMinutes: 10,
      ),
    ],
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
  );

  /// زيارة واحدة — بتختبر إن الكارت مايقولش «١ جلسة».
  static PackageOfferUiModel get captainSingle => PackageOfferUiModel(
    uuid: 'pkg-offer-captain-3',
    name: 'يوم العريس',
    description: 'كل حاجة قبل الفرح في زيارة واحدة.',
    type: PackageOfferType.singleVisit,
    basePrice: 900,
    effectivePrice: 900,
    durationMinutes: 150,
    validityDays: 60,
    services: const <PackageOfferServiceUiModel>[
      PackageOfferServiceUiModel(
        uuid: 'srv-1',
        name: 'قص شعر رجالي',
        durationMinutes: 45,
      ),
      PackageOfferServiceUiModel(
        uuid: 'srv-2',
        name: 'حلاقة ذقن',
        durationMinutes: 20,
      ),
    ],
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
  );

  // ── مركز ريلاكس ────────────────────────────────────────────────────────

  /// بركة وحدات — بتختبر إن الكتالوج بيتكلم بالوحدة مش بالجلسة.
  static PackageOfferUiModel get relaxMassagePool => PackageOfferUiModel(
    uuid: 'pkg-offer-relax-1',
    name: 'رصيد المساج',
    description: 'رصيد دقايق تصرفيه على أي مساج في المركز.',
    type: PackageOfferType.usageBased,
    basePrice: 2400,
    effectivePrice: 2400,
    unitName: 'دقيقة',
    initialUnits: 300,
    validityDays: 90,
    services: const <PackageOfferServiceUiModel>[
      PackageOfferServiceUiModel(
        uuid: 'srv-10',
        name: 'مساج استرخاء',
        durationMinutes: 60,
      ),
      PackageOfferServiceUiModel(
        uuid: 'srv-11',
        name: 'مساج عميق',
        durationMinutes: 90,
      ),
      PackageOfferServiceUiModel(
        uuid: 'srv-12',
        name: 'مساج قدم',
        durationMinutes: 30,
      ),
    ],
    providerUuid: 'prv-4',
    providerName: 'مركز ريلاكس',
    branchUuid: 'brn-prv-4',
    branchName: 'الفرع الرئيسي',
  );

  /// **نفس الباقة في فرع تاني بسعر تاني.**
  ///
  /// دي اللي بتخلّي الفلترة بالفرع حاجة تتشاف مش كلام: لو القسم فلتر
  /// بالمزوّد، اللي واقفة في المعادي هتقرا سعر مدينة نصر.
  static PackageOfferUiModel get captainHaircutNasrCity => PackageOfferUiModel(
    uuid: 'pkg-offer-captain-nasr-1',
    name: 'باقة قص الشعر',
    description: 'تمن جلسات قص شعر رجالي على مدار ستة شهور.',
    type: PackageOfferType.multiSession,
    basePrice: 1400,
    effectivePrice: 1400,
    sessionsIncluded: 8,
    durationMinutes: 45,
    validityDays: 180,
    services: const <PackageOfferServiceUiModel>[
      PackageOfferServiceUiModel(
        uuid: 'srv-1',
        name: 'قص شعر رجالي',
        durationMinutes: 45,
      ),
    ],
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-2',
    branchName: 'فرع مدينة نصر',
  );

  /// كتالوج الفرع حسب السيناريو.
  ///
  /// ⚠ **الفلترة بالفرع مش بالمزوّد** — نفس قاعدة السيرفر. فرع تاني
  /// لنفس الصالون ممكن يبيع بسعر تاني، ودمج الاتنين بيقول للعميلة رقم
  /// المكان اللي هي مش واقفة فيه.
  static List<PackageOfferUiModel> ofBranch(String? branchUuid) {
    final catalogue = switch (MockConfig.scenario) {
      MockScenario.providerPackagesNone => const <PackageOfferUiModel>[],
      MockScenario.providerPackageOnOffer => <PackageOfferUiModel>[
        captainGrooming,
        captainHaircut,
      ],
      _ => <PackageOfferUiModel>[
        captainHaircut,
        captainGrooming,
        captainSingle,
        captainHaircutNasrCity,
        relaxMassagePool,
      ],
    };

    if (branchUuid == null || branchUuid.isEmpty) return catalogue;
    return catalogue.where((p) => p.branchUuid == branchUuid).toList();
  }
}
