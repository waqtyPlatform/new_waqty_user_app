import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

class AppInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    request.headers[ConstantKeys.contentType] = ConstantKeys.applicationJson;
    request.headers[ConstantKeys.acceptText] = ConstantKeys.applicationJson;
    // request.headers[ConstantKeys.acceptLanguage] =
    //     getIt<AppConstant>().getLanguage();
    debugPrint(request.toString());
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    debugPrint(response.toString());
    return response;
  }
}
