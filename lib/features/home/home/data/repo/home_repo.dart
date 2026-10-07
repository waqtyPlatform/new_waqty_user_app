import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';

class HomeRepo {
  final HomeService _homeService;

  HomeRepo(this._homeService);

  Future<Either<Failure, List<HomeCategoryModel>>> categories({String? query}) async {
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
