import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_service.dart';

class AccountRemoteService implements AccountService {
  final ApiClient _client;

  const AccountRemoteService(this._client);

  @override
  Future<Either<Failure, AccountUiModel>> profile() => _client.get(
    ApiPaths.me,
    // ⚠ `/me` بيرجّع موديل `User` **خام** مش مورد — الحقول snake_case
    // وفيها حاجات داخلية زي `normalized_phone` و`superseded_by_user_id`.
    parse: (envelope) =>
        AccountUiModel.fromJson(JsonParse.mapValue(envelope.data)),
  );

  @override
  Future<Either<Failure, Unit>> logout() =>
      _client.post(ApiPaths.logout, parse: (_) => unit);
}
