class ProviderDetailsModel {
  final String uuid, name;
  final String? description, logoUrl, coverUrl, currencyCode;
  final ProviderCategoryModel? category;
  final ProviderPoliciesModel? policies;
  final double? rating, distanceKm;
  final int ratingCount, servicesCount;
  final bool isOpenNow;
  final List<ProviderBranchModel> branches;
  final List<ProviderServiceModel> services;
  final List<ProviderEmployeeModel> employees;
  final List<ProviderReviewModel> reviews;
  final List<ProviderPackageModel> packages;
  const ProviderDetailsModel({
    required this.uuid,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.currencyCode,
    this.category,
    this.policies,
    this.rating,
    this.distanceKm,
    this.ratingCount = 0,
    this.servicesCount = 0,
    this.isOpenNow = false,
    this.branches = const [],
    this.services = const [],
    this.employees = const [],
    this.reviews = const [],
    this.packages = const [],
  });
  factory ProviderDetailsModel.fromJson(Map<String, dynamic> json) =>
      ProviderDetailsModel(
        uuid: _string(json['uuid']),
        name: _string(json['name']),
        description: _nullableString(json['description']),
        logoUrl: _nullableString(json['logo_url']),
        coverUrl: _nullableString(json['cover_url']),
        currencyCode: _nullableString(json['currency_code']),
        category: _map(json['category'], ProviderCategoryModel.fromJson),
        policies: _map(json['policies'], ProviderPoliciesModel.fromJson),
        rating: _nullableDouble(json['rating']),
        ratingCount: _integer(json['rating_count']),
        distanceKm: _nullableDouble(json['distance_km']),
        isOpenNow: json['is_open_now'] == true,
        branches: _list(json['branches'], ProviderBranchModel.fromJson),
        services: _list(json['services'], ProviderServiceModel.fromJson),
        servicesCount: _integer(json['services_count']),
        employees: _list(json['employees'], ProviderEmployeeModel.fromJson),
        reviews: _list(json['reviews'], ProviderReviewModel.fromJson),
        packages: _list(json['packages'], ProviderPackageModel.fromJson),
      );
}

class ProviderPoliciesModel {
  final String? cancellation, refund, noShow;
  final int? cancellationWindowHours;
  final double? noShowFee;

  const ProviderPoliciesModel({
    this.cancellation,
    this.cancellationWindowHours,
    this.refund,
    this.noShow,
    this.noShowFee,
  });

  factory ProviderPoliciesModel.fromJson(Map<String, dynamic> json) =>
      ProviderPoliciesModel(
        cancellation: _nullableString(json['cancellation']),
        cancellationWindowHours: _nullableInt(
          json['cancellation_window_hours'],
        ),
        refund: _nullableString(json['refund']),
        noShow: _nullableString(json['no_show']),
        noShowFee: _nullableDouble(json['no_show_fee']),
      );

  bool get hasContent =>
      cancellation != null ||
      cancellationWindowHours != null ||
      refund != null ||
      noShow != null ||
      noShowFee != null;
}

class ProviderCategoryModel {
  final String uuid, name;
  const ProviderCategoryModel({required this.uuid, required this.name});
  factory ProviderCategoryModel.fromJson(Map<String, dynamic> json) =>
      ProviderCategoryModel(
        uuid: _string(json['uuid']),
        name: _string(json['name']),
      );
}

class ProviderBranchModel {
  final String uuid, name;
  final String? address, city, closesAt;
  final double? latitude, longitude, distanceKm;
  final bool isOpenNow;
  final List<ProviderWorkingHourModel> workingHours;
  const ProviderBranchModel({
    required this.uuid,
    required this.name,
    this.address,
    this.city,
    this.closesAt,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isOpenNow = false,
    this.workingHours = const [],
  });
  factory ProviderBranchModel.fromJson(Map<String, dynamic> json) =>
      ProviderBranchModel(
        uuid: _string(json['uuid']),
        name: _string(json['name']),
        address: _nullableString(json['address']),
        city: _nullableString(json['city']),
        closesAt: _nullableString(json['closes_at']),
        latitude: _nullableDouble(json['latitude']),
        longitude: _nullableDouble(json['longitude']),
        distanceKm: _nullableDouble(json['distance_km']),
        isOpenNow: json['is_open_now'] == true,
        workingHours: _list(
          json['working_hours'],
          ProviderWorkingHourModel.fromJson,
        ),
      );
  String get displayAddress => [
    address,
    city,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).join('، ');
}

class ProviderWorkingHourModel {
  final int dayOfWeek;
  final String startTime, endTime;
  const ProviderWorkingHourModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
  factory ProviderWorkingHourModel.fromJson(Map<String, dynamic> json) =>
      ProviderWorkingHourModel(
        dayOfWeek: _integer(json['day_of_week']),
        startTime: _string(json['start_time']),
        endTime: _string(json['end_time']),
      );
}

class ProviderServiceModel {
  final String uuid, name;
  final String? branchUuid, description, imageUrl, currencyCode;
  final double price, priceMax;
  final double? basePrice;
  final int? durationMinutes;
  final ProviderCategoryModel? subcategory;
  final int branchesCount;
  const ProviderServiceModel({
    required this.uuid,
    required this.name,
    required this.price,
    required this.priceMax,
    this.basePrice,
    this.branchUuid,
    this.description,
    this.imageUrl,
    this.currencyCode,
    this.durationMinutes,
    this.subcategory,
    this.branchesCount = 0,
  });
  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final price = _nullableDouble(json['price']) ?? 0;
    return ProviderServiceModel(
      uuid: _string(json['uuid']),
      name: _string(json['name']),
      branchUuid: _nullableString(json['branch_uuid']),
      description: _nullableString(json['description']),
      imageUrl: _nullableString(json['image_url']),
      currencyCode: _nullableString(json['currency_code'] ?? json['currency']),
      price: price,
      priceMax: _nullableDouble(json['price_max']) ?? price,
      basePrice: _nullableDouble(json['base_price']),
      durationMinutes: _nullableInt(json['duration_minutes']),
      subcategory: _map(json['subcategory'], ProviderCategoryModel.fromJson),
      branchesCount: _integer(json['branches_count']),
    );
  }
}

class ProviderEmployeeProfileModel {
  final String uuid, name, providerUuid, providerName, branchUuid, branchName;
  final String? jobTitle, photoUrl, currencyCode;
  final double? rating;
  final int ratingCount, servicesCount;
  final List<ProviderServiceModel> services;

  const ProviderEmployeeProfileModel({
    required this.uuid,
    required this.name,
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.ratingCount,
    required this.servicesCount,
    required this.services,
    this.jobTitle,
    this.photoUrl,
    this.currencyCode,
    this.rating,
  });

  factory ProviderEmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map<String, dynamic>
        ? json['provider'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final branch = json['branch'] is Map<String, dynamic>
        ? json['branch'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return ProviderEmployeeProfileModel(
      uuid: _string(json['uuid']),
      name: _string(json['name']),
      jobTitle: _nullableString(json['job_title']),
      photoUrl: _nullableString(json['photo_url']),
      providerUuid: _string(provider['uuid']),
      providerName: _string(provider['name']),
      branchUuid: _string(branch['uuid']),
      branchName: _string(branch['name']),
      rating: _nullableDouble(json['rating']),
      ratingCount: _integer(json['rating_count']),
      services: _list(json['services'], ProviderServiceModel.fromJson),
      servicesCount: _integer(json['services_count']),
      currencyCode: _nullableString(json['currency_code']),
    );
  }
}

class ProviderPackageModel {
  final String uuid, name;
  final String? branchUuid, description, currencyCode, unitName;
  final int sessions, validityDays, units;
  final ProviderPackageType type;
  final double originalTotal, price;
  final double? savings, discountPercentage;
  final DateTime? expiresAt;
  final ProviderEmployeeModel? employee;
  final int? sessionDurationMinutes;
  final List<ProviderPackageIncludedServiceModel> includedServices;

  const ProviderPackageModel({
    required this.uuid,
    required this.name,
    required this.originalTotal,
    required this.price,
    this.branchUuid,
    this.description,
    this.currencyCode,
    this.unitName,
    this.sessions = 0,
    this.validityDays = 0,
    this.units = 0,
    this.type = ProviderPackageType.unknown,
    this.savings,
    this.discountPercentage,
    this.expiresAt,
    this.employee,
    this.sessionDurationMinutes,
    this.includedServices = const [],
  });

  factory ProviderPackageModel.fromJson(
    Map<String, dynamic> json,
  ) => ProviderPackageModel(
    uuid: _string(json['uuid']),
    name: _string(json['name']),
    branchUuid: _nullableString(json['branch_uuid']),
    description: _nullableString(json['description']),
    type: ProviderPackageType.fromJson(json['package_type'] ?? json['type']),
    sessions: _integer(json['sessions']),
    units: _integer(
      json['units'] ?? json['total_units'] ?? json['credit_units'],
    ),
    validityDays: _integer(json['validity_days']),
    originalTotal: _nullableDouble(json['original_total']) ?? 0,
    price: _nullableDouble(json['price']) ?? 0,
    currencyCode: _nullableString(json['currency_code'] ?? json['currency']),
    unitName: _nullableString(json['unit_name']),
    savings: _nullableDouble(json['savings']),
    discountPercentage: _nullableDouble(json['discount_percentage']),
    expiresAt: DateTime.tryParse(_string(json['expires_at'])),
    employee: _map(json['employee'], ProviderEmployeeModel.fromJson),
    sessionDurationMinutes: _nullableInt(json['session_duration_minutes']),
    includedServices: _list(
      json['included_services'],
      ProviderPackageIncludedServiceModel.fromJson,
    ),
  );
}

enum ProviderPackageType {
  singleVisit,
  multiSession,
  creditUnits,
  unknown;

  factory ProviderPackageType.fromJson(dynamic value) {
    final type = value?.toString().trim().toLowerCase();
    return switch (type) {
      'single_visit' || 'single' || 'one_visit' => singleVisit,
      'multi_session' || 'multiple_sessions' || 'sessions' => multiSession,
      'credit_units' ||
      'usage_based' ||
      'consumption_units' ||
      'wallet' ||
      'points' => creditUnits,
      _ => unknown,
    };
  }
}

class ProviderPackageIncludedServiceModel {
  final String serviceName;
  final int sessions, unitsPerSession;

  const ProviderPackageIncludedServiceModel({
    required this.serviceName,
    required this.sessions,
    this.unitsPerSession = 0,
  });

  factory ProviderPackageIncludedServiceModel.fromJson(
    Map<String, dynamic> json,
  ) => ProviderPackageIncludedServiceModel(
    serviceName: _string(
      json['service_name'] ??
          (json['service'] is Map ? json['service']['name'] : null) ??
          json['name'],
    ),
    sessions: _integer(json['sessions']),
    unitsPerSession: _integer(json['units_per_session'] ?? json['unit_cost']),
  );
}

class ProviderEmployeeModel {
  final String uuid, name;
  final String? jobTitle, photoUrl, currencyCode, availableDate, branchUuid;
  final List<String> branchUuids;
  final int experienceYears, servicesCount;
  final double selectionFee;
  final List<ProviderServiceModel> services;
  final List<String> availableSlots;
  const ProviderEmployeeModel({
    required this.uuid,
    required this.name,
    this.jobTitle,
    this.photoUrl,
    this.currencyCode,
    this.availableDate,
    this.branchUuid,
    this.branchUuids = const [],
    this.experienceYears = 0,
    this.servicesCount = 0,
    this.selectionFee = 0,
    this.services = const [],
    this.availableSlots = const [],
  });
  factory ProviderEmployeeModel.fromJson(
    Map<String, dynamic> json,
  ) => ProviderEmployeeModel(
    uuid: _string(json['uuid']),
    name: _string(json['name']),
    jobTitle: _nullableString(json['job_title']),
    photoUrl: _nullableString(json['photo_url']),
    currencyCode: _nullableString(json['currency_code'] ?? json['currency']),
    availableDate: _nullableString(json['available_date']),
    branchUuid: _nullableString(json['branch_uuid']),
    branchUuids: _stringList(json['branch_uuids']),
    experienceYears: _integer(json['experience_years']),
    servicesCount: _integer(json['services_count']),
    selectionFee:
        _nullableDouble(json['selection_fee'] ?? json['named_selection_fee']) ??
        0,
    services: _list(json['services'], ProviderServiceModel.fromJson),
    availableSlots: _slotList(json['available_slots'] ?? json['slots']),
  );

  bool isAvailableAtBranch(String? uuid) {
    if (uuid == null || uuid.isEmpty) return true;
    if (branchUuid != null) return branchUuid == uuid;
    if (branchUuids.isNotEmpty) return branchUuids.contains(uuid);
    return true;
  }
}

class ProviderReviewModel {
  final String uuid, comment;
  final int rating;
  final String? userName, serviceName, reply;
  final DateTime? createdAt, repliedAt;
  const ProviderReviewModel({
    required this.uuid,
    required this.rating,
    required this.comment,
    this.userName,
    this.serviceName,
    this.createdAt,
    this.reply,
    this.repliedAt,
  });
  factory ProviderReviewModel.fromJson(Map<String, dynamic> json) =>
      ProviderReviewModel(
        uuid: _string(json['uuid']),
        rating: _integer(json['rating']),
        comment: _string(json['comment']),
        userName: _nullableString(json['user_name']),
        serviceName: _nullableString(json['service_name']),
        createdAt: DateTime.tryParse(_string(json['created_at'])),
        reply: _nullableString(json['reply']),
        repliedAt: DateTime.tryParse(_string(json['replied_at'])),
      );
}

String _string(dynamic value) => value?.toString().trim() ?? '';
String? _nullableString(dynamic value) {
  final result = _string(value);
  return result.isEmpty ? null : result;
}

double? _nullableDouble(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());
int _integer(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
int? _nullableInt(dynamic value) =>
    value == null ? null : int.tryParse(value.toString());
T? _map<T>(dynamic value, T Function(Map<String, dynamic>) parser) =>
    value is Map<String, dynamic> ? parser(value) : null;
List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) parser) =>
    value is List
    ? value
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(growable: false)
    : <T>[];

List<String> _slotList(dynamic value) => value is List
    ? value
          .map(
            (slot) => slot is Map<String, dynamic>
                ? _string(slot['start_time'] ?? slot['time'] ?? slot['label'])
                : _string(slot),
          )
          .where((slot) => slot.isNotEmpty)
          .toList(growable: false)
    : const [];

List<String> _stringList(dynamic value) => value is List
    ? value
          .map(_string)
          .where((item) => item.isNotEmpty)
          .toList(growable: false)
    : const [];
