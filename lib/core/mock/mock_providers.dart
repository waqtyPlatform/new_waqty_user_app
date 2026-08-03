import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';

/// MOCK — يتشال عند ربط:
///   GET /api/public/providers
///   GET /api/public/provider-branches
///
/// ملحوظة على الصور: كل المحلات هنا `imagePath` فاضي بالقصد. مفيش صور محلات
/// حقيقية في المشروع، وحطّ صور تجريبية مكانها بيخلي الفريق يتعوّد على شكل
/// مش هيحصل. الـ placeholder ده هو نفسه اللي هيظهر في الحقيقي لأي محل
/// مالوش لوجو — يعني إحنا بنجرّب الحالة الشائعة مش الاستثناء.
class MockProviders {
  MockProviders._();

  static const List<ProviderUiModel> all = <ProviderUiModel>[
    ProviderUiModel(
      uuid: 'prv-1',
      name: 'صالون كابتن',
      categoryName: 'حلاقة رجالي',
      areaName: 'المعادي',
      imagePath: '',
      distanceKm: 1.2,
      priceFrom: 250,
      servicesCount: 11,
      nextAvailableLabel: 'النهاردة 4:30 م',
    ),
    ProviderUiModel(
      uuid: 'prv-2',
      name: 'كوافير نور',
      categoryName: 'كوافير حريمي',
      areaName: 'مدينة نصر',
      imagePath: '',
      distanceKm: 2.8,
      priceFrom: 300,
      servicesCount: 19,
      nextAvailableLabel: 'بكرة 11:00 ص',
    ),
    ProviderUiModel(
      uuid: 'prv-3',
      name: 'باربر شوب الحرية',
      categoryName: 'حلاقة رجالي',
      areaName: 'مصر الجديدة',
      imagePath: '',
      distanceKm: 4.1,
      priceFrom: 180,
      servicesCount: 8,
      nextAvailableLabel: 'النهاردة 7:15 م',
    ),
    ProviderUiModel(
      uuid: 'prv-4',
      name: 'مركز ريلاكس',
      categoryName: 'مساج واسترخاء',
      areaName: 'الدقي',
      imagePath: '',
      distanceKm: 5.6,
      priceFrom: 450,
      servicesCount: 6,
      nextAvailableLabel: '',
    ),
    ProviderUiModel(
      uuid: 'prv-5',
      name: 'استوديو جمال',
      categoryName: 'عناية بالبشرة',
      areaName: 'المهندسين',
      imagePath: '',
      distanceKm: 6.3,
      priceFrom: 400,
      servicesCount: 14,
      nextAvailableLabel: 'الخميس 2:00 م',
    ),
    ProviderUiModel(
      uuid: 'prv-6',
      name: 'صالون الأصدقاء',
      categoryName: 'حلاقة رجالي',
      areaName: 'المعادي',
      imagePath: '',
      distanceKm: 1.9,
      priceFrom: 200,
      servicesCount: 10,
      nextAvailableLabel: 'النهاردة 6:00 م',
    ),
  ];

  /// المحلات القريبة — مرتبة بالمسافة.
  static List<ProviderUiModel> get nearby =>
      List<ProviderUiModel>.from(all)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

  static ProviderUiModel byUuid(String uuid) =>
      all.firstWhere((p) => p.uuid == uuid, orElse: () => all.first);

  /// بحث بسيط بالاسم أو المنطقة أو التصنيف.
  static List<ProviderUiModel> search(String query, {String? categoryUuid}) {
    final q = query.trim();
    return all.where((p) {
      final matchesQuery =
          q.isEmpty ||
          p.name.contains(q) ||
          p.areaName.contains(q) ||
          p.categoryName.contains(q);
      final matchesCategory =
          categoryUuid == null ||
          categoryUuid.isEmpty ||
          _categoryOf(p) == categoryUuid;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  static String _categoryOf(ProviderUiModel p) => switch (p.categoryName) {
    'حلاقة رجالي' => 'cat-1',
    'كوافير حريمي' => 'cat-2',
    'عناية بالبشرة' => 'cat-3',
    'مساج واسترخاء' => 'cat-4',
    'أظافر' => 'cat-5',
    _ => 'cat-6',
  };

  // ── الفروع ──────────────────────────────────────────────────────────────

  /// معظم المحلات فرع واحد — وده مقصود، عشان نتأكد إن الفلو بيتخطى خطوة
  /// اختيار الفرع لما يبقى فيه واحد بس. «صالون كابتن» ليه فرعين عشان
  /// نجرّب الحالة التانية.
  ///
  /// **سيناريو `twoBranches` بيدّي فرعين لكل المحلات.** من غير كده كان
  /// السيناريو مجرد تعليمة شفهية («افتح صالون كابتن») — يعني اسم في
  /// القايمة مالوش أثر، وهو بالظبط العيب اللي شيلنا عشانه حالات مستحيلة
  /// من الـ enums. دلوقتي أي محل التستر يفتحه بيوصله لاختيار الفرع.
  static List<BranchUiModel> branchesOf(String providerUuid) {
    if (providerUuid == 'prv-1') {
      return const <BranchUiModel>[
        BranchUiModel(
          uuid: 'brn-1',
          name: 'فرع المعادي',
          areaName: 'المعادي',
          address: '12 شارع 9، المعادي، القاهرة',
          phone: '+201012345678',
          latitude: 29.9601,
          longitude: 31.2569,
          distanceKm: 1.2,
          openStatusLabel: 'مفتوح · يقفل 9:00 م',
          isOpenNow: true,
          workingHours: _standardHours,
        ),
        BranchUiModel(
          uuid: 'brn-2',
          name: 'فرع مدينة نصر',
          areaName: 'مدينة نصر',
          address: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
          phone: '+201098765432',
          latitude: 30.0511,
          longitude: 31.3656,
          distanceKm: 7.4,
          openStatusLabel: 'مفتوح · يقفل 10:00 م',
          isOpenNow: true,
          workingHours: _standardHours,
        ),
      ];
    }

    final provider = byUuid(providerUuid);

    return <BranchUiModel>[
      BranchUiModel(
        uuid: 'brn-$providerUuid',
        name: 'الفرع الرئيسي',
        areaName: provider.areaName,
        address: 'شارع الجمهورية، ${provider.areaName}، القاهرة',
        phone: '+201155667788',
        latitude: 30.0444,
        longitude: 31.2357,
        distanceKm: provider.distanceKm,
        openStatusLabel: 'مفتوح · يقفل 9:00 م',
        isOpenNow: true,
        workingHours: _standardHours,
      ),

      // الفرع التاني بيتولّد **من المحل نفسه** — الاسم والمنطقة والـ uuid
      // كلهم مشتقين، عشان مايبقاش فيه فرع اسمه «المعادي» تحت محل في
      // المهندسين ولا uuid يتكرر بين محلين.
      if (MockConfig.scenario == MockScenario.twoBranches)
        BranchUiModel(
          uuid: 'brn-$providerUuid-2',
          name: 'فرع مدينة نصر',
          areaName: 'مدينة نصر',
          address: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
          phone: '+201098765432',
          latitude: 30.0511,
          longitude: 31.3656,
          distanceKm: provider.distanceKm + 5.2,
          openStatusLabel: 'مفتوح · يقفل 9:00 م',
          isOpenNow: true,
          workingHours: _standardHours,
        ),
    ];
  }

  /// الجمعة مقفول — ده إيقاع طبيعي في مصر، وبيخلي التقويم يبان فيه فراغ
  /// حقيقي بدل ما يبقى كله متاح.
  ///
  /// **الساعات هنا لازم تطابق `MockSlots`** (`_openHour = 9`,
  /// `_closeHour = 21`) و`MockConfig.emptySlotsDays`. المولّد ٩ص–٩م ثابت
  /// لكل الفروع، فأي ساعة تتكتب هنا غيرها بتخلي الكارت يعد بحاجة المواعيد
  /// مابتديهاش. الخميس كان مكتوب ١١:٠٠ م والمواعيد بتقف ٩ م.
  static const List<BranchWorkingDay> _standardHours = <BranchWorkingDay>[
    BranchWorkingDay(dayName: 'السبت', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الأحد', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الاثنين', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الثلاثاء', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الأربعاء', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الخميس', hoursLabel: '9:00 ص – 9:00 م'),
    BranchWorkingDay(dayName: 'الجمعة', hoursLabel: 'مقفول', isClosed: true),
  ];
}
