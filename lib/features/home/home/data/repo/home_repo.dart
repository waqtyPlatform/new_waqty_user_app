import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_profile_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/upcoming_booking_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/pending_rating_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';

class HomeRepo {
  final HomeService _homeService;

  HomeRepo(this._homeService);

  Future<Either<Failure, HomeProfileModel>> profile() async {
    try {
      return Right(await _homeService.profile());
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, UpcomingBookingModel?>> upcomingBooking() async {
    try {
      return Right(await _homeService.upcomingBooking());
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, List<PendingRatingModel>>> pendingRatings() async {
    try {
      return Right(await _homeService.pendingRatings());
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, DateTime>> announceOnWay(String bookingUuid) async {
    try {
      return Right(await _homeService.announceOnWay(bookingUuid));
    } on ServerException catch (failure) {
      return Left(failure.serverFailure);
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, List<HomeCategoryModel>>> categories({
    String? query,
  }) async {
    try {
      return Right(await _homeService.categories(query: query));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, HomeLocationModel>> location() async {
    try {
      return Right(await _homeService.location());
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  Future<Either<Failure, HomeLocationModel>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return Right(
        await _homeService.updateLocation(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }

  //
  // Future<Either<Failure, GetMyAddressResponseModel>> myAddress(
  //   String type,
  //   String search,
  // ) async {
  //   try {
  //     return Right(await _myAddressService.myAddress(type, search));
  //   } on ServerException catch (failure) {
  //     return Left(ServerFailure(message: failure.serverFailure.message));
  //   }
  // }
  //
  // Future<Either<Failure, SuccessResponseModel>> deleteAddress(int id) async {
  //   try {
  //     return Right(await _myAddressService.deleteAddress(id));
  //   } on ServerException catch (failure) {
  //     return Left(ServerFailure(message: failure.serverFailure.message));
  //   }
  // }
  // Future<Either<Failure, SuccessResponseModel>> setAddressDefault(int id) async {
  //   try {
  //     return Right(await _myAddressService.setAddressDefault(id));
  //   } on ServerException catch (failure) {
  //     return Left(ServerFailure(message: failure.serverFailure.message));
  //   }
  // }
}
