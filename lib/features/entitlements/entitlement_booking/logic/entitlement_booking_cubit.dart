import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/entitlement_owner_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/repo/create_booking_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_state.dart';

/// اللي بيتحجز — باقة ولا متابعة.
///
/// النوعين بياخدوا نفس الشاشة (تاريخ + ميعاد) بس بيروحوا لـendpoint
/// مختلف، والبركة بتسيب العميلة تختار الخدمة.
enum EntitlementBookingKind { package, followUp }

/// حجز جلسة من استحقاق — **التاريخ والميعاد بس**، الباقي محسوم.
///
/// ## اللي اتغيّر مع BE-A1
///
/// الشاشة كانت بتبدأ بنداء **زيادة** على `GET /user/bookings/{uuid}` عشان
/// تطلّع الفرع والخدمة من snapshots الحجز الأصلي — الحيلة الوحيدة اللي
/// كانت متاحة للمتابعات، ومكانش ليها مقابل في الباقات أصلاً، فحجز الباقة
/// كان مقفول بالكامل.
///
/// دلوقتي `provider` و`branch` و`service_uuid` بييجوا في الصف نفسه، فالشاشة
/// بتفتح على نداء المواعيد على طول — أسرع، وشغّالة للنوعين.
class EntitlementBookingCubit extends Cubit<EntitlementBookingState> {
  EntitlementBookingCubit._({
    required CreateBookingRepo booking,
    required this.kind,
    required this.owner,
    required this.entitlementUuid,
    required String serviceUuid,
    required this.durationMinutes,
    this.lockedEmployeeUuid,
    this.allowedServices = const <AllowedServiceUiModel>[],
  }) : _booking = booking,
       selectedServiceUuid = serviceUuid,
       super(const EntitlementBookingResolving());

  factory EntitlementBookingCubit.forPackage({
    required PackageEntitlementUiModel package,
    required CreateBookingRepo booking,
  }) => EntitlementBookingCubit._(
    booking: booking,
    kind: EntitlementBookingKind.package,
    owner: package.owner,
    entitlementUuid: package.uuid,
    serviceUuid: package.slotServiceUuid,
    durationMinutes: switch (package) {
      SessionPackageEntitlement(:final durationMinutes) => durationMinutes,
      UsagePackageEntitlement(:final allowedServices) =>
        allowedServices.isEmpty ? 0 : allowedServices.first.durationMinutes,
    },
    allowedServices: switch (package) {
      UsagePackageEntitlement(:final allowedServices) => allowedServices,
      SessionPackageEntitlement() => const <AllowedServiceUiModel>[],
    },
  );

  factory EntitlementBookingCubit.forFollowUp({
    required FollowUpEntitlementUiModel followUp,
    required CreateBookingRepo booking,
  }) => EntitlementBookingCubit._(
    booking: booking,
    kind: EntitlementBookingKind.followUp,
    owner: followUp.owner,
    entitlementUuid: followUp.uuid,
    serviceUuid: followUp.serviceUuid,
    durationMinutes: followUp.durationMinutes,
    // القاعدة `same_employee_required` بتتبعت صراحة — السيرفر بيتحقق منها
    // برضه، بس بعتها بتخلّي النية واضحة في الطلب.
    lockedEmployeeUuid:
        followUp.employeeRule == FollowUpEmployeeRule.sameRequired
        ? followUp.employee?.uuid
        : null,
  );

  final CreateBookingRepo _booking;

  final EntitlementBookingKind kind;
  final EntitlementOwnerUiModel owner;
  final String entitlementUuid;
  final int durationMinutes;
  final String? lockedEmployeeUuid;

  /// الخدمات اللي البركة تنفع عليها. فاضية = مفيش اختيار (جلسات/متابعة).
  final List<AllowedServiceUiModel> allowedServices;

  /// الخدمة اللي بنجيب مواعيدها. بتتغيّر للبركة بس.
  String selectedServiceUuid;

  List<DateTime> availableDates = <DateTime>[];
  List<SlotUiModel> slots = <SlotUiModel>[];

  DateTime? selectedDate;
  SlotUiModel? selectedSlot;
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool get canConfirm => selectedDate != null && selectedSlot != null;

  bool get canPickService => allowedServices.length > 1;

  Future<void> start() => loadDates();

  Future<void> loadDates() async {
    emit(const EntitlementBookingLoadingDates());

    final result = await _booking.availableDates(
      branchUuid: owner.branchUuid,
      serviceUuid: selectedServiceUuid,
      month: currentMonth,
      employeeUuid: lockedEmployeeUuid,
    );
    if (isClosed) return;

    result.fold((failure) => emit(EntitlementBookingError(failure.message)), (
      dates,
    ) {
      availableDates = dates;
      _emitReady();
    });
  }

  void changeMonth(int delta) {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + delta);
    _clearSelection();
    loadDates();
  }

  /// تغيير الخدمة في البركة — بيرمي الاختيار، لأن المواعيد بتختلف بالمدة.
  Future<void> selectService(String serviceUuid) async {
    if (serviceUuid == selectedServiceUuid) return;
    selectedServiceUuid = serviceUuid;
    _clearSelection();
    await loadDates();
  }

  Future<void> selectDate(DateTime date) async {
    selectedDate = date;
    selectedSlot = null;
    slots = <SlotUiModel>[];
    emit(const EntitlementBookingLoadingSlots());

    final result = await _booking.availableSlots(
      branchUuid: owner.branchUuid,
      serviceUuid: selectedServiceUuid,
      date: date,
      employeeUuid: lockedEmployeeUuid,
    );
    if (isClosed) return;

    result.fold((failure) => emit(EntitlementBookingError(failure.message)), (
      data,
    ) {
      slots = data;
      _emitReady();
    });
  }

  void selectSlot(SlotUiModel slot) {
    selectedSlot = slot;
    _emitReady();
  }

  void _clearSelection() {
    selectedDate = null;
    selectedSlot = null;
    slots = <SlotUiModel>[];
  }

  /// ⚠ **الحالة بتشيل الاختيار** — من غيره `emit` بعد اختيار ميعاد بيتبلع
  /// لأن الحالة القديمة والجديدة نفس نسخة الـ`const`. شوف
  /// [EntitlementBookingReady].
  void _emitReady() => emit(
    EntitlementBookingReady(
      selectedDate: selectedDate,
      selectedSlotStart: selectedSlot?.startAt,
      serviceUuid: selectedServiceUuid,
    ),
  );

  /// `Y-m-d` زي ما السيرفر بيطلبه.
  String get bookingDate => AppFormat.serverDate(selectedDate!);

  /// **`HH:mm` خام — مش [AppFormat.time].**
  ///
  /// الـendpoint بيتحقق بـ`date_format:H:i`، و`AppFormat.time` بيرجّع
  /// «٤:٣٠ م» للعرض. الاتنين مالهمش علاقة: واحد للعميلة وواحد للسيرفر.
  String get startTime {
    final start = selectedSlot!.startAt;
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static EntitlementBookingCubit get(context) => BlocProvider.of(context);
}
