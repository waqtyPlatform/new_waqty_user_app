class ProviderDetailsModel {
  final String uuid;
  final String name;
  final String? imageUrl;
  final String categoryName;
  final String branchName;
  final String address;
  final String description;
  final double rating;
  final int reviewsCount;
  final bool isOpen;
  final List<String> services;
  final List<String> packages;

  const ProviderDetailsModel({
    required this.uuid,
    required this.name,
    this.imageUrl,
    this.categoryName = '',
    this.branchName = '',
    this.address = '',
    this.description = '',
    this.rating = 0,
    this.reviewsCount = 0,
    this.isOpen = true,
    this.services = const [],
    this.packages = const [],
  });

  factory ProviderDetailsModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] is Map<String, dynamic>
        ? json['branch'] as Map<String, dynamic>
        : <String, dynamic>{};
    return ProviderDetailsModel(
      uuid: (json['uuid'] ?? json['provider_uuid'] ?? json['id'] ?? '')
          .toString(),
      name: (json['name'] ?? json['provider_name'] ?? '').toString(),
      imageUrl: _text(
        json['logo_path'] ?? json['logo_url'] ?? json['image_url'],
      ),
      categoryName: (json['category_name'] ?? '').toString(),
      branchName: (json['branch_name'] ?? branch['name'] ?? '').toString(),
      address: (json['address'] ?? branch['address'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0,
      reviewsCount:
          int.tryParse(
            (json['rating_count'] ?? json['reviews_count'] ?? 0).toString(),
          ) ??
          0,
      isOpen: json['is_open'] != false,
      services: _strings(json['services']),
      packages: _strings(json['packages']),
    );
  }

  static String? _text(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is Map) {
            return (item['name'] ?? item['title'] ?? '').toString();
          }
          return item.toString();
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
