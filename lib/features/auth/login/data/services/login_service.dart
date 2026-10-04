import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
      null,
    );
    return _parseAuthResponse(response);
  }

  Future<LoginResponseModel> loginWithGoogle({
    required String idToken,
    String? fcmToken,
    required String platform,
    required String deviceId,
  }) async {
    final response = await apiConsumer.post(LoginApiEndPoints.googleLoginUrl, {
      'id_token': idToken,
      if (fcmToken != null) 'fcm_token': fcmToken,
      'platform': platform,
      'device_id': deviceId,
      'app': 'user',
    }, null);
    debugPrint('GOOGLE_BACKEND_LOGIN_STATUS: ${response.statusCode}');
    _debugPrintGoogleBackendResponse(response);
    return _parseAuthResponse(response);
  }

  void _debugPrintGoogleBackendResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        debugPrint('GOOGLE_BACKEND_LOGIN_MESSAGE: ${decoded['message']}');
        debugPrint('GOOGLE_BACKEND_LOGIN_ERRORS: ${decoded['errors']}');
        debugPrint('GOOGLE_BACKEND_AUTH_ACTION: ${_authActionForLog(decoded)}');
        debugPrint(
          'GOOGLE_BACKEND_LOGIN_DATA: ${jsonEncode(_redactAuthData(decoded['data']))}',
        );
        return;
      }
    } catch (_) {}
    debugPrint('GOOGLE_BACKEND_LOGIN_BODY: ${response.body}');
  }

  dynamic _redactAuthData(dynamic data) {
    if (data is! Map<String, dynamic>) return data;
    final redacted = Map<String, dynamic>.from(data);
    if (redacted.containsKey('token')) redacted['token'] = '[redacted]';
    return redacted;
  }

  String? _authActionForLog(Map<String, dynamic> body) {
    final rootAction = _firstAuthAction(body);
    if (rootAction != null) return rootAction;
    final data = body['data'];
    if (data is Map<String, dynamic>) return _firstAuthAction(data);
    return null;
  }

  String? _firstAuthAction(Map<String, dynamic> json) {
    const keys = [
      'auth_action',
      'action',
      'auth_flow',
      'flow',
      'auth_state',
      'state',
      'mode',
      'type',
      'result',
      'account_action',
      'next_step',
      'register',
      'is_register',
      'is_new',
      'is_new_user',
      'created',
      'login',
      'is_login',
    ];
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return '$key=$value';
      }
    }
    return null;
  }

  LoginResponseModel _parseAuthResponse(http.Response response) {
    if (response.statusCode == StatusCode.ok ||
        response.statusCode == StatusCode.created ||
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
