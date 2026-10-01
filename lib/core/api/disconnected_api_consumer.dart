import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waqty_user_application/core/api/api_consumer.dart';

class DisconnectedApiConsumer implements ApiConsumer {
  static const int _statusCode = 503;

  http.Response _response(String method, String path) {
    return http.Response(
      jsonEncode({
        'message': 'API is temporarily disconnected.',
        'method': method,
        'path': path,
      }),
      _statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    return _response('GET', path);
  }

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    return _response('PUT', path);
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    return _response('POST', path);
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    return _response('DELETE', path);
  }

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    return _response('MULTIPART_POST', path);
  }
}
