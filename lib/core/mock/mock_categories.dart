import 'package:waqty_user_application/core/models/category_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/public/categories
class MockCategories {
  MockCategories._();

  static const List<CategoryUiModel> all = <CategoryUiModel>[
    CategoryUiModel(
      uuid: 'cat-1',
      name: 'حلاقة رجالي',
      imagePath: '',
      servicesCount: 24,
    ),
    CategoryUiModel(
      uuid: 'cat-2',
      name: 'كوافير حريمي',
      imagePath: '',
      servicesCount: 38,
    ),
    CategoryUiModel(
      uuid: 'cat-3',
      name: 'عناية بالبشرة',
      imagePath: '',
      servicesCount: 16,
    ),
    CategoryUiModel(
      uuid: 'cat-4',
      name: 'مساج واسترخاء',
      imagePath: '',
      servicesCount: 12,
    ),
    CategoryUiModel(
      uuid: 'cat-5',
      name: 'أظافر',
      imagePath: '',
      servicesCount: 9,
    ),
    CategoryUiModel(
      uuid: 'cat-6',
      name: 'عيادات جلدية',
      imagePath: '',
      servicesCount: 21,
    ),
  ];
}
