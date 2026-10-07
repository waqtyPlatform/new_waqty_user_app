import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/end_points.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import '../models/provider_details_model.dart';

class ProviderDetailsNotFoundException implements Exception {
  const ProviderDetailsNotFoundException();
}

class ProviderDetailsService {
  final ApiConsumer apiConsumer;
  ProviderDetailsService({required this.apiConsumer});
  Future<ProviderDetailsModel> show(String uuid) async {
    final response = await apiConsumer.get(
      '${EndPoints.baseUrl}/user/providers/${Uri.encodeComponent(uuid)}',
      await _authHeaders(),
    );
    if (response.statusCode == 404) {
      throw const ProviderDetailsNotFoundException();
    }
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded is Map<String, dynamic> &&
        decoded['data'] is Map<String, dynamic>) {
      final provider = ProviderDetailsModel.fromJson(
        decoded['data'] as Map<String, dynamic>,
      );
      if (provider.uuid.isNotEmpty && provider.name.isNotEmpty) return provider;
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
