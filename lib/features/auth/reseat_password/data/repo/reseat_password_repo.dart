import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_service.dart';

class ReseatPasswordRepo {
  final ReseatPasswordService _reseatPasswordService;

  ReseatPasswordRepo(this._reseatPasswordService);
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
