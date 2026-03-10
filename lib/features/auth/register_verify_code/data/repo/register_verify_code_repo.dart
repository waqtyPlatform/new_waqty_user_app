import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/services/register_verify_code_service.dart';

class RegisterVerifyCodeRepo {
  final RegisterVerifyCodeService _registerVerifyCodeService;

  RegisterVerifyCodeRepo(this._registerVerifyCodeService);

  /// Send/Resend verification OTP to user's email
  Future<Either<Failure, ResendVerificationResponseModel>>
  resendVerificationCode(ResendVerificationRequestModel parameter) async {
    try {
      return Right(
        await _registerVerifyCodeService.resendVerificationCode(parameter),
      );
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }

  /// Verify the OTP code entered by the user
  Future<Either<Failure, RegisterVerifyCodeResponseModel>> verifyCode(
    RegisterVerifyCodeRequestModel parameter,
  ) async {
    try {
      return Right(await _registerVerifyCodeService.verifyCode(parameter));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
