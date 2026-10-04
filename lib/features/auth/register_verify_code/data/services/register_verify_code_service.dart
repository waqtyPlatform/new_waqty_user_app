import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    final verifyUrl = RegisterVerifyCodeApiEndPoints.verifyUrlFromEndpoint(
      parameter.verifyEndpoint,
    );
    final requestBody = RegisterVerifyCodeRequestModel(
      email: parameter.email,
      otp: parameter.otp,
      verifyEndpoint: parameter.verifyEndpoint,
    ).toJson();
    debugPrint('VERIFY_CODE_URL: $verifyUrl');
    debugPrint('VERIFY_CODE_REQUEST_BODY: ${jsonEncode(requestBody)}');
    final response = await apiConsumer.post(verifyUrl, requestBody, null);
    debugPrint('VERIFY_CODE_RESPONSE_STATUS: ${response.statusCode}');
    _debugPrintVerifyResponse(response.body);

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

  void _debugPrintVerifyResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        debugPrint('VERIFY_CODE_RESPONSE_MESSAGE: ${decoded['message']}');
        debugPrint('VERIFY_CODE_RESPONSE_ERRORS: ${decoded['errors']}');
        debugPrint(
          'VERIFY_CODE_RESPONSE_DATA: ${jsonEncode(_redactToken(decoded['data']))}',
        );
        return;
      }
    } catch (_) {}
    debugPrint('VERIFY_CODE_RESPONSE_BODY: $body');
  }

  dynamic _redactToken(dynamic data) {
    if (data is! Map<String, dynamic>) return data;
    final redacted = Map<String, dynamic>.from(data);
    if (redacted.containsKey('token')) redacted['token'] = '[redacted]';
    return redacted;
  }
}
