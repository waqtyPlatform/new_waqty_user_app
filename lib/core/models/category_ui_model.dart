/// موديل عرض للتصنيف. بسيط بالقصد — لما نربط بالـ API هنعمل
/// موديل response منفصل ونحوّل منه لده.
class CategoryUiModel {
  final String uuid;
  final String name;
  final String imagePath;
  final int servicesCount;

  const CategoryUiModel({
    required this.uuid,
    required this.name,
    required this.imagePath,
    this.servicesCount = 0,
  });
}
