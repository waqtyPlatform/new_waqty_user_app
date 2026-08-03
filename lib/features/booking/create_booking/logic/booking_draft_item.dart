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

  /// **الاقتراحات — ٤–٦ مواعيد عبر كذا يوم.**
  ///
  /// دي الواجهة الافتراضية دلوقتي، مش شبكة الـ٣٠ شيب. العميل بيقول
  /// النافذة اللي تناسبه والأبلكيشن بيبحث، بدل العكس.
  List<SlotUiModel> proposals;

  /// النوافذ اللي العميل قابلها — فاضية = أي وقت.
  ///
  /// **مجموعة مش قيمة واحدة.** «أنا فاضي الصبح أو بالليل بس مش الضهر»
  /// جملة طبيعية، و«اختار واحدة» كانت هتجبره يقسم طلبه على مرتين.
  Set<SlotPeriod> periods;

  /// العميل فتح الشبكة الكاملة؟
  ///
  /// الاقتراحات بتغطي الحالة الغالبة، والشبكة بتفضل موجودة للي عايز
  /// ميعاد بعينه. **مفيش حاجة اتشالت** — اتنقلت ورا ضغطة.
  bool isBrowsingAll;

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
    this.proposals = const <SlotUiModel>[],
    Set<SlotPeriod>? periods,
    this.isBrowsingAll = false,
  }) : periods = periods ?? <SlotPeriod>{};

  bool get isScheduled => selectedSlot != null;

  /// السعر من الميعاد لو اتحدد — السعر بيختلف حسب الأخصائي والوقت،
  /// وسعر الخدمة المعروض في القايمة تقدير مبدئي بس.
  double get price => selectedSlot?.price ?? service.price;

  int get durationMinutes =>
      selectedSlot?.durationMinutes ?? service.durationMinutes;

  /// الاسم اللي بيتعرض للعميل **قبل التأكيد**.
  ///
  /// ## «أي أخصائي متاح» بتفضل «أي أخصائي متاح»
  ///
  /// كان بيرجّع `selectedSlot?.employeeName` — يعني اسم شخص بعينه. وده
  /// **وعد الأبلكيشن مش ماسكه**: التوزيع بيحصل **وقت الحفظ** جوه
  /// transaction بـ `lockForUpdate` باستراتيجية `first_available` أو
  /// `least_booked` (`BookingAvailabilityService`). فالاسم اللي كان
  /// بيتعرض تخمين، والعميل بيروح المحل ويلاقي حد تاني — يبقى الأبلكيشن
  /// كدب عليه.
  ///
  /// وحتى **لو** السيرفر كان ماسك التوزيع من بدري، العرض غلط: العميل
  /// اختار صراحة إنه مش فارقة معاه. تسمية شخص بترد على سؤال هو قرر
  /// مايسألوش، وبتحوّل اختيار مريح لالتزام.
  ///
  /// الاسم الحقيقي بيبان **بعد** التأكيد، من `BookingItemUiModel` اللي
  /// السيرفر بيرجّعه.
  String get resolvedEmployeeName => employee.name;

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
