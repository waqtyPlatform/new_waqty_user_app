import 'package:easy_localization/easy_localization.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:waqty_user_application/my_app.dart';

class AppInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    request.headers[ConstantKeys.contentType] = ConstantKeys.applicationJson;
    request.headers[ConstantKeys.acceptText] = ConstantKeys.applicationJson;
    final context = navigatorKey.currentContext;
    request.headers[ConstantKeys.acceptLanguage] =
        (context != null && context.locale == const Locale('en', 'US'))
        ? 'en'
        : 'ar';
    final token = await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    );
    if (token.isNotEmpty &&
        !request.headers.containsKey(ConstantKeys.appAuthorization)) {
      request.headers[ConstantKeys.appAuthorization] =
          '${ConstantKeys.appBearer} $token';
    }
    debugPrint(request.toString());
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    debugPrint(response.toString());
    return response;
  }
}
