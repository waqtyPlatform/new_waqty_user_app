import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';

import '../models/provider_booking_items_model.dart';
import '../services/provider_booking_items_service.dart';

class ProviderBookingItemsRepo {
  final ProviderBookingItemsService _service;

  const ProviderBookingItemsRepo(this._service);

  Future<Either<Failure, ProviderBookingCatalogueModel>> catalogue({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
  }) => _guard(
    () => _service.catalogue(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      type: type,
    ),
  );

  Future<Either<Failure, ProviderBookingEntitlementsModel>> entitlements({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
    String status = 'active',
  }) => _guard(
    () => _service.entitlements(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      type: type,
      status: status,
    ),
  );

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
