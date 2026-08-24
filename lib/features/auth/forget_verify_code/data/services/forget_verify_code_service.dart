import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_api_end_points.dart';

class ForgetVerifyCodeService {
  ApiConsumer apiConsumer;

  ForgetVerifyCodeService({required this.apiConsumer});
  Future<VerifyCodeResponseModel> verifyCode(
    VerifyCodeRequestModel parameter,
  ) async {
    final response = await apiConsumer.post(
      ForgetVerifyCodeApiEndPoints.verifyCode,
      VerifyCodeRequestModel(
        email: parameter.email,
        otp: parameter.otp,
      ).toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );

    if (response.statusCode == StatusCode.ok) {
      return VerifyCodeResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
