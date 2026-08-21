import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/repo/create_booking_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_state.dart';

/// حجز متابعة — **التاريخ والميعاد بس**، الباقي محسوم من الاستحقاق.
///
/// ## الخطوة الأولى اللي مش مفروض تكون موجودة
///
/// عشان نجيب مواعيد، محتاجين `branch_uuid` و`service_uuid`. صف المتابعة
/// مافيهوش ولا واحد فيهم — فيه `original_booking_uuid` بس. فبنعمل نداء
/// **زيادة** على `GET /user/bookings/{uuid}`، واللي بيرجّع `branch`
/// و`service` من الـsnapshots (`BookingCreationService:54-78` بيأكّد إن
/// الاتنين فيهم `uuid`).
///
/// ⚠ النداء ده **دين مؤقت** وموصوف كده بالقصد. أول ما BE-A1 ينزّل `branch`
/// في صف المتابعة نفسه، الخطوة دي تتشال ويبقى الفتح أسرع بنداء كامل.
/// TODO(api): BE-A1.
class EntitlementBookingCubit extends Cubit<EntitlementBookingState> {
  EntitlementBookingCubit({
    required FollowUpEntitlementUiModel followUp,
    required BookingDetailsRepo bookings,
    required CreateBookingRepo booking,
  }) : _followUp = followUp,
       _bookings = bookings,
       _booking = booking,
       super(const EntitlementBookingResolving());

  final FollowUpEntitlementUiModel _followUp;
  final BookingDetailsRepo _bookings;
  final CreateBookingRepo _booking;

  String branchUuid = '';
  String serviceUuid = '';

  List<DateTime> availableDates = <DateTime>[];
  List<SlotUiModel> slots = <SlotUiModel>[];

  DateTime? selectedDate;
  SlotUiModel? selectedSlot;
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool get canConfirm => selectedDate != null && selectedSlot != null;

  /// الأخصائي اللي هيتبعت. `null` = سيب السيرفر يختار.
  ///
  /// لما القاعدة `same_employee_required` بنبعت الأخصائي صراحة — السيرفر
  /// بيتحقق منها برضه، بس بعتها بيخلّي النية واضحة في الطلب.
  String? get employeeUuid =>
      _followUp.employeeRule == FollowUpEmployeeRule.sameRequired
      ? _followUp.employee?.uuid
      : null;

  /// بيحلّ الفرع والخدمة من الحجز الأصلي، وبعدين بيجيب تواريخ الشهر.
  Future<void> start() async {
    emit(const EntitlementBookingResolving());

    final result = await _bookings.booking(_followUp.originalBookingUuid);
    if (isClosed) return;

    var failed = '';
    result.fold((failure) => failed = failure.message, (booking) {
      branchUuid = booking.branchUuid;
      serviceUuid = booking.items.isEmpty ? '' : booking.items.first.serviceUuid;
    });

    if (failed.isNotEmpty || branchUuid.isEmpty || serviceUuid.isEmpty) {
      emit(
        EntitlementBookingError(
          failed.isNotEmpty
              ? failed
              : 'مش قادرين نجيب بيانات الفرع — كلّم الفرع للحجز',
        ),
      );
      return;
    }

    await loadDates();
  }

  Future<void> loadDates() async {
    emit(const EntitlementBookingLoadingDates());

    final result = await _booking.availableDates(
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      month: currentMonth,
      employeeUuid: employeeUuid,
    );
    if (isClosed) return;

    result.fold((failure) => emit(EntitlementBookingError(failure.message)), (
      dates,
    ) {
      availableDates = dates;
      emit(const EntitlementBookingReady());
    });
  }

  void changeMonth(int delta) {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + delta);
    selectedDate = null;
    selectedSlot = null;
    slots = <SlotUiModel>[];
    loadDates();
  }

  Future<void> selectDate(DateTime date) async {
    selectedDate = date;
    selectedSlot = null;
    slots = <SlotUiModel>[];
    emit(const EntitlementBookingLoadingSlots());

    final result = await _booking.availableSlots(
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      date: date,
      employeeUuid: employeeUuid,
    );
    if (isClosed) return;

    result.fold((failure) => emit(EntitlementBookingError(failure.message)), (
      data,
    ) {
      slots = data;
      emit(const EntitlementBookingReady());
    });
  }

  void selectSlot(SlotUiModel slot) {
    selectedSlot = slot;
    emit(const EntitlementBookingReady());
  }

  /// التاريخ والوقت بالشكل اللي السيرفر بيطلبه — `Y-m-d` و`H:i`.
  String get bookingDate => AppFormat.serverDate(selectedDate!);

  /// **`HH:mm` خام — مش [AppFormat.time].**
  ///
  /// `bookFollowUp` بيتحقق بـ`date_format:H:i`، و`AppFormat.time` بيرجّع
  /// «٤:٣٠ م» للعرض. الاتنين مالهمش علاقة: واحد للعميلة وواحد للسيرفر.
  ///
  /// محلي مقصود ومش في الكيت — مستهلك واحد، وإضافته لـ`AppFormat` بتلزّمنا
  /// نزامن `design-kit/` من غير مقابل.
  String get startTime {
    final start = selectedSlot!.startAt;
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static EntitlementBookingCubit get(context) => BlocProvider.of(context);
}
