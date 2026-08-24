import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';

/// تأكيد رقم التليفون — **وربط اللي اتعمل على الرقم ده بالحساب**.
///
/// الاتنين فعل واحد على السيرفر: `verify-phone` بيأكّد وبيطالب في نفس
/// الترانزاكشن. فمافيش دالة `claim()` منفصلة — لو اتفصلت هيبقى فيه حالة
/// «مأكّد بس مش مربوط» مالهاش وجود في الباك إند.
abstract class PhoneVerificationService {
  /// بيبعت OTP على الرقم. الرقم بصيغة محلية (`01113000000`) و[countryIso2]
  /// بيحدّد التطبيع.
  Future<Either<Failure, Unit>> sendCode({
    required String phone,
    required String countryIso2,
  });

  /// بيأكّد الـOTP — وبيرجّع **اللي اترّبط**، مش مجرد نجاح.
  Future<Either<Failure, PhoneClaimResultUiModel>> verify({
    required String phone,
    required String countryIso2,
    required String otp,
  });
}
