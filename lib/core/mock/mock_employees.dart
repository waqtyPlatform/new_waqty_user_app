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

  /// مين بيعمل إيه.
  ///
  /// **الربط ده حقيقي في السيرفر** — تعيينات (أخصائي × خدمة × فرع) بسعر
  /// ومدة لكل تعيين، وهي مصدر السعر في `PriceResolverService`. الـ mock
  /// كان بيتجاهل الـ `serviceUuid` تمامًا ويرجّع نفس التلاتة لكل خدمة،
  /// فمكانش ينفع نجرّب ولا واحدة من النتيجتين الحقيقيتين دول:
  ///
  ///   • **خدمة بأخصائي واحد** — الندرة بتغيّر اختيار العميل؟
  ///   • **خدمة مالهاش حد في الفرع** — الطريق المسدود متشرح ولا صامت؟
  ///
  /// الخدمات اللي مش في الخريطة بتاخد الفريق كله — عشان محلات تانية
  /// تفضل شغالة من غير ما نكتب كل خدمة فيها.
  static const Map<String, List<String>> _serviceStaff = <String, List<String>>{
    'srv-1': <String>['emp-1', 'emp-2', 'emp-3'], // قص شعر — الكل
    'srv-2': <String>['emp-2', 'emp-3'], // حلاقة ذقن
    'srv-3': <String>['emp-1'], // قص + ذقن — **واحد بس**
    'srv-5': <String>['emp-1', 'emp-3'], // حمام كريم
    'srv-7': <String>[], // فرد بروتين — **محدش في الفرع ده**
  };

  /// «أي أخصائي متاح» أول القايمة دايمًا وهو الافتراضي — عشان منقللش
  /// المواعيد المتاحة قدام العميل قبل ما يشوفها.
  ///
  /// بترجّع **ليستة فاضية بالكامل** لما مفيش حد بيعمل الخدمة — من غير
  /// «أي أخصائي متاح» كمان، لأن مفيش أي حد يتوزّع عليه. اللي بينده
  /// بيقرا الفراغ ده ويعرض طريق مسدود مشروح.
  static List<EmployeeUiModel> forService(String serviceUuid) {
    final allowed = _serviceStaff[serviceUuid];
    final staff = allowed == null
        ? _staff
        : _staff.where((e) => allowed.contains(e.uuid)).toList();

    if (staff.isEmpty) return const <EmployeeUiModel>[];

    return <EmployeeUiModel>[EmployeeUiModel.anyAvailable, ...staff];
  }

  static EmployeeUiModel byUuid(String uuid) => _staff.firstWhere(
    (e) => e.uuid == uuid,
    orElse: () => EmployeeUiModel.anyAvailable,
  );

  /// الأخصائي اللي بياخد الميعاد ده لما العميل سايب «أي أخصائي متاح».
  static EmployeeUiModel forSlot(int slotIndex) =>
      _staff[slotIndex % _staff.length];

  /// اسم بيتحط على الميعاد لما العميل مختار «أي أخصائي متاح».
  static String nameForSlot(int slotIndex) => forSlot(slotIndex).name;

  /// أرخص سعر في الفريق — الأساس اللي الفروق بتتقاس منه.
  static double get _cheapestPrice =>
      _staff.map((e) => e.price).reduce((a, b) => a < b ? a : b);

  /// الزيادة اللي الأخصائي بتاع الميعاد ده بياخدها فوق أرخص واحد في الفريق.
  ///
  /// **فرق مش سعر مطلق — وده مقصود.** [EmployeeUiModel.price] هنا رقم
  /// واحد لكل أخصائي، بينما السيرفر بيحدد السعر لكل **(أخصائي × خدمة)**
  /// من سلسلة `PriceResolverService`. فلو حطينا ٣٠٠ بتاعة أحمد كسعر
  /// مطلق على ميعاد «فرد بروتين» بـ١٢٠٠، السعر يطلع غلط بالكامل.
  /// الفرق بيشتغل صح مع أي خدمة مهما كان سعرها.
  static double priceDeltaForSlot(int slotIndex) =>
      forSlot(slotIndex).price - _cheapestPrice;
}
