import 'package:waqty_user_application/core/models/service_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/public/services?provider_uuid=
///
/// ## التصنيفات ليها ولاد حقيقيين دلوقتي
///
/// كان «صبغة» تصنيف بـ`childrenCount: 11` **مكتوبة بالإيد** ومفيش ولا
/// خدمة واحدة تحته. الضغط عليه كان بيفتح مختار الخدمات على **كل** خدمات
/// المحل — يعني الصف بيوعد بـ11 حاجة ويوصّلك لحاجات تانية خالص.
///
/// دلوقتي الولاد موجودين فعلاً و[childrenOf] بترجّعهم، والعدد بيتحسب من
/// القايمة مش من رقم مكتوب.
class MockServices {
  MockServices._();

  static const List<ServiceUiModel> _menServices = <ServiceUiModel>[
    ServiceUiModel(
      uuid: 'srv-1',
      name: 'قص شعر',
      price: 250,
      durationMinutes: 45,
    ),
    ServiceUiModel(
      uuid: 'srv-2',
      name: 'حلاقة ذقن',
      price: 120,
      durationMinutes: 20,
    ),
    ServiceUiModel(
      uuid: 'srv-3',
      name: 'قص شعر + ذقن',
      price: 330,
      durationMinutes: 60,
    ),
    ServiceUiModel(
      uuid: 'srv-4',
      name: 'صبغة',
      price: 0,
      durationMinutes: 0,
      isCategory: true,
    ),
    ServiceUiModel(
      uuid: 'srv-5',
      name: 'حمام كريم',
      price: 180,
      durationMinutes: 30,
    ),
  ];

  /// ولاد «صبغة» الرجالي — أسعار ومدد مختلفة بالقصد، عشان التصنيف يبان
  /// إنه اختيار حقيقي مش مجرد عنوان.
  static const List<ServiceUiModel> _menDyeChildren = <ServiceUiModel>[
    ServiceUiModel(
      uuid: 'srv-4-1',
      name: 'صبغة شعر كاملة',
      price: 400,
      durationMinutes: 90,
      parentUuid: 'srv-4',
    ),
    ServiceUiModel(
      uuid: 'srv-4-2',
      name: 'صبغة جذور',
      price: 220,
      durationMinutes: 45,
      parentUuid: 'srv-4',
    ),
    ServiceUiModel(
      uuid: 'srv-4-3',
      name: 'صبغة ذقن',
      price: 150,
      durationMinutes: 30,
      parentUuid: 'srv-4',
    ),
    ServiceUiModel(
      uuid: 'srv-4-4',
      name: 'هاي لايت',
      price: 550,
      durationMinutes: 120,
      parentUuid: 'srv-4',
    ),
    ServiceUiModel(
      uuid: 'srv-4-5',
      name: 'تغطية الشيب',
      price: 300,
      durationMinutes: 60,
      parentUuid: 'srv-4',
    ),
  ];

  static const List<ServiceUiModel> _womenServices = <ServiceUiModel>[
    ServiceUiModel(
      uuid: 'srv-6',
      name: 'سشوار',
      price: 300,
      durationMinutes: 45,
    ),
    ServiceUiModel(
      uuid: 'srv-7',
      name: 'فرد بروتين',
      price: 1200,
      durationMinutes: 180,
    ),
    ServiceUiModel(
      uuid: 'srv-8',
      name: 'قص وتصفيف',
      price: 400,
      durationMinutes: 60,
    ),
    ServiceUiModel(
      uuid: 'srv-9',
      name: 'صبغة',
      price: 0,
      durationMinutes: 0,
      isCategory: true,
    ),
  ];

  static const List<ServiceUiModel> _womenDyeChildren = <ServiceUiModel>[
    ServiceUiModel(
      uuid: 'srv-9-1',
      name: 'صبغة كاملة',
      price: 700,
      durationMinutes: 120,
      parentUuid: 'srv-9',
    ),
    ServiceUiModel(
      uuid: 'srv-9-2',
      name: 'أومبريه',
      price: 1400,
      durationMinutes: 180,
      parentUuid: 'srv-9',
    ),
    ServiceUiModel(
      uuid: 'srv-9-3',
      name: 'بالياج',
      price: 1600,
      durationMinutes: 210,
      parentUuid: 'srv-9',
    ),
    ServiceUiModel(
      uuid: 'srv-9-4',
      name: 'صبغة جذور',
      price: 350,
      durationMinutes: 60,
      parentUuid: 'srv-9',
    ),
  ];

  static const List<ServiceUiModel> _careServices = <ServiceUiModel>[
    ServiceUiModel(
      uuid: 'srv-10',
      name: 'تنظيف بشرة عميق',
      price: 450,
      durationMinutes: 60,
    ),
    ServiceUiModel(
      uuid: 'srv-11',
      name: 'مساج استرخاء',
      price: 500,
      durationMinutes: 90,
    ),
  ];

  static const List<ServiceUiModel> _allChildren = <ServiceUiModel>[
    ..._menDyeChildren,
    ..._womenDyeChildren,
  ];

  /// خدمات المحل — **المستوى الأول بس**.
  ///
  /// ولاد التصنيفات مابيظهروش هنا؛ بيتفتحوا لما العميل يدوس على التصنيف.
  /// لو ظهروا مع بعض، «صبغة» تبقى عنوان بلا معنى وأربع صبغات ورا بعض.
  static List<ServiceUiModel> ofProvider(String providerUuid) =>
      switch (providerUuid) {
        'prv-2' => _womenServices,
        'prv-4' || 'prv-5' => _careServices,
        _ => _menServices,
      };

  /// الخدمات اللي تحت تصنيف معيّن.
  static List<ServiceUiModel> childrenOf(String categoryUuid) =>
      _allChildren.where((s) => s.parentUuid == categoryUuid).toList();

  /// **العدد بيتحسب، مش بيتكتب.** الرقم المكتوب بالإيد بيفضل صح لحد أول
  /// مرة حد يضيف أو يشيل خدمة وينسى يعدّله.
  static int childrenCountOf(String categoryUuid) =>
      childrenOf(categoryUuid).length;

  static ServiceUiModel byUuid(String uuid) => <ServiceUiModel>[
    ..._menServices,
    ..._womenServices,
    ..._careServices,
    ..._allChildren,
  ].firstWhere((s) => s.uuid == uuid, orElse: () => _menServices.first);
}
