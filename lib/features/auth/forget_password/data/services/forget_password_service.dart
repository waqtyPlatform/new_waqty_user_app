import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_response_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_api_end_points.dart';

class ForgetPasswordService {
  ApiConsumer apiConsumer;

  ForgetPasswordService({required this.apiConsumer});

  Future<ForgetPasswordResponseModel> forgetPassword(
    ForgetPasswordRequestModel parameter,
  ) async {
    final response = await apiConsumer.post(
      ForgetPasswordApiEndPoints.forgetPassword,
      ForgetPasswordRequestModel(email: parameter.email).toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == StatusCode.ok) {
      return ForgetPasswordResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
