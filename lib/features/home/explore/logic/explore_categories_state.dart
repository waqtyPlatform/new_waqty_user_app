import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';

abstract class ExploreCategoriesState {
  final List<HomeCategoryModel> categories;
  final String? selectedCategoryId;

  const ExploreCategoriesState({
    this.categories = const [],
    this.selectedCategoryId,
  });
}

class ExploreCategoriesInitialState extends ExploreCategoriesState {
  const ExploreCategoriesInitialState();
}

class ExploreCategoriesLoadingState extends ExploreCategoriesState {
  const ExploreCategoriesLoadingState({
    super.categories,
    super.selectedCategoryId,
  });
}

class ExploreCategoriesLoadedState extends ExploreCategoriesState {
  const ExploreCategoriesLoadedState(
    List<HomeCategoryModel> categories, {
    super.selectedCategoryId,
  }) : super(categories: categories);
}

class ExploreCategoriesErrorState extends ExploreCategoriesState {
  const ExploreCategoriesErrorState({
    super.categories,
    super.selectedCategoryId,
  });
}
