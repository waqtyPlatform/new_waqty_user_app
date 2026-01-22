import 'package:waqty_user_application/features/auth/login/data/services/login_service.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

class ServiceProviderDetailsRepo {
  final ServiceProviderDetailsService _serviceProviderDetailsService;

  ServiceProviderDetailsRepo(this._serviceProviderDetailsService);
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
