import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_service.dart';

/// ⚠ **الكاش هنا حماية من `throttle:60,1` مش تحسين سرعة.**
///
/// `public/bookings/*` عليها ستين طلب في الدقيقة لكل IP. وويزارد الحجز
/// بطبيعته بيطلب كتير: العميل بيلعب في شريط التواريخ، بيغيّر الأخصائي،
/// بيرجع لخدمة قبلها. من غير كاش، عميل بيقلّب في التقويم بيحرق الميزانية
/// **في ثواني** وياخد ٤٢٩ نص الويزارد — وساعتها مايقدرش يكمّل حجز.
///
/// الكاش عايش على الـrepo (يعني على عمر الـcubit) مش singleton: المواعيد
/// بتبوظ بسرعة، وكاش بيعيش أكتر من الجلسة بيوري العميل ميعاد اتحجز خلاص.
class CreateBookingRepo extends BaseRepo<CreateBookingService> {
  CreateBookingRepo(super.remote, super.mock);

  final Map<String, List<DateTime>> _datesCache = <String, List<DateTime>>{};
  final Map<String, List<SlotUiModel>> _slotsCache =
      <String, List<SlotUiModel>>{};
  final Map<String, List<EmployeeUiModel>> _employeesCache =
      <String, List<EmployeeUiModel>>{};

  Future<Either<Failure, List<BranchUiModel>>> branches(String providerUuid) =>
      guard(() => source.branches(providerUuid));

  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  }) => guard(
    () => source.services(providerUuid: providerUuid, branchUuid: branchUuid),
  );

  Future<Either<Failure, List<EmployeeUiModel>>> availableEmployees({
    required String branchUuid,
    required String serviceUuid,
  }) {
    final key = '$branchUuid|$serviceUuid';
    final cached = _employeesCache[key];
    if (cached != null) return Future.value(Right(cached));

    return guard(
      () => source
          .availableEmployees(branchUuid: branchUuid, serviceUuid: serviceUuid)
          .then((result) {
            result.forEach((data) => _employeesCache[key] = data);
            return result;
          }),
    );
  }

  Future<Either<Failure, List<DateTime>>> availableDates({
    required String branchUuid,
    required String serviceUuid,
    required DateTime month,
    String? employeeUuid,
  }) {
    final key = '$branchUuid|$serviceUuid|$employeeUuid|'
        '${month.year}-${month.month}';
    final cached = _datesCache[key];
    if (cached != null) return Future.value(Right(cached));

    return guard(
      () => source
          .availableDates(
            branchUuid: branchUuid,
            serviceUuid: serviceUuid,
            month: month,
            employeeUuid: employeeUuid,
          )
          .then((result) {
            result.forEach((data) => _datesCache[key] = data);
            return result;
          }),
    );
  }

  Future<Either<Failure, List<SlotUiModel>>> availableSlots({
    required String branchUuid,
    required String serviceUuid,
    required DateTime date,
    String? employeeUuid,
  }) {
    final key = '$branchUuid|$serviceUuid|$employeeUuid|'
        '${AppFormat.serverDate(date)}';
    final cached = _slotsCache[key];
    if (cached != null) return Future.value(Right(cached));

    return guard(
      () => source
          .availableSlots(
            branchUuid: branchUuid,
            serviceUuid: serviceUuid,
            date: date,
            employeeUuid: employeeUuid,
          )
          .then((result) {
            result.forEach((data) => _slotsCache[key] = data);
            return result;
          }),
    );
  }

  /// **بيفضّي كاش المواعيد بعد أي كتابة.**
  ///
  /// حجز نجح = ميعاد اتشال من المتاح. لو الكاش فضل، العميل يرجع يحجز
  /// خدمة تانية في نفس اليوم وبيشوف الميعاد اللي هو نفسه حجزه لسه فاضي.
  void invalidateSlots() {
    _slotsCache.clear();
    _datesCache.clear();
  }

  Future<Either<Failure, String>> createBooking(Map<String, dynamic> payload) =>
      guard(
        () => source.createBooking(payload).then((result) {
          result.forEach((_) => invalidateSlots());
          return result;
        }),
      );

  Future<Either<Failure, Unit>> joinWaitlist({
    required String branchUuid,
    required String serviceUuid,
    required DateTime preferredAt,
    String? employeeUuid,
    String notes = '',
  }) => guard(
    () => source.joinWaitlist(
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      preferredAt: preferredAt,
      employeeUuid: employeeUuid,
      notes: notes,
    ),
  );
}
