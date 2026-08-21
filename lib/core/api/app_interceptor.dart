import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/my_app.dart';

/// الهيدرز المشتركة لكل طلب — **بما فيهم `Authorization`**.
///
/// ## ليه التوكن هنا مش في كل service
///
/// كان كل واحد من الـ٦ auth services بيبني `{'Authorization': 'Bearer …'}`
/// بإيده — نفس السطرين متكررين ٦ مرات، **وبيتبعتوا حتى على الدخول والتسجيل**
/// وهما راوتس مفتوحة أصلاً. أي endpoint جديد كان هينسخ نفس الغلطة.
///
/// دلوقتي مكان واحد، و[_publicPaths] بتقول مين مايتحطش عليه توكن.
class AppInterceptor extends InterceptorContract {
  final SessionStore _session;

  AppInterceptor(this._session);

  /// الراوتس اللي بتشتغل **من غير** جلسة.
  ///
  /// ⚠ القايمة بالمسار مش بالـhost — `EndPoints.baseUrl` بيتغيّر بالـ
  /// `--dart-define`، فمقارنة الـURL كاملًا كانت هتكسر أول ما حد يبدّل السيرفر.
  ///
  /// `public/*` كلها مفتوحة، بس بنسيب التوكن يعدّي عليها لو موجود — مافيش
  /// ضرر، ولو الباك-إند قرر يخصّص النتايج للمستخدم بعدين هيلاقيه.
  static const List<String> _publicPaths = [
    '/api/user/auth/register',
    '/api/user/auth/login',
    '/api/user/auth/verify-email',
    '/api/user/auth/resend-verification-otp',
    '/api/user/auth/forgot-password',
    '/api/user/auth/verify-otp',
    '/api/user/auth/reset-password',
  ];

  bool _needsToken(Uri url) =>
      !_publicPaths.any((path) => url.path.endsWith(path));

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    request.headers[ConstantKeys.contentType] = ConstantKeys.applicationJson;
    request.headers[ConstantKeys.acceptText] = ConstantKeys.applicationJson;

    final context = navigatorKey.currentContext;
    request.headers[ConstantKeys.acceptLanguage] =
        (context != null && context.locale == const Locale('en', 'US'))
        ? 'en'
        : 'ar';

    final token = _session.token;
    if (token != null && _needsToken(request.url)) {
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
