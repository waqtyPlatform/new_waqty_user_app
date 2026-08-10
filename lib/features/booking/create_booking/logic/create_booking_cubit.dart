import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';

/// خطوات الحجز.
///
/// خطوة الخدمة بتتخطى لما العميل يدخل من صف خدمة معيّنة — وده الطريق
/// الطبيعي، فالحالة الشائعة خطوتين مش تلاتة.
enum BookingStep { service, dateTime, confirm }

/// الحجز — **سلة خدمات، مش خدمة واحدة**.
///
/// السيرفر بيقبل من زمان لحد ٢٠ زيارة × ٥٠ خدمة في الحجز الواحد
/// (`visits[].items[]` في `StoreBookingRequest`)، ونفس الـ payload اللي
/// داشبورد المزود بيبعته. الموبايل كان بيستخدم الحالة الأبسط بس —
/// خدمة واحدة — والسيرفر كان بيلفّها في زيارة واحدة ويكمّل.
///
/// ## الزيارات بتتحدد لوحدها
///
/// الزيارة في السيرفر **تجميعة مش معلومة زيادة**: كل عنصر شايل تاريخه
/// بنفسه و`scheduled_start_at` بتاعة الزيارة بتتحسب `min/max` للعناصر.
/// فبنجمّع العناصر **باليوم** عند الإرسال بدل ما نعلّم العميل مفهوم
/// «زيارة» وهو بيحجز. هو بيضيف خدمات ويحدّد ميعاد لكل واحدة، وبيشوف
/// كلمة «الزيارة» في التأكيد بس كعنوان يوم.
class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit({
    required this.providerUuid,
    required this.providerName,
    String? initialServiceUuid,
    BranchUiModel? initialBranch,
    String? initialBranchUuid,
  }) : super(InitialState()) {
    branches = MockProviders.branchesOf(providerUuid);

    // **الفرع اللي العميل اختاره في شاشة المحل، مش أول واحد في القايمة.**
    //
    // `changeBranch` في `ServiceProviderDetailsCubit` كان شغال، بس القيمة
    // مكانتش بتتنقل هنا خالص — فعميل اختار «فرع مدينة نصر» كان `buildPayload`
    // بيبعتله `branch_uuid` بتاع «فرع المعادي». ده مكانش صمت في الـ UI،
    // ده داتا غلط رايحة للسيرفر.
    //
    // بنطابق بالـ uuid مش بالكائن نفسه عشان مصادر الفروع تفضل تقدر تختلف
    // — شاشة المحل بتبعت الكائن، و«احجز تاني» عنده الـ uuid بس (جاي من
    // `BookingUiModel.branchUuid`).
    final wantedBranch = initialBranch?.uuid ?? initialBranchUuid;
    selectedBranch = branches.isEmpty
        ? null
        : branches.firstWhere(
            (b) => b.uuid == wantedBranch,
            orElse: () => branches.first,
          );

    // **بسعر الفرع المختار** — نفس اللي صفحة المحل بتعرضه.
    //
    // كانت `ofProvider` (سعر الفرع الرئيسي دايمًا)، فالعميل الواقف على
    // الفرع التاني كان يشوف ٢٩٠ في الصفحة ويدوس فيلاقي ٢٥٠ في الـ sheet.
    // تناقض في ضغطة واحدة، وهو بالظبط اللي بُعد الفرع اتعمل عشانه.
    services = MockServices.ofBranch(
      providerUuid: providerUuid,
      branchUuid: selectedBranch?.uuid,
    );

    if (initialServiceUuid != null && initialServiceUuid.isNotEmpty) {
      // من القايمة المسعّرة الأول. الـ fallback لـ`byUuid` للخدمة اللي
      // مش متاحة في الفرع ده — «احجز تاني» بيقدر يجيب خدمة اتحجزت قبل
      // كده في فرع تاني.
      final service = services.firstWhere(
        (s) => s.uuid == initialServiceUuid,
        orElse: () => MockServices.byUuid(initialServiceUuid),
      );
      _addItem(service);
      currentStep = BookingStep.dateTime;
    }
  }

  /// **سلة جاهزة — من غير أي تحميل.**
  ///
  /// ## ليه موجود
  ///
  /// الـ constructor العادي بيبدأ بسلة نص جاهزة وبيحمّل الأخصائيين
  /// والتواريخ والمواعيد على مراحل (`enterDateTimeStep` → `_ensureLoaded`
  /// → `loadProposalsFor` …). عشان توصّل الـ cubit لحالة **«كل خدمة ليها
  /// ميعاد»** — وهي الحالة الوحيدة اللي خطوة الملخص بترسمها — لازم تشغّل
  /// الفلو كله وتستنى كل مرحلة.
  ///
  /// وده **مابينفعش في الاختبارات**: الـ cubit بيشغّل مؤقت مهلة الحجز،
  /// فـ`pumpAndSettle` عمره ما بيرجع، و`Future.delayed` بتاعة الـ mock
  /// مابتتقدّمش جوه الـ fake async بتاع `flutter_test`.
  ///
  /// الـ constructor ده بياخد السلة **مبنية من برّه** ومابينادي ولا دالة
  /// تحميل. الفرق الوحيد عن العادي هو **من فين السلة جت** — كل السلوك
  /// اللي بعد كده (الأسعار، الزيارات، الفواصل، الـ payload) نفسه بالحرف،
  /// فاللي الاختبار بيقيسه هو الكود الحقيقي مش نسخة منه.
  ///
  /// مفيد كمان في المعاينة وفي الـ mock scenarios لو احتجناها بعدين.
  CreateBookingCubit.seeded({
    required this.providerUuid,
    required this.providerName,
    required List<BookingDraftItem> draft,
    BranchUiModel? branch,
    BookingStep step = BookingStep.confirm,
  }) : super(InitialState()) {
    branches = MockProviders.branchesOf(providerUuid);
    selectedBranch = branch ?? (branches.isEmpty ? null : branches.first);
    services = MockServices.ofProvider(providerUuid);

    items.addAll(draft);
    currentStep = step;

    // العدّاد بيبدأ بعد آخر مفتاح مبذور — عشان أي `_addItem` بعد كده
    // مايدّيش مفتاح متكرر.
    _keyCounter = draft.length;
  }

  final String providerUuid;
  final String providerName;

  BookingStep currentStep = BookingStep.service;

  List<BranchUiModel> branches = <BranchUiModel>[];
  BranchUiModel? selectedBranch;

  List<ServiceUiModel> services = <ServiceUiModel>[];

  /// السلة. الترتيب = ترتيب الاختيار.
  final List<BookingDraftItem> items = <BookingDraftItem>[];

  final TextEditingController notesController = TextEditingController();
  bool isNotesExpanded = false;

  /// شهرين محمّلين قدام. الـ key: «فرع|خدمة|أخصائي|شهر».
  ///
  /// **مشترك بين كل عناصر السلة** — خدمتين بنفس المدة ونفس الأخصائي
  /// بيستفيدوا من نفس الطلب بدل ما كل واحدة تروح للسيرفر لوحدها.
  final Map<String, List<DateTime>> _datesCache = <String, List<DateTime>>{};

  int _keyCounter = 0;

  // ── السلة ────────────────────────────────────────────────────────────

  BookingDraftItem? itemByKey(String key) {
    for (final item in items) {
      if (item.key == key) return item;
    }
    return null;
  }

  bool isServiceSelected(String serviceUuid) =>
      items.any((i) => i.service.uuid == serviceUuid);

  void _addItem(ServiceUiModel service) {
    final now = DateTime.now();
    items.add(
      BookingDraftItem(
        key: 'item-${_keyCounter++}',
        service: service,
        currentMonth: DateTime(now.year, now.month),
      ),
    );
  }

  /// إضافة أو شيل خدمة من السلة.
  void toggleService(ServiceUiModel service) {
    final existing = items.where((i) => i.service.uuid == service.uuid);
    if (existing.isEmpty) {
      _addItem(service);
    } else {
      items.removeWhere((i) => i.service.uuid == service.uuid);
    }
    emit(OnSelectionChangedState());
  }

  void removeItem(String key) {
    items.removeWhere((i) => i.key == key);
    _boundaryOverrides.remove(key);

    // شِلنا الكارت المفتوح؟ نفتح اللي بعده بدل ما الخطوة تفضل كلها مقفولة.
    if (items.isNotEmpty && !items.any((i) => i.isExpanded)) {
      _expandNextUnscheduled();
      return;
    }
    emit(OnSelectionChangedState());
  }

  // ── الأكورديون ───────────────────────────────────────────────────────

  /// فتح كارت — وقفل الباقي.
  ///
  /// كارت واحد في المرة بالقصد: تلات خدمات كل واحدة فيها صف أخصائي وشريط
  /// تواريخ وشبكة مواعيد بيبقوا صفحة مالهاش نهاية على موبايل. والقفل
  /// بيخلي الـ N خدمات يتحسّوا **تتابع موجّه** مش استمارة.
  void expandItem(String key) {
    for (final item in items) {
      item.isExpanded = item.key == key;
    }
    emit(OnSelectionChangedState());

    final item = itemByKey(key);
    if (item != null) _ensureLoaded(item);
  }

  void collapseAll() {
    for (final item in items) {
      item.isExpanded = false;
    }
    emit(OnSelectionChangedState());
  }

  /// **بيعمل `emit` بنفسه — اللي بينده ماينفعش يعمل واحد بعده.**
  ///
  /// `_ensureLoaded` بينده `loadDatesFor` اللي بيعمل `emit(LoadingDatesState)`
  /// **بشكل متزامن** قبل ما يستنى الشبكة. فلو اللي نادانا عمل
  /// `emit(OnSelectionChangedState)` بعدينا، بيدهس حالة التحميل — والكارت
  /// بيتفتح على «اليوم ده مليان» بدل الـ skeleton لحد ما الداتا توصل.
  void _expandNextUnscheduled() {
    for (final item in items) {
      item.isExpanded = false;
    }
    final next = items.where((i) => !i.isScheduled);
    if (next.isEmpty) {
      emit(OnSelectionChangedState());
      return;
    }

    next.first.isExpanded = true;
    emit(OnSelectionChangedState());
    _ensureLoaded(next.first);
  }

  // ── الاختيارات ───────────────────────────────────────────────────────

  void selectBranch(BranchUiModel branch) {
    if (branch.uuid == selectedBranch?.uuid) return;

    selectedBranch = branch;

    // الفرع اتغيّر — الأخصائيين والمواعيد كلها بتختلف، فكل اختيارات
    // التوقيت في السلة بتتلغي. الخدمات نفسها بتفضل.
    //
    // ⚠ **الأسعار في السلة مابتتسعّرش من جديد هنا.** إعادة التسعير جوه
    // الـ sheet معناها إن خدمة في السلة ممكن تختفي من الفرع الجديد،
    // ومفيش تعامل مع ده — والسؤال «نشيلها؟ نسيبها بسعرها القديم؟ نمنع
    // التغيير؟» سؤال منتج مش توصيلة. أسبوع ٢.
    for (final item in items) {
      _clearScheduling(item);
    }
    _datesCache.clear();
    emit(OnSelectionChangedState());

    // **الكارت المفتوح لازم يعيد تحميل نفسه.**
    //
    // `_clearScheduling` بيفضّي التواريخ والمواعيد، و`enterDateTimeStep`
    // بيرجع من غير ما يعمل حاجة لو فيه كارت مفتوح (وهو مفتوح دايمًا في
    // الأكورديون). فمن غير السطور دي الكارت بيفضل مفتوح على تقويم من غير
    // أيام ومواعيد فاضية، والعميل مش عارف هو مستني تحميل ولا الفرع
    // الجديد مالوش مواعيد أصلاً.
    final expanded = items.where((i) => i.isExpanded).toList();
    if (expanded.isEmpty) {
      enterDateTimeStep();
      return;
    }
    _ensureLoaded(expanded.first);
  }

  void selectEmployee(String key, EmployeeUiModel employee) {
    final item = itemByKey(key);
    if (item == null) return;

    item.employee = employee;
    // الأخصائي اتغيّر — التواريخ والمواعيد لازم تتحمّل من الأول، بس
    // الشهر والنوافذ المختارة بيفضلوا زي ما هم (دول تفضيل العميل مش
    // نتيجة بحث).
    item.availableDates = <DateTime>[];
    item.selectedDate = null;
    item.slots = <SlotUiModel>[];
    item.selectedSlot = null;
    item.proposals = <SlotUiModel>[];
    emit(OnSelectionChangedState());
    loadProposalsFor(key);
    if (item.isBrowsingAll) loadDatesFor(key);
  }

  void selectDate(String key, DateTime date) {
    final item = itemByKey(key);
    if (item == null) return;

    item.selectedDate = date;
    item.slots = <SlotUiModel>[];
    item.selectedSlot = null;
    item.takenSlot = null;
    emit(OnSelectionChangedState());
    loadSlotsFor(key);
  }

  /// اختيار ميعاد — **وبعديها الكارت بيقفل واللي بعده بيتفتح لوحده**.
  ///
  /// ده اللي بيحوّل السلة من استمارة لتتابع. من غيره العميل بيختار ميعاد
  /// وبعدين لازم يفكّر «طب وبعدين؟» ويدوّر بنفسه على الكارت التاني.
  void selectSlot(String key, SlotUiModel slot) {
    final item = itemByKey(key);
    if (item == null) return;

    item.selectedSlot = slot;

    // **اليوم بيتبع الميعاد.**
    //
    // الاقتراحات بتعدّي على كذا يوم، فميعاد مختار من اقتراح ممكن يكون
    // في يوم غير اللي الشريط واقف عليه. من غير السطر ده، العميل يفتح
    // «كل المواعيد» بعد ما يختار فيلاقي نفسه في يوم تاني.
    item.selectedDate = DateTime(
      slot.startAt.year,
      slot.startAt.month,
      slot.startAt.day,
    );

    // التعديل اليدوي على الحد كان جواب على أوقات بعينها. الوقت اتغيّر،
    // فالجواب رجع للفارق يقرره.
    _boundaryOverrides.remove(key);

    if (items.any((i) => !i.isScheduled)) {
      // بيعمل الـ emit بنفسه — بص على التعليق فوقه.
      _expandNextUnscheduled();
      return;
    }

    item.isExpanded = false;
    emit(OnSelectionChangedState());
  }

  void changeMonth(String key, int offset) {
    final item = itemByKey(key);
    if (item == null) return;

    item.currentMonth = DateTime(
      item.currentMonth.year,
      item.currentMonth.month + offset,
    );
    item.selectedDate = null;
    item.slots = <SlotUiModel>[];
    item.selectedSlot = null;
    emit(OnSelectionChangedState());
    loadDatesFor(key);
  }

  /// مانرجعش لشهر فات — المواعيد اللي عدّت مالهاش لازمة.
  bool canGoToPreviousMonth(BookingDraftItem item) {
    final now = DateTime.now();
    return item.currentMonth.isAfter(DateTime(now.year, now.month));
  }

  void toggleNotes() {
    isNotesExpanded = !isNotesExpanded;
    emit(OnSelectionChangedState());
  }

  void _clearScheduling(BookingDraftItem item) {
    item.employees = <EmployeeUiModel>[];
    item.employee = EmployeeUiModel.anyAvailable;
    item.availableDates = <DateTime>[];
    item.selectedDate = null;
    item.slots = <SlotUiModel>[];
    item.selectedSlot = null;
    item.takenSlot = null;
    item.proposals = <SlotUiModel>[];
  }

  // ── الخطوات ──────────────────────────────────────────────────────────

  void goToStep(BookingStep step) {
    currentStep = step;
    emit(OnStepChangedState());
    if (step == BookingStep.dateTime) enterDateTimeStep();
  }

  /// الرجوع لخطوة المواعيد **وفتح خدمة بعينها** — «تغيير» في التأكيد.
  void goToItem(String key) {
    currentStep = BookingStep.dateTime;
    emit(OnStepChangedState());
    expandItem(key);
  }

  void nextStep() {
    if (currentStep == BookingStep.service && items.isNotEmpty) {
      currentStep = BookingStep.dateTime;
      emit(OnStepChangedState());
      enterDateTimeStep();
    } else if (currentStep == BookingStep.dateTime && _allScheduled) {
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

  bool get _allScheduled =>
      items.isNotEmpty && items.every((i) => i.isScheduled);

  bool get canGoNext => switch (currentStep) {
    BookingStep.service => items.isNotEmpty && selectedBranch != null,
    BookingStep.dateTime => _allScheduled,
    BookingStep.confirm => true,
  };

  // ── التحميل ──────────────────────────────────────────────────────────

  /// أول ما ندخل خطوة المواعيد بنفتح أول خدمة من غير ميعاد ونحمّلها.
  void enterDateTimeStep() {
    if (items.isEmpty) return;
    if (items.any((i) => i.isExpanded)) return;
    // بيعمل الـ emit بنفسه.
    _expandNextUnscheduled();
  }

  Future<void> _ensureLoaded(BookingDraftItem item) async {
    if (item.employees.isEmpty) {
      // TODO(api): GET /api/public/bookings/available-employees
      item.employees = MockEmployees.forService(item.service.uuid);
    }
    // مفيش حد بيعمل الخدمة دي هنا — الكارت بيعرض طريق مسدود، ومفيش
    // لزمة نحمّل مواعيد لحاجة مش هتتحجز.
    if (item.employees.isEmpty) return;

    // **الاقتراحات هي الافتراضي دلوقتي.** التواريخ بتتحمّل لما العميل
    // يفتح الشبكة الكاملة بس — يعني الحالة الغالبة بقت نداء واحد بدل
    // نداء تواريخ + نداء مواعيد اليوم.
    if (item.proposals.isEmpty) {
      await loadProposalsFor(item.key);
    }
    if (item.isBrowsingAll && item.availableDates.isEmpty) {
      await loadDatesFor(item.key);
    }
  }

  // ── الاقتراحات (Phase 4) ─────────────────────────────────────────────

  /// بيقلب نافذة وقت — والاقتراحات بتتحدّث على طول.
  void togglePeriod(String key, SlotPeriod period) {
    final item = itemByKey(key);
    if (item == null) return;

    if (!item.periods.remove(period)) item.periods.add(period);
    emit(OnSelectionChangedState());
    loadProposalsFor(key);
  }

  /// بيفتح/يقفل الشبكة الكاملة.
  ///
  /// أول فتح بيحمّل التواريخ — الشبكة محتاجة شريط الأيام، والاقتراحات لأ.
  void toggleBrowseAll(String key) {
    final item = itemByKey(key);
    if (item == null) return;

    item.isBrowsingAll = !item.isBrowsingAll;
    emit(OnSelectionChangedState());

    if (item.isBrowsingAll && item.availableDates.isEmpty) {
      loadDatesFor(key);
    }
  }

  Future<void> loadProposalsFor(String key) async {
    final item = itemByKey(key);
    if (item == null) return;

    emit(LoadingSlotsState(itemKey: key));

    // TODO(api): GET /api/public/bookings/available-slots على كذا يوم.
    //   الـ endpoint الحالي بياخد **يوم واحد**، فالاقتراحات عبر أسبوعين
    //   معناها N نداءات. الطلب للباك إند: باراميتر مدى تواريخ، أو
    //   endpoint اقتراحات يرجّع أحسن K مواعيد.
    final result = await MockSource.fetchList(
      MockSlots.proposals(
        durationMinutes: item.service.durationMinutes,
        basePrice: item.baselinePrice,
        anyAvailable: item.employee.isAnyAvailable,
        periods: item.periods,
      ),
    );

    result.fold((failure) => emit(CreateBookingErrorState(message: failure)), (
      data,
    ) {
      item.proposals = data;
      emit(OnSelectionChangedState());
    });
  }

  Future<void> loadDatesFor(String key) async {
    final item = itemByKey(key);
    if (item == null) return;

    emit(LoadingDatesState(itemKey: key));

    final cacheKey = _cacheKey(item, item.currentMonth);
    if (_datesCache.containsKey(cacheKey)) {
      item.availableDates = _datesCache[cacheKey]!;
    } else {
      // TODO(api): GET /api/public/bookings/available-dates?month=
      final result = await MockSource.fetchList(
        MockSlots.availableDates(
          month: item.currentMonth,
          // **مدة الخدمة الحقيقية.** من غيرها التقويم بيتحسب بـ٤٥ دقيقة
          // لكل الخدمات، فيوم فيه فرجة ساعة بيبان متاح لخدمة ساعتين.
          durationMinutes: item.service.durationMinutes,
        ),
      );

      final failure = result.fold<String?>((l) => l, (_) => null);
      if (failure != null) {
        emit(CreateBookingErrorState(message: failure));
        return;
      }

      item.availableDates = result.getOrElse(() => <DateTime>[]);
      _datesCache[cacheKey] = item.availableDates;
    }

    // الشهر ده فاضي؟ منسيبش العميل يكتشف الفراغ بنفسه — ننط لأقرب
    // شهر فيه مواعيد.
    if (item.availableDates.isEmpty) {
      final firstAvailable = MockSlots.firstAvailableDate(
        durationMinutes: item.service.durationMinutes,
      );
      if (firstAvailable != null &&
          (firstAvailable.month != item.currentMonth.month ||
              firstAvailable.year != item.currentMonth.year)) {
        item.currentMonth = DateTime(firstAvailable.year, firstAvailable.month);
        await loadDatesFor(key);
        return;
      }
      emit(OnSelectionChangedState());
      return;
    }

    // أول يوم فاضي بيتحدد لوحده ومواعيده بتتحمّل — الكارت بيتفتح وهو
    // مفيد من أول ثانية بدل ما العميل يدوّر.
    item.selectedDate ??= item.availableDates.first;
    await loadSlotsFor(key);
  }

  Future<void> loadSlotsFor(String key) async {
    final item = itemByKey(key);
    if (item == null || item.selectedDate == null) return;

    emit(LoadingSlotsState(itemKey: key));

    // TODO(api): GET /api/public/bookings/available-slots?date=
    final result = await MockSource.fetchList(
      MockSlots.slotsFor(
        date: item.selectedDate!,
        durationMinutes: item.service.durationMinutes,
        basePrice: item.baselinePrice,
        // «أي أخصائي متاح» = السعر بيتغير حسب مين الفاضي في الميعاد ده.
        anyAvailable: item.employee.isAnyAvailable,
      ),
    );

    result.fold((failure) => emit(CreateBookingErrorState(message: failure)), (
      data,
    ) {
      item.slots = data;
      emit(OnSelectionChangedState());
    });
  }

  String _cacheKey(BookingDraftItem item, DateTime month) {
    final employeeKey = item.employee.isAnyAvailable
        ? 'any'
        : item.employee.uuid;
    return '${selectedBranch?.uuid}|${item.service.uuid}|$employeeKey'
        '|${month.year}-${month.month}';
  }

  // ── الإجماليات ───────────────────────────────────────────────────────

  double get totalPrice => items.fold<double>(0, (sum, i) => sum + i.price);

  int get totalDuration =>
      items.fold<int>(0, (sum, i) => sum + i.durationMinutes);

  int get scheduledCount => items.where((i) => i.isScheduled).length;

  // ── الزيارات ─────────────────────────────────────────────────────────

  /// الفارق اللي بعده بنعتبر الخدمتين **رحلتين منفصلتين** للمحل.
  ///
  /// مفيش قاعدة للفصل ده في السيرفر — بياخد `visits[]` زي ما بتتبعت
  /// وبيحسب `scheduled_start_at/end_at` بس `min/max` لعناصر الزيارة.
  /// يعني الـ client هو صاحب القرار، ولو غلط مفيش حد هيصلّحه.
  ///
  /// وده مش شكل: `checkInVisit` في السيرفر بيسجّل `arrived_at` **واحد
  /// للزيارة كلها**. لو صبغة ١٠ص وحمام كريم ٨م اتجمعوا في زيارة واحدة،
  /// الفرع بيعمل check-in الساعة ١٠ والعميل يفضل «واصل» عشر ساعات.
  ///
  /// ساعتين: الانتظار الطبيعي جوه المحل (فراغ بين خدمتين، تأخير) نادرًا
  /// بيعديها. **والخطأ في اتجاه الفصل أرحم من الدمج** — فصل غلط بيعمل
  /// check-in زيادة، ودمج غلط بيكسر تتبع اليوم كله.
  static const Duration visitSplitGap = Duration(hours: 2);

  /// الحد الأدنى للفارق اللي يستاهل نعرض عليه زرار دمج/فصل.
  ///
  /// أقل من كده الإجابة واضحة (نفس الرحلة) وعرض الزرار بيبقى ضوضاء على
  /// كل حد بين خدمتين.
  static const Duration boundaryControlMinGap = Duration(minutes: 30);

  /// تعديلات العميل على الحدود — المفتاح هو العنصر اللي **بعد** الحد.
  ///
  /// `true` = افصل، `false` = ادمج. مفيش مدخل = سيبها للفارق.
  final Map<String, bool> _boundaryOverrides = <String, bool>{};

  List<BookingDraftItem> get _scheduledOrdered {
    final scheduled = items.where((i) => i.isScheduled).toList();
    scheduled.sort(
      (a, b) => a.selectedSlot!.startAt.compareTo(b.selectedSlot!.startAt),
    );
    return scheduled;
  }

  /// الخدمات المتحددة مجمّعة في زيارات ومرتبة زمنيًا.
  ///
  /// نفس التجميع اللي بيتبعت للسيرفر، فالتأكيد بيعرض بالظبط اللي هيتحجز.
  List<List<BookingDraftItem>> get visits {
    final ordered = _scheduledOrdered;
    final groups = <List<BookingDraftItem>>[];

    for (final item in ordered) {
      if (groups.isEmpty || startsNewVisit(groups.last.last, item)) {
        groups.add(<BookingDraftItem>[item]);
      } else {
        groups.last.add(item);
      }
    }

    return groups;
  }

  /// الفارق بين نهاية خدمة وبداية اللي بعدها.
  Duration gapBetween(BookingDraftItem previous, BookingDraftItem current) =>
      current.selectedSlot!.startAt.difference(previous.selectedSlot!.endAt);

  /// هل [current] بيبدأ زيارة جديدة بعد [previous]؟
  bool startsNewVisit(BookingDraftItem previous, BookingDraftItem current) {
    // يوم مختلف = زيارة مختلفة **دايمًا**، والتعديل اليدوي مابيلغيش ده.
    // مفيش رحلة واحدة بتمتد على يومين.
    if (previous.day != current.day) return true;

    final override = _boundaryOverrides[current.key];
    if (override != null) return override;

    return gapBetween(previous, current) > visitSplitGap;
  }

  /// وصف الحد اللي قبل [item] — أو `null` لو مفيش حد يتعرض عليه زرار.
  VisitBoundary? boundaryBefore(BookingDraftItem item) {
    final ordered = _scheduledOrdered;
    final index = ordered.indexWhere((i) => i.key == item.key);
    if (index <= 0) return null;

    final previous = ordered[index - 1];
    // الفصل بين يومين حقيقة مش رأي — مفيش زرار.
    if (previous.day != item.day) return null;

    final gap = gapBetween(previous, item);
    final isBreak = startsNewVisit(previous, item);

    if (gap < boundaryControlMinGap && !isBreak) return null;

    return VisitBoundary(itemKey: item.key, gap: gap, isBreak: isBreak);
  }

  /// دمج زيارتين في نفس اليوم، أو فصل واحدة لاتنين.
  void toggleBoundary(String itemKey) {
    final ordered = _scheduledOrdered;
    final index = ordered.indexWhere((i) => i.key == itemKey);
    if (index <= 0) return;

    final previous = ordered[index - 1];
    final current = ordered[index];
    if (previous.day != current.day) return;

    _boundaryOverrides[itemKey] = !startsNewVisit(previous, current);
    emit(OnSelectionChangedState());
  }

  // ── التأكيد ──────────────────────────────────────────────────────────

  /// الـ payload بتاع `POST /api/user/bookings`.
  ///
  /// مطابق لـ `StoreBookingRequest` في السيرفر:
  /// `visits.*.items.*.{service_uuid, employee_uuid?, start_at}`.
  ///
  /// ملحوظتين مهمتين:
  ///  • `employee_uuid` **بيتشال خالص** لما العميل سايب «أي أخصائي متاح»
  ///    — مش بيتبعت فاضي. السيرفر بيوزّع لوحده لما الحقل مش موجود.
  ///  • `scheduled_start_at` للزيارة **مش بنبعتها**. السيرفر بيحسبها
  ///    `min` لعناصر الزيارة، ولو بعتناها ولو بفرق ثانية بيرفض.
  Map<String, dynamic> buildPayload() {
    final notes = notesController.text.trim();

    return <String, dynamic>{
      'branch_uuid': selectedBranch?.uuid,
      if (notes.isNotEmpty) 'notes': notes,
      'visits': visits
          .map(
            (visit) => <String, dynamic>{
              'items': visit
                  .map(
                    (item) => <String, dynamic>{
                      'service_uuid': item.service.uuid,
                      if (!item.employee.isAnyAvailable)
                        'employee_uuid': item.employee.uuid,
                      'start_at': item.selectedSlot!.startAtPayload,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  /// دخول قائمة انتظار الفرع لخدمة معيّنة.
  ///
  /// **رد السيرفر على يوم مليان كان طريق مسدود.** `POST /user/waitlist`
  /// مبني وشغال (`routes/api.php:642-645`) بحجز مؤقت ٥ دقايق، والأبلكيشن
  /// مكانش فيه ولا سطر عنه — فاليوم المليان كان بيقول «جرّب يوم تاني»
  /// وخلاص، مع إن الطلب نفسه يستاهل يتسجّل.
  void joinWaitlist(String key) {
    final item = itemByKey(key);
    if (item == null) return;

    // الميعاد اللي راح لو موجود، وإلا اليوم اللي هو واقف عليه.
    final preferredAt =
        item.takenSlot?.startAt ?? item.selectedDate ?? DateTime.now();

    // TODO(api): POST /api/user/waitlist — النداء اللي تحت **هو** جسم الطلب
    //   حقل بحقل، فيوم الربط بيتغيّر سطر النداء بس.
    MockWaitlist.add(
      providerUuid: providerUuid,
      branchUuid: selectedBranch?.uuid ?? '',
      serviceUuid: item.service.uuid,
      preferredAt: preferredAt,
      // نفس قاعدة الحجز: «أي أخصائي متاح» بيتبعت **فاضي**، مش باسم.
      employeeUuid: item.employee.isAnyAvailable ? null : item.employee.uuid,
    );

    emit(JoinedWaitlistState(serviceName: item.service.name));
  }

  /// السيناريو بيوقّع **أول محاولة بس**.
  bool _scenarioSlotLostFired = false;

  /// الميعاد ده اتاخد من حد تاني؟ — **mock**.
  ///
  /// القاعدة الافتراضية (دقيقة `:15`) عشوائية شوية: بتعتمد على إن العميل
  /// يصادف يختار ميعاد بالدقيقة دي. سيناريو `slotLostAtConfirm` بيخلي
  /// **أول خدمة** تقع — عشان الحالة تبقى قابلة للعرض في تانيتين بدل ما
  /// نفضل نجرّب مواعيد لحد ما واحد يقع.
  ///
  /// **بس مرة واحدة.** من غير [_scenarioSlotLostFired] كان الحجز يقع كل
  /// مرة: العميل يختار بديل، يدوس تأكيد، ويقع تاني — حلقة مقفولة مالهاش
  /// مخرج. والسيناريو المفروض يوري **التعافي**، والتعافي معناه إنك تقدر
  /// تكمّل في الآخر.
  bool _isSlotTaken(BookingDraftItem item) {
    if (MockConfig.scenario == MockScenario.slotLostAtConfirm) {
      if (_scenarioSlotLostFired) return false;
      return items.isNotEmpty && item.key == items.first.key;
    }
    return item.selectedSlot?.startAt.minute == 15;
  }

  Future<void> confirmBooking() async {
    emit(CreateBookingLoadingState());

    // TODO(api): POST /api/user/bookings — الـ body من `buildPayload()`.
    await Future.delayed(const Duration(milliseconds: 800));

    // مؤقتًا للتجربة: أي ميعاد الدقيقة فيه ١٥ بنعتبره اتحجز من حد تاني،
    // عشان نقدر نجرّب حالة «الميعاد راح» من غير جهازين.
    //
    // **بنجمّعهم كلهم قبل ما نرد.** الكود القديم كان بيعمل `return` من جوه
    // اللوب عند أول خدمة وقعت، فحجز بتلات خدمات واتنين مواعيدهم راحوا كان
    // بيوري واحدة بس — والعميل يصلّحها، يدوس تأكيد، ويتصدم تاني.
    final taken = items.where(_isSlotTaken).toList();

    if (taken.isNotEmpty) {
      _scenarioSlotLostFired = true;

      for (final item in taken) {
        item.takenSlot = item.selectedSlot;
        item.selectedSlot = null;
      }

      currentStep = BookingStep.dateTime;

      // بنفتح أول واحد بس — كارت واحد مفتوح في المرة هي قاعدة الأكورديون،
      // والباقي بيفضل مشخوط ومستني دوره.
      final first = taken.first;
      for (final other in items) {
        other.isExpanded = other.key == first.key;
      }

      await loadSlotsFor(first.key);
      emit(
        SlotTakenState(
          itemKey: first.key,
          serviceNames: taken.map((i) => i.service.name).toList(),
        ),
      );
      return;
    }

    emit(CreateBookingSuccessState());
  }

  /// فيه خدمة النهاردة؟ — **فلتر أهمية للتنبيه، مش قاعدة الإلغاء**.
  ///
  /// ⚠ القاعدة الحقيقية في `Booking::getCanCancelAttribute()` إن الإلغاء
  /// بيتقفل لما الميعاد **يبدأ**، مش عشان هو في نفس اليوم. الاسم هنا كان
  /// بيتقرا كأنه القاعدة نفسها، والنص اللي فوقه كان بيقول كده بالحرف.
  ///
  /// اللي بيفضل صح إن ميعاد النهاردة هو الوحيد اللي نافذة إلغائه ممكن
  /// تقفل قبل ما العميل يفتح الأبلكيشن تاني — فالتنبيه يلزم هنا وبس.
  ///
  /// **أي** خدمة النهاردة بتكفي: العميل بيرتبط بالحجز كله، ولو أول
  /// زيارة النهاردة يبقى مربوط دلوقتي.
  bool get isSameDayBooking {
    final now = DateTime.now();
    return items.any((item) {
      final slot = item.selectedSlot;
      if (slot == null) return false;
      return slot.startAt.year == now.year &&
          slot.startAt.month == now.month &&
          slot.startAt.day == now.day;
    });
  }

  @override
  Future<void> close() {
    notesController.dispose();
    return super.close();
  }

  static CreateBookingCubit get(context) => BlocProvider.of(context);
}
