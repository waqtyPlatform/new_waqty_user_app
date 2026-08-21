import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_service.dart';

class PhoneVerificationRemoteService implements PhoneVerificationService {
  final ApiClient _client;

  const PhoneVerificationRemoteService(this._client);

  @override
  Future<Either<Failure, Unit>> sendCode({
    required String phone,
    required String countryIso2,
  }) => _client.post(
    ApiPaths.sendPhoneVerification,
    body: <String, dynamic>{'phone': phone, 'country_iso2': countryIso2},
    parse: (_) => unit,
  );

  @override
  Future<Either<Failure, PhoneClaimResultUiModel>> verify({
    required String phone,
    required String countryIso2,
    required String otp,
  }) => _client.post(
    ApiPaths.verifyPhone,
    body: <String, dynamic>{
      'phone': phone,
      'country_iso2': countryIso2,
      'otp': otp,
    },
    // الرد `{"success":true,"message":"…","data":{linked,relinked_bookings,…}}`
    parse: (envelope) =>
        PhoneClaimResultUiModel.fromJson(JsonParse.mapValue(envelope.data)),
  );
}
