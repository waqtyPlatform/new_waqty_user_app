import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_account.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_service.dart';

class AccountMockService implements AccountService {
  const AccountMockService();

  @override
  Future<Either<Failure, AccountUiModel>> profile() async =>
      (await MockSource.fetch(MockAccount.me)).fold(
        (message) => Left(ServerFailure(message: message)),
        Right.new,
      );

  @override
  Future<Either<Failure, Unit>> logout() async {
    await Future.delayed(MockConfig.effectiveDelay);
    return const Right(unit);
  }
}
