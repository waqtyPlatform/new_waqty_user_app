import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_service.dart';

class AccountRepo extends BaseRepo<AccountService> {
  const AccountRepo(super.remote, super.mock);

  Future<Either<Failure, AccountUiModel>> profile() =>
      guard(() => source.profile());

  Future<Either<Failure, Unit>> logout() => guard(() => source.logout());
}
