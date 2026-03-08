import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_response_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';

class ForgetPasswordRepo {
  final ForgetPasswordService _forgetPasswordService;

  ForgetPasswordRepo(this._forgetPasswordService);
  Future<Either<Failure, ForgetPasswordResponseModel>> forgetPassword(
    ForgetPasswordRequestModel parameter,
  ) async {
    try {
      return Right(await _forgetPasswordService.forgetPassword(parameter));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
