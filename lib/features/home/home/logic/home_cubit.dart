import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_profile_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/upcoming_booking_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/pending_rating_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;

  HomeCubit(this._homeRepo) : super(HomeInitialState());

  List<HomeCategoryModel> categories = const [];
  bool _categoriesRequestInFlight = false;
  bool _locationRequestInFlight = false;
  bool _locationLoaded = false;
  bool _hasSyncedCurrentSession = false;
  String? selectedCategoryId;
  HomeLocationModel? location;
  HomeProfileModel? profile;
  UpcomingBookingModel? upcomingBooking;
  bool upcomingBookingLoading = false;
  bool announcingOnWay = false;
  List<PendingRatingModel> pendingRatings = const [];
  bool pendingRatingsLoading = false;
  String? selectedRatingBookingUuid;
  int selectedRatingValue = 0;

  String get currentUserName => profile?.name.trim() ?? '';

  Future<void> loadProfile() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return;
    final result = await _homeRepo.profile();
    if (isClosed) return;
    result.fold((_) => emit(HomeProfileErrorState(location: location)), (
      value,
    ) {
      profile = value;
      emit(HomeProfileLoadedState(location: location));
    });
  }

  Future<void> loadUpcomingBooking() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty || upcomingBookingLoading) return;
    upcomingBookingLoading = true;
    emit(HomeUpcomingBookingLoadingState(location: location));
    final result = await _homeRepo.upcomingBooking();
    if (isClosed) return;
    upcomingBookingLoading = false;
    result.fold(
      (_) => emit(HomeUpcomingBookingErrorState(location: location)),
      (value) {
        upcomingBooking = value;
        emit(HomeUpcomingBookingLoadedState(location: location));
      },
    );
  }

  Future<void> loadPendingRatings() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty || pendingRatingsLoading) return;
    pendingRatingsLoading = true;
    emit(HomePendingRatingsLoadingState(location: location));
    final result = await _homeRepo.pendingRatings();
    if (isClosed) return;
    pendingRatingsLoading = false;
    result.fold((_) => emit(HomePendingRatingsErrorState(location: location)), (
      value,
    ) {
      pendingRatings = value;
      if (!value.any((item) => item.bookingUuid == selectedRatingBookingUuid)) {
        selectedRatingBookingUuid = null;
        selectedRatingValue = 0;
      }
      emit(HomePendingRatingsLoadedState(location: location));
    });
  }

  void selectPendingRating(String bookingUuid, int rating) {
    if (rating < 1 ||
        rating > 5 ||
        !pendingRatings.any((item) => item.bookingUuid == bookingUuid)) {
      return;
    }
    selectedRatingBookingUuid = bookingUuid;
    selectedRatingValue = rating;
    emit(HomePendingRatingSelectionState(location: location));
  }

  Future<void> announceOnWay() async {
    final booking = upcomingBooking;
    if (booking == null || !booking.canAnnounceOnWay || announcingOnWay) {
      return;
    }
    announcingOnWay = true;
    emit(HomeOnWayLoadingState(location: location));
    final result = await _homeRepo.announceOnWay(booking.uuid);
    if (isClosed) return;
    announcingOnWay = false;
    result.fold(
      (failure) =>
          emit(HomeOnWayErrorState(failure.message, location: location)),
      (announcedAt) {
        upcomingBooking = booking.announcedAt(announcedAt);
        emit(HomeOnWaySuccessState(location: location));
      },
    );
  }

  Future<void> loadCategories({bool force = false}) async {
    if (_categoriesRequestInFlight || (!force && categories.isNotEmpty)) return;
    _categoriesRequestInFlight = true;
    emit(HomeCategoriesLoadingState(location: location));
    try {
      final result = await _homeRepo.categories();
      result.fold((_) => emit(HomeCategoriesErrorState(location: location)), (
        value,
      ) {
        categories = value;
        emit(
          HomeCategoriesLoadedState(
            value,
            selectedCategoryId: selectedCategoryId,
            location: location,
          ),
        );
      });
    } finally {
      _categoriesRequestInFlight = false;
    }
  }

  Future<void> loadLocation({bool force = false}) async {
    if (_locationRequestInFlight || (_locationLoaded && !force)) return;
    _locationRequestInFlight = true;
    emit(HomeLocationFetchLoadingState(location: location));
    try {
      final result = await _homeRepo.location();
      result.fold(
        (_) => emit(HomeLocationFetchErrorState(location: location)),
        (value) {
          location = value;
          _locationLoaded = true;
          emit(HomeLocationFetchLoadedState(location: value));
        },
      );
    } finally {
      _locationRequestInFlight = false;
    }
  }

  Future<bool> syncCurrentLocation(Position position) async {
    if (_locationRequestInFlight) return false;
    _locationRequestInFlight = true;
    var updateSucceeded = false;
    try {
      if (!_hasSyncedCurrentSession || await _shouldSync(position)) {
        emit(HomeLocationUpdateLoadingState(location: location));
        final result = await _homeRepo.updateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        var requestSucceeded = false;
        result.fold((_) {}, (value) {
          location = value;
          _locationLoaded = true;
          requestSucceeded = true;
        });
        if (!requestSucceeded) {
          emit(HomeLocationUpdateErrorState(location: location));
        } else {
          await _saveSuccessfulSync(position);
          _hasSyncedCurrentSession = true;
          updateSucceeded = true;
          emit(HomeLocationUpdateSuccessState(location: location));
        }
      }
    } finally {
      _locationRequestInFlight = false;
    }

    return updateSucceeded;
  }

  Future<bool> _shouldSync(Position position) async {
    final lastLatitude = CacheHelper.getDouble(
      ConstantKeys.homeLastLocationLatitude,
    );
    final lastLongitude = CacheHelper.getDouble(
      ConstantKeys.homeLastLocationLongitude,
    );
    final lastSyncAt = await CacheHelper.getInt(
      ConstantKeys.homeLastLocationSyncAt,
    );

    if (lastLatitude == null || lastLongitude == null || lastSyncAt == null) {
      return true;
    }

    final distance = Geolocator.distanceBetween(
      lastLatitude,
      lastLongitude,
      position.latitude,
      position.longitude,
    );
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastSyncAt),
    );
    return distance >= 500 || elapsed >= const Duration(minutes: 10);
  }

  Future<void> _saveSuccessfulSync(Position position) async {
    await CacheHelper.setData(
      ConstantKeys.homeLastLocationLatitude,
      position.latitude,
    );
    await CacheHelper.setData(
      ConstantKeys.homeLastLocationLongitude,
      position.longitude,
    );
    await CacheHelper.setData(
      ConstantKeys.homeLastLocationSyncAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    emit(
      HomeCategoriesLoadedState(
        categories,
        selectedCategoryId: selectedCategoryId,
        location: location,
      ),
    );
  }

  static HomeCubit get(context) => BlocProvider.of(context);
}
