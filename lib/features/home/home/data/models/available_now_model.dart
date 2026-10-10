import 'package:waqty_user_application/core/api/end_points.dart';

class AvailableNowModel {
  final String providerUuid;
  final String providerName;
  final String branchUuid;
  final String branchName;
  final String categoryUuid;
  final String categoryName;
  final String? logoUrl;
  final double? rating;
  final int ratingCount;
  final double? distanceKm;
  final String closesAt;

  const AvailableNowModel({
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.categoryUuid,
    required this.categoryName,
    required this.ratingCount,
    required this.closesAt,
    this.logoUrl,
    this.rating,
    this.distanceKm,
  });

  factory AvailableNowModel.fromJson(Map<String, dynamic> json) =>
      AvailableNowModel(
        providerUuid: json['provider_uuid']?.toString() ?? '',
        providerName: json['provider_name']?.toString() ?? '',
        branchUuid: json['branch_uuid']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        categoryUuid: json['category_uuid']?.toString() ?? '',
        categoryName: json['category_name']?.toString() ?? '',
        logoUrl: _logoUrl(json['logo_path']),
        rating: _nullableDouble(json['rating']),
        ratingCount: int.tryParse(json['rating_count']?.toString() ?? '') ?? 0,
        distanceKm: _nullableDouble(json['distance_km']),
        closesAt: json['closes_at']?.toString() ?? '',
      );
}

class AvailableNowPageModel {
  final List<AvailableNowModel> items;
  final int page;
  final bool hasMore;

  const AvailableNowPageModel({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory AvailableNowPageModel.fromJson(
    Map<String, dynamic> json, {
    required int requestedPage,
  }) {
    final data = json['data'];
    final meta = json['meta'];
    final metaMap = meta is Map<String, dynamic> ? meta : null;
    final page =
        int.tryParse(metaMap?['page']?.toString() ?? '') ??
        int.tryParse(metaMap?['current_page']?.toString() ?? '') ??
        requestedPage;
    final lastPage = int.tryParse(metaMap?['last_page']?.toString() ?? '');
    return AvailableNowPageModel(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(AvailableNowModel.fromJson)
                .where((item) => item.providerUuid.isNotEmpty)
                .toList(growable: false)
          : const [],
      page: page,
      hasMore:
          metaMap?['has_more'] == true || (lastPage != null && page < lastPage),
    );
  }
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}

String? _logoUrl(dynamic value) {
  final path = value?.toString().trim();
  if (path == null || path.isEmpty) return null;
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;

  final normalized = path.replaceFirst(RegExp(r'^/+'), '');
  final storagePath = normalized.startsWith('public/storage/')
      ? normalized
      : normalized.startsWith('storage/')
      ? 'public/$normalized'
      : 'public/storage/$normalized';
  return '${Uri.parse(EndPoints.baseUrl).origin}/$storagePath';
}
