import 'package:easy_localization/easy_localization.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

    final token = _normalizeToken(
      await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared),
    );
    if (token.isNotEmpty &&
        !request.headers.containsKey(ConstantKeys.appAuthorization)) {
      request.headers[ConstantKeys.appAuthorization] =
          '${ConstantKeys.appBearer} $token';
    }
    debugPrint(request.toString());
    return request;
  }

  String _normalizeToken(String token) {
    final value = token.trim();
    if (value.toLowerCase().startsWith(
      '${ConstantKeys.appBearer.toLowerCase()} ',
    )) {
      return value.substring(ConstantKeys.appBearer.length).trim();
    }
    return value;
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    final request = response.request;
    debugPrint(
      'API RESPONSE ${request?.method ?? ''} ${request?.url ?? ''} '
      '${response.statusCode}',
    );
    if (response is http.Response) {
      debugPrint('API RESPONSE BODY: ${response.body}');
    }
    return response;
  }
}
