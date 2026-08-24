import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:http/http.dart' as http;

/// ناقل HTTP على [http.Client] المحقون.
///
/// ⚠ **الكلاس ده كان بيرمي الـclient اللي بيتحقنله.** الكونستركتور كان:
///
/// ```dart
/// HttpConsumer(this._client) {
///   _client = InterceptedClient.build(interceptors: [getIt<AppInterceptor>()]);
/// }
/// ```
///
/// البراميتر بيتداس في السطر اللي بعده. نتيجتين: الـ`http.Client()` المسجّل في
/// `services_locator` ميت، و**مفيش service ينفع يتختبر** — `MockClient` من
/// `package:http/testing.dart` (موجود مع `http: ^1.5`) مكنش يوصل خالص.
///
/// دلوقتي الـ`InterceptedClient` بيتبني في الـDI ويتحقن من بره، والكلاس ده
/// بقى ناقل صافي.
class HttpConsumer implements ApiConsumer {
  final http.Client _client;

  const HttpConsumer(this._client);

  /// بتبني الـURI بالـquery، وبتشيل القيم `null` عشان `?employee_uuid=null`
  /// مايوصلش للسيرفر كنص.
  Uri _uri(String path, Map<String, dynamic>? query) {
    final uri = Uri.parse(path);
    if (query == null || query.isEmpty) return uri;

    final params = <String, String>{...uri.queryParameters};
    query.forEach((key, value) {
      if (value != null) params[key] = '$value';
    });
    return uri.replace(queryParameters: params.isEmpty ? null : params);
  }

  @override
  Future<http.Response> get(
    String path,
    Map<String, String>? headers, {
    Map<String, dynamic>? query,
  }) async {
    return _client.get(_uri(path, query), headers: headers);
  }

  @override
  Future<http.Response> put(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.put(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> post(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.post(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> patch(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    return _client.patch(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
  }

  @override
  Future<http.Response> delete(
    String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) async {
    final response = await _client.delete(
      Uri.parse(path),
      body: json.encode(body),
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> multiPost(
    String path,
    Map<String, dynamic> body,
    Map<String, String>? headers,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse(path));
    if (headers != null) {
      request.headers.addAll(headers);
    }

    body.forEach((key, value) async {
      if (key == "images") {
        for (var item in value as List<String>) {
          request.files.add(
            await http.MultipartFile.fromPath(key, item.toString()),
          );
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
          request.files.add(
            await http.MultipartFile.fromPath(key, item.toString()),
          );
        }
      } else if (key == "images[]") {
        for (var item in value as List<String>) {
          request.files.add(
            await http.MultipartFile.fromPath(key, item.toString()),
          );
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
    });
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
