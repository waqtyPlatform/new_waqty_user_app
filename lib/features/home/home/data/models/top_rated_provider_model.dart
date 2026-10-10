class TopRatedProviderModel {
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

  const TopRatedProviderModel({
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.categoryUuid,
    required this.categoryName,
    required this.ratingCount,
    this.logoUrl,
    this.rating,
    this.distanceKm,
  });

  factory TopRatedProviderModel.fromJson(Map<String, dynamic> json) =>
      TopRatedProviderModel(
        providerUuid: json['provider_uuid']?.toString() ?? '',
        providerName: json['provider_name']?.toString() ?? '',
        branchUuid: json['branch_uuid']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        categoryUuid: json['category_uuid']?.toString() ?? '',
        categoryName: json['category_name']?.toString() ?? '',
        logoUrl: _nullableString(json['logo_url']),
        rating: _nullableDouble(json['rating']),
        ratingCount: int.tryParse(json['rating_count']?.toString() ?? '') ?? 0,
        distanceKm: _nullableDouble(json['distance_km']),
      );
}

class TopRatedProvidersPageModel {
  final List<TopRatedProviderModel> items;
  final int page;
  final bool hasMore;

  const TopRatedProvidersPageModel({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory TopRatedProvidersPageModel.fromJson(
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
    return TopRatedProvidersPageModel(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(TopRatedProviderModel.fromJson)
                .where(
                  (provider) =>
                      provider.providerUuid.isNotEmpty &&
                      provider.branchUuid.isNotEmpty,
                )
                .toList(growable: false)
          : const [],
      page: page,
      hasMore:
          metaMap?['has_more'] == true || (lastPage != null && page < lastPage),
    );
  }
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}
