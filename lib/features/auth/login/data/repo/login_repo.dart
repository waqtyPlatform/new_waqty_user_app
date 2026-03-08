import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_request_model.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/login/data/services/login_service.dart';

class LoginRepo {
  final LoginService _loginService;

  LoginRepo(this._loginService);

  Future<Either<Failure, LoginResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final response = await _loginService.login(requestModel);
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    }
  }
}
