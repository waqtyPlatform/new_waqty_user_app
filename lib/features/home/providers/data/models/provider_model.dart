class ProviderModel {
  final String uuid;
  final String name;
  final String? imageUrl;
  final String? categoryName;
  final String? branchName;
  final double rating;
  final int visitsCount;

  const ProviderModel({
    required this.uuid,
    required this.name,
    this.imageUrl,
    this.categoryName,
    this.branchName,
    required this.rating,
    required this.visitsCount,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] ?? json['main_branch'];
    final branchMap = branch is Map<String, dynamic> ? branch : null;
    return ProviderModel(
      uuid: json['uuid']?.toString() ??
          json['provider_uuid']?.toString() ??
          json['id']?.toString() ??
          '',
      name: _text(json['name'] ?? json['provider_name'] ?? json['provider']) ?? '',
      imageUrl: _mediaUrl(
        json['image_url'] ??
            json['image'] ??
            json['logo_url'] ??
            json['logo_path'] ??
            json['logo'],
      ),
      categoryName: _text(json['category_name'] ?? json['specialty']) ??
          _nestedName(json['category']),
      branchName: _text(
        json['branch_name'] ??
            json['address'] ??
            branchMap?['name'] ??
            branchMap?['address'],
      ),
      rating: _number(json['rating'] ?? json['average_rating']),
      visitsCount: _number(json['visits_count'] ?? json['reviews_count']).toInt(),
    );
  }
}

String? _text(dynamic value) {
  if (value is Map<String, dynamic>) return _nestedName(value);
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String? _nestedName(dynamic value) {
  if (value is! Map<String, dynamic>) return null;
  return _text(value['name'] ?? value['title'] ?? value['label']);
}

String? _mediaUrl(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _text(value['url'] ?? value['path'] ?? value['src']);
  }
  return _text(value);
}

double _number(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;
