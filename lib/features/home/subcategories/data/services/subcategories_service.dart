import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/subcategories/data/models/subcategory_model.dart';
import 'subcategories_api_end_points.dart';

class SubcategoriesService {
  final ApiConsumer apiConsumer;

  SubcategoriesService({required this.apiConsumer});

  Future<List<SubcategoryModel>> list({
    required String categoryUuid,
    String? query,
    String? countryCode,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      params['country_code'] = countryCode.trim();
    }
    final uri = Uri.parse(SubcategoriesApiEndPoints.list(categoryUuid))
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await apiConsumer.get(uri.toString(), {});
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 &&
        decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SubcategoryModel.fromJson)
            .where((item) => item.uuid.isNotEmpty && item.name.isNotEmpty)
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
}
