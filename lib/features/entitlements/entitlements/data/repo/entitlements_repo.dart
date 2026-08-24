import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_service.dart';

class EntitlementsRepo extends BaseRepo<EntitlementsService> {
  const EntitlementsRepo(super.remote, super.mock);

  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages() =>
      guard(() => source.packages());

  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps() =>
      guard(() => source.followUps());

  Future<Either<Failure, BookingUiModel>> bookPackageSession({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? serviceUuid,
    String? notes,
  }) => guard(
    () => source.bookPackageSession(
      uuid: uuid,
      bookingDate: bookingDate,
      startTime: startTime,
      serviceUuid: serviceUuid,
      notes: notes,
    ),
  );

  Future<Either<Failure, BookingUiModel>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  }) => guard(
    () => source.bookFollowUp(
      uuid: uuid,
      bookingDate: bookingDate,
      startTime: startTime,
      employeeUuid: employeeUuid,
      notes: notes,
    ),
  );
}
