import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_request_model.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_response_model.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_api_end_points.dart';

class RegisterService {
  ApiConsumer apiConsumer;

  RegisterService({required this.apiConsumer});

  Future<RegisterResponseModel> register(
    RegisterRequestModel registerRequestModel,
  ) async {
    final response = await apiConsumer.post(
      RegisterApiEndPoints.registerUrl,
      registerRequestModel.toJson(),
      // الهيدرز (Authorization + Content-Type + Accept-Language) كلها بقت
      // في `AppInterceptor` — كانت متكررة هنا وفي ٦ services تانية،
      // وبتتبعت حتى على الراوتس المفتوحة.
      null,
    );
    if (response.statusCode == StatusCode.ok ||
        response.statusCode == StatusCode.created) {
      return RegisterResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
