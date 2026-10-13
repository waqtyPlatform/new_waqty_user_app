import '../../../provider_details/data/models/provider_details_model.dart';

enum ProviderBookingItemType { services, packages, ownedPackages, followUps }

class ProviderBookingCatalogueModel {
  final String providerUuid, providerName, branchUuid, branchName;
  final String? currencyCode;
  final List<ProviderServiceModel> services;
  final List<ProviderPackageModel> packages;
  final int servicesCount, packagesCount;

  const ProviderBookingCatalogueModel({
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    this.currencyCode,
    this.services = const [],
    this.packages = const [],
    this.servicesCount = 0,
    this.packagesCount = 0,
  });

  factory ProviderBookingCatalogueModel.fromJson(Map<String, dynamic> json) {
    final provider = _map(json['provider']);
    final branch = _map(json['branch']);
    return ProviderBookingCatalogueModel(
      providerUuid: _string(provider['uuid']),
      providerName: _string(provider['name']),
      branchUuid: _string(branch['uuid']),
      branchName: _string(branch['name']),
      currencyCode: _nullableString(json['currency_code']),
      services: _models(json['services'], ProviderServiceModel.fromJson),
      packages: _models(json['packages'], ProviderPackageModel.fromJson),
      servicesCount: _integer(json['services_count']),
      packagesCount: _integer(json['packages_count']),
    );
  }
}

class ProviderBookingEntitlementsModel {
  final String providerUuid, branchUuid, status;
  final List<ProviderBookingEntitlementModel> packages, followUps;
  final int packagesCount, followUpsCount;
  final bool hasEntitlements;

  const ProviderBookingEntitlementsModel({
    required this.providerUuid,
    required this.branchUuid,
    required this.status,
    this.packages = const [],
    this.followUps = const [],
    this.packagesCount = 0,
    this.followUpsCount = 0,
    this.hasEntitlements = false,
  });

  factory ProviderBookingEntitlementsModel.fromJson(
    Map<String, dynamic> json,
  ) => ProviderBookingEntitlementsModel(
    providerUuid: _string(json['provider_uuid']),
    branchUuid: _string(json['branch_uuid']),
    status: _string(json['status']),
    packages: _models(
      json['packages'],
      ProviderBookingEntitlementModel.fromJson,
    ),
    followUps: _models(
      json['follow_ups'],
      ProviderBookingEntitlementModel.fromJson,
    ),
    packagesCount: _integer(json['packages_count']),
    followUpsCount: _integer(json['follow_ups_count']),
    hasEntitlements: json['has_entitlements'] == true,
  );
}

class ProviderBookingEntitlementModel {
  final String uuid, name, status;
  final String? description, serviceUuid, packageUuid, expiresAt, unitName;
  final int? remainingSessions, remainingUnits, remainingVisits;

  const ProviderBookingEntitlementModel({
    required this.uuid,
    required this.name,
    required this.status,
    this.description,
    this.serviceUuid,
    this.packageUuid,
    this.expiresAt,
    this.unitName,
    this.remainingSessions,
    this.remainingUnits,
    this.remainingVisits,
  });

  factory ProviderBookingEntitlementModel.fromJson(Map<String, dynamic> json) {
    final service = _map(json['service']);
    final package = _map(json['package']);
    return ProviderBookingEntitlementModel(
      uuid: _string(json['uuid']),
      name: _string(
        json['name'] ??
            json['package_name'] ??
            json['service_name'] ??
            package['name'] ??
            service['name'],
      ),
      status: _string(json['status']),
      description: _nullableString(json['description']),
      serviceUuid: _nullableString(json['service_uuid'] ?? service['uuid']),
      packageUuid: _nullableString(json['package_uuid'] ?? package['uuid']),
      expiresAt: _nullableString(json['expires_at']),
      unitName: _nullableString(json['unit_name']),
      remainingSessions: _nullableInt(json['remaining_sessions']),
      remainingUnits: _nullableInt(json['remaining_units']),
      remainingVisits: _nullableInt(json['remaining_visits']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<T> _models<T>(dynamic value, T Function(Map<String, dynamic>) parser) =>
    value is List
    ? value
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(growable: false)
    : <T>[];

String _string(dynamic value) => value?.toString() ?? '';

String? _nullableString(dynamic value) {
  final parsed = value?.toString().trim();
  return parsed == null || parsed.isEmpty ? null : parsed;
}

int _integer(dynamic value) => _nullableInt(value) ?? 0;

int? _nullableInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
