import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';

/// خطوات الحجز.
///
/// خطوة الخدمة بتتخطى لما العميل يدخل من صف خدمة معيّنة — وده الطريق
/// الطبيعي، فالحالة الشائعة خطوتين مش تلاتة.
enum BookingStep { service, dateTime, confirm }

class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit({
    required this.providerUuid,
    required this.providerName,
    String? initialServiceUuid,
  }) : super(InitialState()) {
    branches = MockProviders.branchesOf(providerUuid);
    selectedBranch = branches.isEmpty ? null : branches.first;
    services = MockServices.ofProvider(providerUuid);

    if (initialServiceUuid != null && initialServiceUuid.isNotEmpty) {
      selectedService = MockServices.byUuid(initialServiceUuid);
      currentStep = BookingStep.dateTime;
    }
  }

  final String providerUuid;
  final String providerName;

  BookingStep currentStep = BookingStep.service;

  List<BranchUiModel> branches = <BranchUiModel>[];
  BranchUiModel? selectedBranch;

  List<ServiceUiModel> services = <ServiceUiModel>[];
  ServiceUiModel? selectedService;

  List<EmployeeUiModel> employees = <EmployeeUiModel>[];

  /// الافتراضي «أي أخصائي متاح».
  ///
  /// ده أهم قرار في الفلو كله: لما نطلب من العميل يختار أخصائي الأول،
  /// بنجبره على تفضيل هو أصلاً ملوش، **وبنقلّل المواعيد المتاحة قبل ما
  /// يشوفها** — وده السبب الأول اللي بيخلي حد يشوف «مفيش مواعيد» وهي
  /// مش صح. والسيرفر بيختار لوحده لما نبعتله فاضي.
  EmployeeUiModel selectedEmployee = EmployeeUiModel.anyAvailable;

  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<DateTime> availableDates = <DateTime>[];
  DateTime? selectedDate;

  List<SlotUiModel> slots = <SlotUiModel>[];
  SlotUiModel? selectedSlot;

  /// الميعاد اللي اتحجز من حد تاني — بيتشخط في مكانه.
  SlotUiModel? takenSlot;

  final TextEditingController notesController = TextEditingController();
  bool isNotesExpanded = false;

  /// شهرين محمّلين قدام. الـ key: «فرع|خدمة|أخصائي|شهر».
  final Map<String, List<DateTime>> _datesCache = <String, List<DateTime>>{};

  // ── الاختيارات ───────────────────────────────────────────────────────

  void selectBranch(BranchUiModel branch) {
    selectedBranch = branch;
    // تغيير الفرع بيلغي كل اللي بعده — الأخصائيين والمواعيد بيختلفوا.
    _clearFrom(clearService: false);
    emit(OnSelectionChangedState());
  }

  void selectService(ServiceUiModel service) {
    selectedService = service;
    _clearFrom(clearService: false);
    emit(OnSelectionChangedState());
  }

  void selectEmployee(EmployeeUiModel employee) {
    selectedEmployee = employee;
    // الأخصائي اتغيّر — التواريخ والمواعيد لازم تتحمّل من الأول،
    // بس الشهر بيفضل زي ما هو.
    availableDates = <DateTime>[];
    selectedDate = null;
    slots = <SlotUiModel>[];
    selectedSlot = null;
    emit(OnSelectionChangedState());
    loadDates();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    slots = <SlotUiModel>[];
    selectedSlot = null;
    takenSlot = null;
    emit(OnSelectionChangedState());
    loadSlots();
  }

  void selectSlot(SlotUiModel slot) {
    selectedSlot = slot;
    emit(OnSelectionChangedState());
  }

  void toggleNotes() {
    isNotesExpanded = !isNotesExpanded;
    emit(OnSelectionChangedState());
  }

  void _clearFrom({required bool clearService}) {
    if (clearService) selectedService = null;
    employees = <EmployeeUiModel>[];
    selectedEmployee = EmployeeUiModel.anyAvailable;
    availableDates = <DateTime>[];
    selectedDate = null;
    slots = <SlotUiModel>[];
    selectedSlot = null;
    takenSlot = null;
  }

  // ── الخطوات ──────────────────────────────────────────────────────────

  void goToStep(BookingStep step) {
    currentStep = step;
    emit(OnStepChangedState());
  }

  void nextStep() {
    if (currentStep == BookingStep.service && selectedService != null) {
      currentStep = BookingStep.dateTime;
      emit(OnStepChangedState());
      loadDateTimeStep();
    } else if (currentStep == BookingStep.dateTime && selectedSlot != null) {
      currentStep = BookingStep.confirm;
      emit(OnStepChangedState());
    }
  }

  void previousStep() {
    if (currentStep == BookingStep.confirm) {
      currentStep = BookingStep.dateTime;
    } else if (currentStep == BookingStep.dateTime) {
      currentStep = BookingStep.service;
    }
    emit(OnStepChangedState());
  }

  bool get canGoNext => switch (currentStep) {
    BookingStep.service => selectedService != null && selectedBranch != null,
    BookingStep.dateTime => selectedSlot != null,
    BookingStep.confirm => true,
  };

  // ── تحميل المواعيد ───────────────────────────────────────────────────

  Future<void> loadDateTimeStep() async {
    // TODO(api): GET /api/public/bookings/available-employees
    employees = MockEmployees.forService(selectedService?.uuid ?? '');
    await loadDates();
  }

  Future<void> loadDates() async {
    emit(LoadingDatesState());

    final key = _cacheKey(currentMonth);
    if (_datesCache.containsKey(key)) {
      availableDates = _datesCache[key]!;
    } else {
      // TODO(api): GET /api/public/bookings/available-dates?month=
      final result = await MockSource.fetchList(
        MockSlots.availableDates(month: currentMonth),
      );

      final failure = result.fold<String?>((l) => l, (_) => null);
      if (failure != null) {
        emit(CreateBookingErrorState(message: failure));
        return;
      }

      availableDates = result.getOrElse(() => <DateTime>[]);
      _datesCache[key] = availableDates;
    }

    // الشهر ده فاضي؟ منسيبش العميل يكتشف الفراغ بنفسه — ننط لأقرب
    // شهر فيه مواعيد.
    if (availableDates.isEmpty) {
      final firstAvailable = MockSlots.firstAvailableDate();
      if (firstAvailable != null &&
          (firstAvailable.month != currentMonth.month ||
              firstAvailable.year != currentMonth.year)) {
        currentMonth = DateTime(firstAvailable.year, firstAvailable.month);
        await loadDates();
        return;
      }
      emit(OnSelectionChangedState());
      return;
    }

    // أول يوم فاضي بيتحدد لوحده ومواعيده بتتحمّل — الـ sheet بيفتح
    // وهو مفيد من أول ثانية بدل ما العميل يدوّر.
    selectedDate ??= availableDates.first;
    await loadSlots();
  }

  Future<void> loadSlots() async {
    if (selectedDate == null) return;

    emit(LoadingSlotsState());

    // TODO(api): GET /api/public/bookings/available-slots?date=
    final result = await MockSource.fetchList(
      MockSlots.slotsFor(
        date: selectedDate!,
        durationMinutes: selectedService?.durationMinutes ?? 45,
        basePrice: selectedEmployee.isAnyAvailable
            ? (selectedService?.price ?? 250)
            : selectedEmployee.price,
      ),
    );

    result.fold((failure) => emit(CreateBookingErrorState(message: failure)), (
      data,
    ) {
      slots = data;
      emit(OnSelectionChangedState());
    });
  }

  void changeMonth(int offset) {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
    selectedDate = null;
    slots = <SlotUiModel>[];
    selectedSlot = null;
    emit(OnSelectionChangedState());
    loadDates();
  }

  /// مانرجعش لشهر فات — المواعيد اللي عدّت مالهاش لازمة.
  bool get canGoToPreviousMonth {
    final now = DateTime.now();
    return currentMonth.isAfter(DateTime(now.year, now.month));
  }

  String _cacheKey(DateTime month) {
    final employeeKey = selectedEmployee.isAnyAvailable
        ? 'any'
        : selectedEmployee.uuid;
    return '${selectedBranch?.uuid}|${selectedService?.uuid}|$employeeKey|${month.year}-${month.month}';
  }

  // ── التأكيد ──────────────────────────────────────────────────────────

  Future<void> confirmBooking() async {
    emit(CreateBookingLoadingState());

    // TODO(api): POST /api/user/bookings
    // ملحوظة وقت الربط: الميعاد راجع من السيرفر بصيغة H:i:s بس الـ request
    // بيقبل H:i بس — لازم نقص الثواني قبل الإرسال وإلا هيرجع 422.
    await Future.delayed(const Duration(milliseconds: 800));

    // مؤقتًا للتجربة: أي ميعاد الدقيقة فيه ١٥ بنعتبره اتحجز من حد تاني،
    // عشان نقدر نجرّب شاشة «الميعاد راح» من غير جهازين.
    if (selectedSlot != null && selectedSlot!.startAt.minute == 15) {
      takenSlot = selectedSlot;
      selectedSlot = null;
      currentStep = BookingStep.dateTime;
      await loadSlots();
      emit(SlotTakenState());
      return;
    }

    emit(CreateBookingSuccessState());
  }

  /// حجز النهاردة مايتلغيش بعد التأكيد — قاعدة موجودة في السيرفر
  /// والعميل مكانش بيعرفها غير بعد ما يقع فيها.
  bool get isSameDayBooking {
    if (selectedSlot == null) return false;
    final now = DateTime.now();
    final slot = selectedSlot!.startAt;
    return slot.year == now.year &&
        slot.month == now.month &&
        slot.day == now.day;
  }

  @override
  Future<void> close() {
    notesController.dispose();
    return super.close();
  }

  static CreateBookingCubit get(context) => BlocProvider.of(context);
}
