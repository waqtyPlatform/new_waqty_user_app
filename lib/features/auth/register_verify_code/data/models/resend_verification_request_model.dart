class ResendVerificationRequestModel {
  final String email;
  final String otpChannel;

  ResendVerificationRequestModel({
    required this.email,
    required this.otpChannel,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp_channel': otpChannel};
  }
}
