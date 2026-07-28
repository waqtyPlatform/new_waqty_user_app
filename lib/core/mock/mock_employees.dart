import 'package:waqty_user_application/core/models/employee_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/public/bookings/available-employees
class MockEmployees {
  MockEmployees._();

  /// الأسعار مختلفة بالقصد. السعر في السيرفر بيختلف **لكل أخصائي** مش
  /// للخدمة، فلازم نتأكد إن الفرق ده باين للعميل قبل ما يختار.
  static const List<EmployeeUiModel> _staff = <EmployeeUiModel>[
    EmployeeUiModel(
      uuid: 'emp-1',
      name: 'أحمد محمود',
      imagePath: '',
      price: 300,
      durationMinutes: 45,
    ),
    EmployeeUiModel(
      uuid: 'emp-2',
      name: 'محمد سيد',
      imagePath: '',
      price: 250,
      durationMinutes: 45,
    ),
    EmployeeUiModel(
      uuid: 'emp-3',
      name: 'مصطفى خالد',
      imagePath: '',
      price: 250,
      durationMinutes: 50,
    ),
  ];

  /// «أي أخصائي متاح» أول القايمة دايمًا وهو الافتراضي — عشان منقللش
  /// المواعيد المتاحة قدام العميل قبل ما يشوفها.
  static List<EmployeeUiModel> forService(String serviceUuid) =>
      <EmployeeUiModel>[EmployeeUiModel.anyAvailable, ..._staff];

  static EmployeeUiModel byUuid(String uuid) => _staff.firstWhere(
    (e) => e.uuid == uuid,
    orElse: () => EmployeeUiModel.anyAvailable,
  );

  /// اسم بيتحط على الميعاد لما العميل مختار «أي أخصائي متاح».
  static String nameForSlot(int slotIndex) =>
      _staff[slotIndex % _staff.length].name;
}
