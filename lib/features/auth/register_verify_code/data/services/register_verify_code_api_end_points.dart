import 'package:waqty_user_application/core/api/end_points.dart';

class RegisterVerifyCodeApiEndPoints {
  static final resendVerificationUrl =
      '${EndPoints.baseUrl}/user/auth/resend-verification-otp';
  static final verifyCode = '${EndPoints.baseUrl}/user/auth/verify-email';
  static final verifyPhoneSignup =
      '${EndPoints.baseUrl}/user/auth/verify-phone-signup';

  static String verifyUrlFromEndpoint(String endpoint) {
    if (endpoint.contains('verify-phone-signup')) return verifyPhoneSignup;
    return verifyCode;
  }
}
