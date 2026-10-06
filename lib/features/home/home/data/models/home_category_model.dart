class HomeCategoryModel {
  final String uuid;
  final String name;
  final String slug;
  final String? iconUrl;
  final int providersCount;
  final int subcategoriesCount;

  const HomeCategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
    this.iconUrl,
    required this.providersCount,
    required this.subcategoriesCount,
  });

  bool get hasProviders => providersCount > 0;
  bool get hasSubcategories => subcategoriesCount > 0;
  bool get shouldDisplay => hasProviders || hasSubcategories;

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconUrl: json['icon_url'] as String?,
      providersCount: (json['providers_count'] as num?)?.toInt() ?? 0,
      subcategoriesCount: (json['subcategories_count'] as num?)?.toInt() ?? 0,
    );
  }
}
