import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';

class ForgetVerifyCodeRepo {
  final ForgetVerifyCodeService _forgetPasswordService;

  ForgetVerifyCodeRepo(this._forgetPasswordService);

  Future<Either<Failure, VerifyCodeResponseModel>> verifyCode(
    VerifyCodeRequestModel parameter,
  ) async {
    try {
      return Right(await _forgetPasswordService.verifyCode(parameter));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
