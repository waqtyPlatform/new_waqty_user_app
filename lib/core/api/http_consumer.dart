import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/app_interceptor.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;

class HttpConsumer implements ApiConsumer {
  http.Client _client;

  HttpConsumer(this._client) {
    _client = InterceptedClient.build(interceptors: [getIt<AppInterceptor>()]);
  }

  @override
  Future<http.Response> get(String path, Map<String, String>? headers) async {
    final response = await _client.get(Uri.parse(path), headers: headers);
    return response;
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
