import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';

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
