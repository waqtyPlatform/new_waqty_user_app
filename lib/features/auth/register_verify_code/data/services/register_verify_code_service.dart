import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/services/register_verify_code_api_end_points.dart';

class RegisterVerifyCodeService {
  ApiConsumer apiConsumer;

  RegisterVerifyCodeService({required this.apiConsumer});

  /// Send/Resend verification OTP to user's email
  Future<ResendVerificationResponseModel> resendVerificationCode(
    ResendVerificationRequestModel parameter,
  ) async {
    final response = await apiConsumer.post(
      RegisterVerifyCodeApiEndPoints.resendVerificationUrl,
      parameter.toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );

    if (response.statusCode == StatusCode.ok) {
      return ResendVerificationResponseModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }

  /// Verify the OTP code entered by the user
  Future<RegisterVerifyCodeResponseModel> verifyCode(
    RegisterVerifyCodeRequestModel parameter,
  ) async {
    final response = await apiConsumer.post(
      RegisterVerifyCodeApiEndPoints.verifyCode,
      RegisterVerifyCodeRequestModel(
        email: parameter.email,
        otp: parameter.otp,
      ).toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );

    if (response.statusCode == StatusCode.ok) {
      return RegisterVerifyCodeResponseModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
