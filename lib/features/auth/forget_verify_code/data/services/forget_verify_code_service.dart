import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
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
      {
        ConstantKeys.appAuthorization:
            "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
      },
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
