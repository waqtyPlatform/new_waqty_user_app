import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_request_model.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_response_model.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';

class RegisterRepo {
  final RegisterService _registerService;

  RegisterRepo(this._registerService);

  Future<Either<Failure, RegisterResponseModel>> register(
    RegisterRequestModel registerRequestModel,
  ) async {
    try {
      return Right(await _registerService.register(registerRequestModel));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
