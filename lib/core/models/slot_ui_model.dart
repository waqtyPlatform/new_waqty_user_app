import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// موديل عرض للميعاد المتاح.
enum SlotPeriod { morning, afternoon, evening }

class SlotUiModel {
  /// «١٨:٠٠» بصيغة ٢٤ ساعة — ده اللي بيتبعت للسيرفر.
  /// الشكل اللي بيتعرض للعميل بيتولّد من [DateTime] في الـ formatter.
  final DateTime startAt;
  final DateTime endAt;
  final double price;

  /// اسم الأخصائي اللي هيتحدد لو العميل مختار «أي أخصائي متاح».
  ///
  /// **فاضي في وضع «أي أخصائي متاح» الجاي من السيرفر** — ورد
  /// `slotsForAnyEmployee` بيرجّع `employees[]` (كل اللي فاضيين) مش
  /// أخصائي واحد، لأن التوزيع بيحصل **وقت الحفظ** جوه transaction
  /// بـ `lockForUpdate`. أي اسم نعرضه قبل كده تخمين.
  final String employeeName;

  /// كام أخصائي فاضي في الميعاد ده — من `available_employees_count`.
  /// `null` لما العميل مختار أخصائي بعينه (الرد ساعتها مافيهوش الحقل).
  final int? availableEmployeesCount;

  /// نص الـ `start_at` **الخام** زي ما رجع من السيرفر.
  ///
  /// السيرفر بيرجّع الميعاد بصيغة ISO 8601 كاملة بالـ offset، والـ
  /// `StoreBookingRequest` بيقبل نفس الصيغة بالظبط في
  /// `visits.*.items.*.start_at`. فبنمرّره زي ما هو بدل ما نفكّه لـ
  /// [DateTime] ونعيد بناءه — إعادة البناء بتخاطر بإزاحة في المنطقة
  /// الزمنية بين توقيت الفرع وتوقيت جهاز العميل.
  ///
  /// `null` في الـ mock بس، وساعتها [startAtPayload] بيولّده.
  final String? startAtRaw;

  const SlotUiModel({
    required this.startAt,
    required this.endAt,
    required this.price,
    this.employeeName = '',
    this.availableEmployeesCount,
    this.startAtRaw,
  });

  /// من `GET /api/public/bookings/available-slots`.
  ///
  /// ## الرد ليه **شكلين**، والفرق بينهم بيوقّع
  ///
  /// أخصائي بعينه (`slotsForEmployee`):
  /// `{..., price, effective_price, currency, employee: {uuid, name}}`
  ///
  /// أي أخصائي (`slotsForAnyEmployee`) — **مافيهوش مفتاح `price` خالص**:
  /// `{..., effective_price, currency, available_employees_count, employees: []}`
  ///
  /// موديل واحد بيقرا `price` مباشرة كان هيقع على المسار التاني — وهو
  /// **المسار الافتراضي**، يعني كان هيقع أول ما يتربط. عشان كده بنقرا
  /// `effective_price` الأول (موجود في الاتنين) والباقي fallback.
  ///
  /// والمفاتيح `snake_case` — `ApiResponse` مابيحوّلش أسماء المفاتيح.
  factory SlotUiModel.fromJson(Map<String, dynamic> json) {
    final start = JsonParse.dateValue(json['start_at']);
    final employee = JsonParse.mapValue(json['employee']);
    final employees = JsonParse.mapListValue(json['employees']);

    return SlotUiModel(
      startAt: start,
      endAt:
          JsonParse.dateOrNull(json['end_at']) ??
          start.add(
            Duration(minutes: JsonParse.intValue(json['duration_minutes'])),
          ),
      price: JsonParse.doubleValue(json['effective_price'] ?? json['price']),
      // مفيش اسم في وضع «أي أخصائي متاح» — وده مقصود، مش نقص في البيانات.
      employeeName: JsonParse.stringValue(employee['name']),
      availableEmployeesCount:
          JsonParse.intOrNull(json['available_employees_count']) ??
          (employees.isEmpty ? null : employees.length),
      startAtRaw: JsonParse.stringValue(json['start_at']),
    );
  }

  /// القيمة اللي بتتحط في الـ payload.
  String get startAtPayload => startAtRaw ?? AppFormat.serverDateTime(startAt);

  int get durationMinutes => endAt.difference(startAt).inMinutes;

  SlotPeriod get period {
    if (startAt.hour < 12) return SlotPeriod.morning;
    if (startAt.hour < 17) return SlotPeriod.afternoon;
    return SlotPeriod.evening;
  }
}

extension SlotPeriodLabel on SlotPeriod {
  String get label => switch (this) {
    SlotPeriod.morning => 'صباحًا',
    SlotPeriod.afternoon => 'بعد الظهر',
    SlotPeriod.evening => 'مساءً',
  };
}
