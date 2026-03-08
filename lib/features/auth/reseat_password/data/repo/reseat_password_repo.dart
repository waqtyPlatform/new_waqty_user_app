import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_request_model.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_response_model.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_service.dart';

class ReseatPasswordRepo {
  final ReseatPasswordService _reseatPasswordService;

  ReseatPasswordRepo(this._reseatPasswordService);

  Future<Either<Failure, ResetPasswordResponseModel>> resetPassword(
    ResetPasswordRequestModel parameter,
  ) async {
    try {
      return Right(await _reseatPasswordService.resetPassword(parameter));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
