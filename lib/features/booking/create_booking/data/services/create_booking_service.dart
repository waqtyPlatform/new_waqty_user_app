import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';

/// عقد داتا ويزارد الحجز.
///
/// ⚠ **`public/bookings/*` عليها `throttle:60,1`.** ستين طلب في الدقيقة
/// لكل IP، وشريط تواريخ بينده لكل يوم بيحرقها في ثواني. الكاش والـdebounce
/// **قيد تصميم مش تحسين** — شوف `CreateBookingRepo`.
abstract class CreateBookingService {
  /// فروع المقدّم — الويزارد بيحمّلهم بنفسه.
  ///
  /// ⚠ ممكن تبان تكرار مع `ServiceProviderDetailsService`، بس الويزارد
  /// بيتفتح من **أربع أماكن** (صفحة المحل وتلت مسارات «احجز
  /// تاني»)، وتلاتة منهم معندهمش غير الـuuid. ربط الويزارد بـrepo
  /// تانية عشان نوفّر نداء بيخلّي الفيتشر تعتمد على فيتشر تانية
  /// عشان تقلع. والـrepo بيكشّ الرد أصلاً.
  Future<Either<Failure, List<BranchUiModel>>> branches(String providerUuid);

  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  });

  Future<Either<Failure, List<EmployeeUiModel>>> availableEmployees({
    required String branchUuid,
    required String serviceUuid,
  });

  /// أيام الشهر اللي فيها ميعاد فاضي — `DateTime` لكل يوم متاح.
  Future<Either<Failure, List<DateTime>>> availableDates({
    required String branchUuid,
    required String serviceUuid,
    required DateTime month,
    String? employeeUuid,
  });

  Future<Either<Failure, List<SlotUiModel>>> availableSlots({
    required String branchUuid,
    required String serviceUuid,
    required DateTime date,
    String? employeeUuid,
  });

  /// بترجّع `uuid` الحجز الجديد.
  Future<Either<Failure, String>> createBooking(Map<String, dynamic> payload);

  /// ⚠ **`preferred_date` و`preferred_time` حقلين منفصلين مطلوبين** —
  /// `Y-m-d` و`H:i`. الموك كان بيبعت `DateTime` واحد.
  Future<Either<Failure, Unit>> joinWaitlist({
    required String branchUuid,
    required String serviceUuid,
    required DateTime preferredAt,
    String? employeeUuid,
    String notes = '',
  });
}
