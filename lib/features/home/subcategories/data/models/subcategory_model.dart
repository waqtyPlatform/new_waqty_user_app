class SubcategoryModel {
  final String uuid;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? description;

  const SubcategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.description,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconUrl: json['icon_url'] as String?,
      description: json['description']?.toString(),
    );
  }
}
