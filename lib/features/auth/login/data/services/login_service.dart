import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
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
      {
        ConstantKeys.appAuthorization:
            "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
      },
    );

    if (response.statusCode == StatusCode.ok) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
