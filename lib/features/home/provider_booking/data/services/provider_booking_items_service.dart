import 'dart:convert';

import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';

import 'provider_booking_items_api_end_points.dart';
import '../models/provider_booking_items_model.dart';

class ProviderBookingItemsService {
  final ApiConsumer apiConsumer;

  const ProviderBookingItemsService({required this.apiConsumer});

  Future<ProviderBookingCatalogueModel> catalogue({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
  }) async {
    final data =
        await _get(ProviderBookingItemsApiEndPoints.catalogue(providerUuid), {
          'branch_uuid': branchUuid,
          'type': type == ProviderBookingItemType.services
              ? 'services'
              : 'packages',
        });
    return ProviderBookingCatalogueModel.fromJson(_map(data));
  }

  Future<ProviderBookingEntitlementsModel> entitlements({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
    String status = 'active',
  }) async {
    final data = await _get(ProviderBookingItemsApiEndPoints.entitlements, {
      'provider_uuid': providerUuid,
      'branch_uuid': branchUuid,
      'type': type == ProviderBookingItemType.ownedPackages
          ? 'packages'
          : 'follow_ups',
      'status': status,
    });
    return ProviderBookingEntitlementsModel.fromJson(_map(data));
  }

  Future<dynamic> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse(path).replace(queryParameters: query);
    final response = await apiConsumer.get(uri.toString(), await _headers());
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded is Map<String, dynamic>) {
      return decoded['data'];
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      ),
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};
    return {ConstantKeys.appAuthorization: '${ConstantKeys.appBearer} $token'};
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};
