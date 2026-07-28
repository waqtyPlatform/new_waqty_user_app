import 'package:waqty_user_application/core/models/service_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/public/services?provider_uuid=
class MockServices {
  MockServices._();

  /// فيها صف تصنيف واحد بالقصد («صبغة») عشان نتأكد إن شكله مختلف عن
  /// صف الخدمة الحقيقية — دي المشكلة اللي كانت في التصميم القديم.
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
      childrenCount: 11,
    ),
    ServiceUiModel(
      uuid: 'srv-5',
      name: 'حمام كريم',
      price: 180,
      durationMinutes: 30,
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
      childrenCount: 8,
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

  static List<ServiceUiModel> ofProvider(String providerUuid) =>
      switch (providerUuid) {
        'prv-2' => _womenServices,
        'prv-4' || 'prv-5' => _careServices,
        _ => _menServices,
      };

  static ServiceUiModel byUuid(String uuid) => <ServiceUiModel>[
    ..._menServices,
    ..._womenServices,
    ..._careServices,
  ].firstWhere((s) => s.uuid == uuid, orElse: () => _menServices.first);
}
