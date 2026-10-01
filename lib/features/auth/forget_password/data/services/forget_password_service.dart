import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
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
      parameter.toJson(),
      {
        ConstantKeys.appAuthorization:
            "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
      },
    );
    if (response.statusCode == StatusCode.ok) {
      return ForgetPasswordResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }
}
