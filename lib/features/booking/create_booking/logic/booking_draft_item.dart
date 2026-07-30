import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';

/// خدمة واحدة في سلة الحجز — **بكل حالة الاختيار بتاعتها**.
///
/// ده مقابل `blankItem()` في `NewBooking` بتاعة الداشبورد. المهم فيه إن
/// الأخصائي والتاريخ والمواعيد **جوه العنصر مش مشتركين**: كل خدمة ليها
/// أخصائي مختلف، والأخصائي المختلف معناه أيام متاحة مختلفة ومواعيد
/// مختلفة. لو سيبناهم مشتركين، اختيار في خدمة كان هيمسح اختيار في التانية.
class BookingDraftItem {
  /// هوية ثابتة للعنصر طول عمره في السلة.
  ///
  /// **مش `service.uuid`** — ده بيخلي الموديل مايمنعش نفس الخدمة مرتين
  /// لو احتجناها بعدين (الداشبورد بيسمح بيها). ومهم كمان لـ `Key` في
  /// الليستة عشان الـ widgets ما تتلغبطش لما عنصر يتشال من النص.
  final String key;

  final ServiceUiModel service;

  /// الافتراضي «أي أخصائي متاح» — ودي مش تفصيلة.
  ///
  /// أول ما نطلب من العميل يختار أخصائي، بنجبره على تفضيل هو أصلاً ملوش
  /// **وبنقلّل المواعيد المتاحة قبل ما يشوفها**. السيرفر بيوزّع لوحده
  /// لما الحقل يتبعت فاضي.
  EmployeeUiModel employee;
  List<EmployeeUiModel> employees;

  DateTime currentMonth;
  List<DateTime> availableDates;
  DateTime? selectedDate;

  List<SlotUiModel> slots;
  SlotUiModel? selectedSlot;

  /// الميعاد اللي حد تاني خده وإحنا بنأكد — بيتشخط في مكانه.
  SlotUiModel? takenSlot;

  /// كارت واحد بس بيبقى مفتوح في المرة.
  bool isExpanded;

  BookingDraftItem({
    required this.key,
    required this.service,
    required this.currentMonth,
    this.employee = EmployeeUiModel.anyAvailable,
    this.employees = const <EmployeeUiModel>[],
    this.availableDates = const <DateTime>[],
    this.selectedDate,
    this.slots = const <SlotUiModel>[],
    this.selectedSlot,
    this.takenSlot,
    this.isExpanded = false,
  });

  bool get isScheduled => selectedSlot != null;

  /// السعر من الميعاد لو اتحدد — السعر بيختلف حسب الأخصائي والوقت،
  /// وسعر الخدمة المعروض في القايمة تقدير مبدئي بس.
  double get price => selectedSlot?.price ?? service.price;

  int get durationMinutes =>
      selectedSlot?.durationMinutes ?? service.durationMinutes;

  /// الأخصائي اللي هيعمل الخدمة فعلاً.
  ///
  /// لما العميل سايب «أي أخصائي متاح»، الاسم الحقيقي بيبقى جوه الميعاد
  /// اللي السيرفر رجّعه — فبنعرضه هو مش النص العام.
  String get resolvedEmployeeName => employee.isAnyAvailable
      ? (selectedSlot?.employeeName ?? employee.name)
      : employee.name;

  /// اليوم من غير ساعة — مفتاح تجميع العناصر في زيارات.
  DateTime? get day {
    final slot = selectedSlot;
    if (slot == null) return null;
    return DateTime(slot.startAt.year, slot.startAt.month, slot.startAt.day);
  }

  /// السعر اللي الشيبات بتتقاس عليه فرق السعر.
  double get baselinePrice =>
      employee.isAnyAvailable ? service.price : employee.price;
}

/// الحد بين خدمتين في **نفس اليوم** — رحلة واحدة ولا اتنين؟
///
/// الحد بين يومين مالوش وجود هنا: ده حقيقة مش رأي، ومفيش رحلة بتمتد
/// على يومين.
class VisitBoundary {
  /// العنصر اللي **بعد** الحد — ده مفتاح التعديل.
  final String itemKey;

  /// الفارق بين نهاية الخدمة اللي قبله وبداية اللي بعده.
  final Duration gap;

  /// دلوقتي مفصول (زيارتين) ولا مدموج (زيارة واحدة)؟
  final bool isBreak;

  const VisitBoundary({
    required this.itemKey,
    required this.gap,
    required this.isBreak,
  });
}
