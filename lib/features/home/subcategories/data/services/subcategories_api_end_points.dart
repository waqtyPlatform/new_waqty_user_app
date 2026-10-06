import 'package:waqty_user_application/core/api/end_points.dart';

class SubcategoriesApiEndPoints {
  static String list(String categoryUuid) =>
      '${EndPoints.baseUrl}/user/home/categories/$categoryUuid/subcategories';
}
