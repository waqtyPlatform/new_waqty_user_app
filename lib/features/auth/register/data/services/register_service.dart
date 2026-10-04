import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    final requestBody = registerRequestModel.toJson();
    debugPrint(
      'REGISTER_REQUEST_BODY: ${jsonEncode(_redactRegisterBody(requestBody))}',
    );
    final response = await apiConsumer.post(
      RegisterApiEndPoints.registerUrl,
      requestBody,
      null,
    );
    debugPrint('REGISTER_RESPONSE_STATUS: ${response.statusCode}');
    _debugPrintRegisterResponse(response.body);
    if (response.statusCode == StatusCode.ok ||
        response.statusCode == StatusCode.created) {
      return RegisterResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(
        serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
      );
    }
  }

  Map<String, dynamic> _redactRegisterBody(Map<String, dynamic> body) {
    final redacted = Map<String, dynamic>.from(body);
    if (redacted.containsKey('password')) {
      redacted['password'] = '[redacted]';
    }
    if (redacted.containsKey('fcm_token')) {
      redacted['fcm_token'] = '[redacted]';
    }
    return redacted;
  }

  void _debugPrintRegisterResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        debugPrint('REGISTER_RESPONSE_MESSAGE: ${decoded['message']}');
        debugPrint('REGISTER_RESPONSE_ERRORS: ${decoded['errors']}');
        return;
      }
    } catch (_) {}
    debugPrint('REGISTER_RESPONSE_BODY: $body');
  }
}
