class ResendVerificationResponseModel {
  final bool success;
  final String message;
  final ResendVerificationDataModel data;

  ResendVerificationResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ResendVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendVerificationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ResendVerificationDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class ResendVerificationDataModel {
  final String otpChannel;
  final String otpSentTo;

  ResendVerificationDataModel({
    required this.otpChannel,
    required this.otpSentTo,
  });

  factory ResendVerificationDataModel.fromJson(Map<String, dynamic> json) {
    return ResendVerificationDataModel(
      otpChannel: json['otp_channel'] ?? 'email',
      otpSentTo: json['otp_sent_to'] ?? '',
    );
  }
}
