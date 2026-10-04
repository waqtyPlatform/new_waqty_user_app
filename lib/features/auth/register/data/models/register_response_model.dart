class RegisterResponseModel {
  final bool success;
  final String message;
  final RegisterDataModel data;

  RegisterResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: RegisterDataModel.fromJson(json['data']),
      );
}

class RegisterDataModel {
  final String? email;
  final String login;
  final bool phoneVerificationRequired;
  final String otpChannel;
  final String otpSentTo;
  final String verifyEndpoint;

  RegisterDataModel({
    required this.email,
    required this.login,
    required this.phoneVerificationRequired,
    required this.otpChannel,
    required this.otpSentTo,
    required this.verifyEndpoint,
  });

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) =>
      RegisterDataModel(
        email: json['email']?.toString(),
        login: json['login']?.toString() ?? json['email']?.toString() ?? '',
        phoneVerificationRequired: json['phone_verification_required'] ?? false,
        otpChannel: json['otp_channel'] ?? 'email',
        otpSentTo: json['otp_sent_to'] ?? '',
        verifyEndpoint:
            json['verify_endpoint']?.toString() ??
            '/api/user/auth/verify-email',
      );
}
