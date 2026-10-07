import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import '../models/provider_details_model.dart';
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
}
