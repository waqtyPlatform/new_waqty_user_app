import 'package:waqty_user_application/features/home/subcategories/data/models/subcategory_model.dart';

abstract class SubcategoriesState {
  final List<SubcategoryModel> subcategories;
  const SubcategoriesState([this.subcategories = const []]);
}

class SubcategoriesInitialState extends SubcategoriesState {
  const SubcategoriesInitialState();
}

class SubcategoriesLoadingState extends SubcategoriesState {
  const SubcategoriesLoadingState([super.subcategories]);
}

class SubcategoriesLoadedState extends SubcategoriesState {
  const SubcategoriesLoadedState(super.subcategories);
}

class SubcategoriesErrorState extends SubcategoriesState {
  const SubcategoriesErrorState([super.subcategories]);
}
