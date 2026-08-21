import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_request_model.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/login/data/services/login_api_end_points.dart';

class LoginService {
  ApiConsumer apiConsumer;

  LoginService({required this.apiConsumer});

  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    final response = await apiConsumer.post(
      LoginApiEndPoints.loginUrl,
      requestModel.toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == StatusCode.ok ||
        response.statusCode == StatusCode.notVerified) {
      return LoginResponseModel.fromJson(
        jsonDecode(response.body),
        code: response.statusCode,
      );
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
