import 'package:waqty_user_application/core/api/end_points.dart';

class RegisterVerifyCodeApiEndPoints {
  static final resendVerificationUrl =
      '${EndPoints.baseUrl}/api/user/auth/resend-verification-otp';
  static final verifyCode = '${EndPoints.baseUrl}/api/user/auth/verify-email';
}
