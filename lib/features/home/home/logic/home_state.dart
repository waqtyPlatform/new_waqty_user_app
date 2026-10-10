import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';

abstract class HomeState {
  final HomeLocationModel? location;

  const HomeState({this.location});
}

class HomeInitialState extends HomeState {
  const HomeInitialState({super.location});
}

class HomeProfileLoadedState extends HomeState {
  const HomeProfileLoadedState({super.location});
}

class HomeProfileErrorState extends HomeState {
  const HomeProfileErrorState({super.location});
}

class HomeUpcomingBookingLoadingState extends HomeState {
  const HomeUpcomingBookingLoadingState({super.location});
}

class HomeUpcomingBookingLoadedState extends HomeState {
  const HomeUpcomingBookingLoadedState({super.location});
}

class HomeUpcomingBookingErrorState extends HomeState {
  const HomeUpcomingBookingErrorState({super.location});
}

class HomePendingRatingsLoadingState extends HomeState {
  const HomePendingRatingsLoadingState({super.location});
}

class HomePendingRatingsLoadedState extends HomeState {
  const HomePendingRatingsLoadedState({super.location});
}

class HomePendingRatingsErrorState extends HomeState {
  const HomePendingRatingsErrorState({super.location});
}

class HomePendingRatingSelectionState extends HomeState {
  const HomePendingRatingSelectionState({super.location});
}

class HomeRatingSubmitLoadingState extends HomeState {
  const HomeRatingSubmitLoadingState({super.location});
}

class HomeRatingSubmitSuccessState extends HomeState {
  final String message;

  const HomeRatingSubmitSuccessState(this.message, {super.location});
}

class HomeRatingSubmitErrorState extends HomeState {
  final String message;

  const HomeRatingSubmitErrorState(this.message, {super.location});
}

class HomeWaitlistOfferLoadingState extends HomeState {
  const HomeWaitlistOfferLoadingState({super.location});
}

class HomeWaitlistOfferLoadedState extends HomeState {
  const HomeWaitlistOfferLoadedState({super.location});
}

class HomeWaitlistOfferTickState extends HomeState {
  const HomeWaitlistOfferTickState({super.location});
}

class HomeWaitlistOfferErrorState extends HomeState {
  const HomeWaitlistOfferErrorState({super.location});
}

class HomeOnWayLoadingState extends HomeState {
  const HomeOnWayLoadingState({super.location});
}

class HomeOnWaySuccessState extends HomeState {
  const HomeOnWaySuccessState({super.location});
}

class HomeOnWayErrorState extends HomeState {
  final String message;
  const HomeOnWayErrorState(this.message, {super.location});
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
