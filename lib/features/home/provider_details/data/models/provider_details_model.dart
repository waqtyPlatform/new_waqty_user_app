class ProviderDetailsModel {
  final String uuid, name;
  final String? description, logoUrl, coverUrl, currencyCode;
  final ProviderCategoryModel? category;
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
  final int? durationMinutes;
  final ProviderCategoryModel? subcategory;
  final int branchesCount;
  const ProviderServiceModel({
    required this.uuid,
    required this.name,
    required this.price,
    required this.priceMax,
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
      durationMinutes: _nullableInt(json['duration_minutes']),
      subcategory: _map(json['subcategory'], ProviderCategoryModel.fromJson),
      branchesCount: _integer(json['branches_count']),
    );
  }
}

class ProviderPackageModel {
  final String uuid, name;
  final String? branchUuid, description, currencyCode;
  final int sessions, validityDays;
  final double originalTotal, price;
  final double? savings, discountPercentage;
  final DateTime? expiresAt;
  final ProviderEmployeeModel? employee;
  final int? sessionDurationMinutes;

  const ProviderPackageModel({
    required this.uuid,
    required this.name,
    required this.originalTotal,
    required this.price,
    this.branchUuid,
    this.description,
    this.currencyCode,
    this.sessions = 0,
    this.validityDays = 0,
    this.savings,
    this.discountPercentage,
    this.expiresAt,
    this.employee,
    this.sessionDurationMinutes,
  });

  factory ProviderPackageModel.fromJson(Map<String, dynamic> json) =>
      ProviderPackageModel(
        uuid: _string(json['uuid']),
        name: _string(json['name']),
        branchUuid: _nullableString(json['branch_uuid']),
        description: _nullableString(json['description']),
        sessions: _integer(json['sessions']),
        validityDays: _integer(json['validity_days']),
        originalTotal: _nullableDouble(json['original_total']) ?? 0,
        price: _nullableDouble(json['price']) ?? 0,
        currencyCode: _nullableString(
          json['currency_code'] ?? json['currency'],
        ),
        savings: _nullableDouble(json['savings']),
        discountPercentage: _nullableDouble(json['discount_percentage']),
        expiresAt: DateTime.tryParse(_string(json['expires_at'])),
        employee: _map(json['employee'], ProviderEmployeeModel.fromJson),
        sessionDurationMinutes: _nullableInt(json['session_duration_minutes']),
      );
}

class ProviderEmployeeModel {
  final String uuid, name;
  final String? jobTitle, photoUrl;
  const ProviderEmployeeModel({
    required this.uuid,
    required this.name,
    this.jobTitle,
    this.photoUrl,
  });
  factory ProviderEmployeeModel.fromJson(Map<String, dynamic> json) =>
      ProviderEmployeeModel(
        uuid: _string(json['uuid']),
        name: _string(json['name']),
        jobTitle: _nullableString(json['job_title']),
        photoUrl: _nullableString(json['photo_url']),
      );
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
