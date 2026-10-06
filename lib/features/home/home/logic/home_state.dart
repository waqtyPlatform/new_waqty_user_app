import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';

abstract class HomeState {
  final HomeLocationModel? location;

  const HomeState({this.location});
}

class HomeInitialState extends HomeState {
  const HomeInitialState({super.location});
}

class HomeCategoriesLoadingState extends HomeState {
  const HomeCategoriesLoadingState({super.location});
}

class HomeCategoriesLoadedState extends HomeState {
  final List<HomeCategoryModel> categories;
  final String? selectedCategoryId;

  HomeCategoriesLoadedState(
    this.categories, {
    this.selectedCategoryId,
    super.location,
  });
}

class HomeCategoriesErrorState extends HomeState {
  const HomeCategoriesErrorState({super.location});
}

class HomeLocationFetchLoadingState extends HomeState {
  const HomeLocationFetchLoadingState({super.location});
}

class HomeLocationFetchLoadedState extends HomeState {
  const HomeLocationFetchLoadedState({required super.location});
}

class HomeLocationFetchErrorState extends HomeState {
  const HomeLocationFetchErrorState({super.location});
}

class HomeLocationUpdateLoadingState extends HomeState {
  const HomeLocationUpdateLoadingState({super.location});
}

class HomeLocationUpdateSuccessState extends HomeState {
  const HomeLocationUpdateSuccessState({super.location});
}

class HomeLocationUpdateErrorState extends HomeState {
  const HomeLocationUpdateErrorState({super.location});
}
