import 'dart:convert';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/end_points.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import '../models/provider_details_model.dart';
import '../models/provider_booking_model.dart';

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

  Future<List<ProviderServiceModel>> bookingServices(
    String providerUuid,
    String branchUuid,
  ) async {
    final data = await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/services',
      {'branch_uuid': branchUuid},
    );
    return _modelList(data, ProviderServiceModel.fromJson);
  }

  Future<ProviderBookingEmployeesModel> bookingEmployees(
    String providerUuid,
    String branchUuid,
    String serviceUuid,
  ) async => ProviderBookingEmployeesModel.fromData(
    await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/employees',
      {'branch_uuid': branchUuid, 'service_uuid': serviceUuid},
    ),
  );

  Future<List<ProviderBookingDateModel>> bookingDates({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required String timezone,
  }) async {
    final now = DateTime.now();
    final data = await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/dates',
      {
        'branch_uuid': branchUuid,
        'service_uuid': serviceUuid,
        if (employeeUuid != null) 'employee_uuid': employeeUuid,
        'from': _date(now),
        'days': '14',
        'timezone': timezone,
      },
    );
    final map = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    return _modelList(map['dates'], ProviderBookingDateModel.fromJson);
  }

  Future<ProviderBookingSlotsModel> bookingSlots({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required DateTime date,
    required String timezone,
  }) async => ProviderBookingSlotsModel.fromData(
    await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/slots',
      {
        'branch_uuid': branchUuid,
        'service_uuid': serviceUuid,
        if (employeeUuid != null) 'employee_uuid': employeeUuid,
        'date': _date(date),
        'timezone': timezone,
      },
    ),
  );

  Future<List<ProviderPackageModel>> bookingPackages(
    String providerUuid,
    String branchUuid,
  ) async => _modelList(
    await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/packages',
      {'branch_uuid': branchUuid},
    ),
    ProviderPackageModel.fromJson,
  );

  Future<List<ProviderBookingDateModel>> packageDates({
    required String providerUuid,
    required String branchUuid,
    required String packageUuid,
    required String timezone,
  }) async {
    final data = await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/packages/${Uri.encodeComponent(packageUuid)}/dates',
      {
        'branch_uuid': branchUuid,
        'from': _date(DateTime.now()),
        'days': '14',
        'timezone': timezone,
      },
    );
    final map = data is Map<String, dynamic> ? data : const <String, dynamic>{};
    return _modelList(map['dates'], ProviderBookingDateModel.fromJson);
  }

  Future<ProviderBookingSlotsModel> packageSlots({
    required String providerUuid,
    required String branchUuid,
    required String packageUuid,
    required DateTime date,
    required String timezone,
  }) async => ProviderBookingSlotsModel.fromData(
    await _get(
      '/user/providers/${Uri.encodeComponent(providerUuid)}/booking/packages/${Uri.encodeComponent(packageUuid)}/slots',
      {'branch_uuid': branchUuid, 'date': _date(date), 'timezone': timezone},
    ),
  );

  Future<void> createBooking(Map<String, dynamic> body) async {
    await _post('/user/bookings', body);
  }

  Future<void> joinWaitlist(Map<String, dynamic> body) async {
    await _post('/user/waitlist', body);
  }

  Future<dynamic> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse(
      '${EndPoints.baseUrl}$path',
    ).replace(queryParameters: query);
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    return _decode(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await apiConsumer.post(
      '${EndPoints.baseUrl}$path',
      body,
      await _authHeaders(),
    );
    return _decode(response);
  }

  dynamic _decode(dynamic response) {
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

  Future<Map<String, String>> _authHeaders() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};
    return {ConstantKeys.appAuthorization: '${ConstantKeys.appBearer} $token'};
  }
}

List<T> _modelList<T>(dynamic data, T Function(Map<String, dynamic>) parser) =>
    data is List
    ? data.whereType<Map<String, dynamic>>().map(parser).toList(growable: false)
    : <T>[];

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
