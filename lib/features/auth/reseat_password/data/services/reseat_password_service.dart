import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_api_end_points.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_request_model.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_response_model.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_api_end_points.dart';

class ReseatPasswordService {
  ApiConsumer apiConsumer;

  ReseatPasswordService({required this.apiConsumer});

  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel parameter,
  ) async {
    final response = await apiConsumer.post(
      ReseatPasswordApiEndPoints.resetPassword,
      ResetPasswordRequestModel(
        email: parameter.email,
        otp: parameter.otp,
        newPassword: parameter.newPassword,
        newPasswordConfirmation: parameter.newPasswordConfirmation,
      ).toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );

    if (response.statusCode == StatusCode.ok) {
      return ResetPasswordResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
