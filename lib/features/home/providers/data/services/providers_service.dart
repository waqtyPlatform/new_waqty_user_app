import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/home/providers/data/models/provider_model.dart';
import 'providers_api_end_points.dart';

class ProvidersService {
  final ApiConsumer apiConsumer;

  ProvidersService({required this.apiConsumer});

  Future<List<ProviderModel>> list({
    String? categoryUuid,
    String? subcategoryUuid,
    String? query,
    String? sort,
    double? minRating,
    int limit = 10,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (categoryUuid != null && categoryUuid.isNotEmpty) {
      params['category_uuid'] = categoryUuid;
    }
    if (subcategoryUuid != null && subcategoryUuid.isNotEmpty) {
      params['subcategory_uuid'] = subcategoryUuid;
    }
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();

    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (minRating != null) params['min_rating'] = minRating.toString();

    final uri = Uri.parse(
      ProvidersApiEndPoints.list,
    ).replace(queryParameters: params);
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ProviderModel.fromJson)
            .where(
              (provider) =>
                  provider.uuid.isNotEmpty && provider.name.isNotEmpty,
            )
            .toList();
      }
      return const [];
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      ),
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};
    return {ConstantKeys.appAuthorization: '${ConstantKeys.appBearer} $token'};
  }
}
