import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_api_end_points.dart';

class HomeService {
  ApiConsumer apiConsumer;

  HomeService({required this.apiConsumer});

  Future<List<HomeCategoryModel>> categories() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.categories,
      await _authHeaders(),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode == StatusCode.ok &&
        decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(HomeCategoryModel.fromJson)
            .where(
              (category) => category.name.isNotEmpty && category.shouldDisplay,
            )
            .toList();
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      ),
    );
  }

  Future<HomeLocationModel> location() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.location,
      await _authHeaders(),
    );
    _logLocationResponse('GET', response);
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded != null) {
      final data = decoded['data'];
      final locationData = data is Map<String, dynamic>
          ? _nestedLocation(data) ?? data
          : _nestedLocation(decoded);
      if (locationData is Map<String, dynamic>) {
        return HomeLocationModel.fromJson(locationData);
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<HomeLocationModel> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiConsumer.put(HomeApiEndPoints.updateLocation, {
      'latitude': latitude,
      'longitude': longitude,
    }, await _authHeaders());
    _logLocationResponse('PUT', response);
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode)) {
      if (decoded == null) return const HomeLocationModel.empty();

      final data = decoded['data'];
      final locationData = data is Map<String, dynamic>
          ? _nestedLocation(data) ?? data
          : _nestedLocation(decoded);
      if (locationData is Map<String, dynamic>) {
        return HomeLocationModel.fromJson(locationData);
      }
      if (decoded['success'] == true) {
        return const HomeLocationModel.empty();
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};

    return {ConstantKeys.appAuthorization: '${ConstantKeys.appBearer} $token'};
  }

  Map<String, dynamic>? _nestedLocation(Map<String, dynamic> json) {
    for (final key in ['location', 'user_location', 'current_location']) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
    }
    if (json.containsKey('needs_prompt')) return json;
    return null;
  }

  Map<String, dynamic>? _decode(String body) {
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  void _logLocationResponse(String method, dynamic response) {
    debugPrint(
      'HOME_LOCATION_$method status=${response.statusCode} '
      'message=${_decode(response.body)?['message'] ?? ''}',
    );
    debugPrint('HOME_LOCATION_$method response=${response.body}');
  }
}
