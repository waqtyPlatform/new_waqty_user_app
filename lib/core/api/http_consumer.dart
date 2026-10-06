import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/app_interceptor.dart';
import 'package:waqty_user_application/core/api/end_points.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;

class HttpConsumer implements ApiConsumer {
  http.Client _client;
  Future<bool>? _refreshRequest;

  HttpConsumer(this._client) {
    _client = InterceptedClient.build(interceptors: [getIt<AppInterceptor>()]);
  }

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    final requestHeaders = _copyHeaders(headers);
    return _withRefresh(
      () => _client.get(Uri.parse(path), headers: requestHeaders),
      requestHeaders,
    );
  }

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _copyHeaders(headers);
    return _withRefresh(
      () => _client.put(
        Uri.parse(path),
        body: json.encode(body),
        headers: requestHeaders,
      ),
      requestHeaders,
    );
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _copyHeaders(headers);
    return _withRefresh(
      () => _client.post(
        Uri.parse(path),
        body: json.encode(body),
        headers: requestHeaders,
      ),
      requestHeaders,
    );
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _copyHeaders(headers);
    return _withRefresh(
      () => _client.delete(
        Uri.parse(path),
        body: json.encode(body),
        headers: requestHeaders,
      ),
      requestHeaders,
    );
  }

  Map<String, String>? _copyHeaders(Map<String, String>? headers) =>
      headers == null ? null : Map<String, String>.from(headers);

  Future<http.Response> _withRefresh(
    Future<http.Response> Function() request,
    Map<String, String>? headers,
  ) async {
    final response = await request();
    if (response.statusCode != 401) return response;

    final refreshed = await _refreshBearer();
    if (!refreshed) return response;

    headers?.remove(ConstantKeys.appAuthorization);
    return request();
  }

  Future<bool> _refreshBearer() async {
    final activeRequest = _refreshRequest;
    if (activeRequest != null) return activeRequest;

    final request = _performRefreshBearer();
    _refreshRequest = request;
    try {
      return await request;
    } finally {
      if (identical(_refreshRequest, request)) _refreshRequest = null;
    }
  }

  Future<bool> _performRefreshBearer() async {
    final oldToken = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (oldToken.isEmpty) return false;

    final authorization = oldToken.toLowerCase().startsWith('bearer ')
        ? oldToken
        : '${ConstantKeys.appBearer} $oldToken';
    final response = await _client.post(
      Uri.parse(EndPoints.refreshToken),
      headers: {
        ConstantKeys.appAuthorization: authorization,
        ConstantKeys.contentType: ConstantKeys.applicationJson,
        ConstantKeys.acceptText: ConstantKeys.applicationJson,
      },
    );
    if (response.statusCode != StatusCode.ok) return false;

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    final token = data is Map<String, dynamic>
        ? data['token']?.toString().trim() ?? ''
        : '';
    if (token.isEmpty) return false;

    await CacheHelper.setSecuredString(ConstantKeys.saveTokenToShared, token);
    return true;
  }

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    final requestHeaders = _copyHeaders(headers);
    return _withRefresh(
      () => _sendMultiPost(path, body, requestHeaders),
      requestHeaders,
    );
  }

  Future<http.Response> _sendMultiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(path));
    if (headers != null) request.headers.addAll(headers);

    for (final entry in body.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key == "images") {
        for (var item in value as List<String>) {
          request.files.add(await http.MultipartFile.fromPath(key, item));
        }
      } else if (key == "captions[]" && value is List<String>) {
        for (var caption in value) {
          request.fields.addAll({"captions[]": caption});
        }
      } else if (key == "remove_images[]") {
        for (var i = 0; i < value.length; i++) {
          request.fields.addAll({"remove_images[$i]": value[i].toString()});
        }
      } else if (key == "files[]") {
        for (var item in value as List<String>) {
          request.files.add(await http.MultipartFile.fromPath(key, item));
        }
      } else if (key == "images[]") {
        for (var item in value as List<String>) {
          request.files.add(await http.MultipartFile.fromPath(key, item));
        }
      } else if (key == "budget_breakdown_file") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else if (key == "img" || key == "image") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else if (key == "logo") {
        request.files.add(
          await http.MultipartFile.fromPath(key, value.toString()),
        );
      } else {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      }
    }
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
