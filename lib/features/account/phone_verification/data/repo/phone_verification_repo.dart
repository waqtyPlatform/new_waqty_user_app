import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_service.dart';

class PhoneVerificationRepo extends BaseRepo<PhoneVerificationService> {
  const PhoneVerificationRepo(super.remote, super.mock);

  Future<Either<Failure, Unit>> sendCode({
    required String phone,
    required String countryIso2,
  }) => guard(() => source.sendCode(phone: phone, countryIso2: countryIso2));

  Future<Either<Failure, PhoneClaimResultUiModel>> verify({
    required String phone,
    required String countryIso2,
    required String otp,
  }) => guard(
    () => source.verify(phone: phone, countryIso2: countryIso2, otp: otp),
  );
}
