import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import '../models/provider_details_model.dart';
import '../models/provider_booking_model.dart';
import '../services/provider_details_service.dart';

class ProviderDetailsNotFoundFailure extends Failure {
  const ProviderDetailsNotFoundFailure() : super(message: 'not_found');
}

class ProviderDetailsRepo {
  final ProviderDetailsService _service;
  ProviderDetailsRepo(this._service);
  Future<Either<Failure, ProviderDetailsModel>> show(String uuid) async {
    try {
      return Right(await _service.show(uuid));
    } on ProviderDetailsNotFoundException {
      return const Left(ProviderDetailsNotFoundFailure());
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, List<ProviderServiceModel>>> bookingServices(
    String providerUuid,
    String branchUuid,
  ) => _guard(() => _service.bookingServices(providerUuid, branchUuid));

  Future<Either<Failure, ProviderBookingEmployeesModel>> bookingEmployees(
    String providerUuid,
    String branchUuid,
    String serviceUuid,
  ) => _guard(
    () => _service.bookingEmployees(providerUuid, branchUuid, serviceUuid),
  );

  Future<Either<Failure, List<ProviderBookingDateModel>>> bookingDates({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required String timezone,
  }) => _guard(
    () => _service.bookingDates(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      employeeUuid: employeeUuid,
      timezone: timezone,
    ),
  );

  Future<Either<Failure, ProviderBookingSlotsModel>> bookingSlots({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required DateTime date,
    required String timezone,
  }) => _guard(
    () => _service.bookingSlots(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      employeeUuid: employeeUuid,
      date: date,
      timezone: timezone,
    ),
  );

  Future<Either<Failure, List<ProviderBookingDateModel>>> packageDates({
    required String providerUuid,
    required String branchUuid,
    required String packageUuid,
    required String timezone,
  }) => _guard(
    () => _service.packageDates(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      packageUuid: packageUuid,
      timezone: timezone,
    ),
  );

  Future<Either<Failure, ProviderBookingSlotsModel>> packageSlots({
    required String providerUuid,
    required String branchUuid,
    required String packageUuid,
    required DateTime date,
    required String timezone,
  }) => _guard(
    () => _service.packageSlots(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      packageUuid: packageUuid,
      date: date,
      timezone: timezone,
    ),
  );

  Future<Either<Failure, void>> createBooking(Map<String, dynamic> body) =>
      _guard(() => _service.createBooking(body));

  Future<Either<Failure, void>> joinWaitlist(Map<String, dynamic> body) =>
      _guard(() => _service.joinWaitlist(body));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }
}
