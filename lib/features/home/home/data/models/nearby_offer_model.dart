class NearbyOfferModel {
  final String providerUuid;
  final String providerName;
  final String branchUuid;
  final String branchName;
  final String categoryUuid;
  final String categoryName;
  final String packageUuid;
  final String packageName;
  final String? logoUrl;
  final double? rating;
  final int ratingCount;
  final double? distanceKm;
  final double originalTotal;
  final double packagePrice;
  final int sessionsIncluded;
  final int discountPercentage;
  final double savings;
  final int? daysRemaining;

  const NearbyOfferModel({
    required this.providerUuid,
    required this.providerName,
    required this.branchUuid,
    required this.branchName,
    required this.categoryUuid,
    required this.categoryName,
    required this.packageUuid,
    required this.packageName,
    required this.ratingCount,
    required this.originalTotal,
    required this.packagePrice,
    required this.sessionsIncluded,
    required this.discountPercentage,
    required this.savings,
    this.logoUrl,
    this.rating,
    this.distanceKm,
    this.daysRemaining,
  });

  factory NearbyOfferModel.fromJson(Map<String, dynamic> json) =>
      NearbyOfferModel(
        providerUuid: json['provider_uuid']?.toString() ?? '',
        providerName: json['provider_name']?.toString() ?? '',
        branchUuid: json['branch_uuid']?.toString() ?? '',
        branchName: json['branch_name']?.toString() ?? '',
        categoryUuid: json['category_uuid']?.toString() ?? '',
        categoryName: json['category_name']?.toString() ?? '',
        packageUuid: json['package_uuid']?.toString() ?? '',
        packageName: json['package_name']?.toString() ?? '',
        logoUrl: _nullableString(json['logo_url']),
        rating: _nullableDouble(json['rating']),
        ratingCount: _int(json['rating_count']),
        distanceKm: _nullableDouble(json['distance_km']),
        originalTotal: _double(json['original_total']),
        packagePrice: _double(json['package_price']),
        sessionsIncluded: _int(json['sessions_included']),
        discountPercentage: _int(json['discount_percentage']),
        savings: _double(json['savings']),
        daysRemaining: json['days_remaining'] == null
            ? null
            : _int(json['days_remaining']),
      );
}

class NearbyOffersPageModel {
  final List<NearbyOfferModel> items;
  final int page;
  final bool hasMore;

  const NearbyOffersPageModel({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory NearbyOffersPageModel.fromJson(
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
    return NearbyOffersPageModel(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(NearbyOfferModel.fromJson)
                .where(
                  (offer) =>
                      offer.providerUuid.isNotEmpty &&
                      offer.packageUuid.isNotEmpty,
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

double _double(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}

int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
