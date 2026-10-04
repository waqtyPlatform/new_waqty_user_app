class RegisterVerifyCodeRequestModel {
  String email;
  String otp;
  String verifyEndpoint;

  RegisterVerifyCodeRequestModel({
    required this.email,
    required this.otp,
    required this.verifyEndpoint,
  });

  Map<String, dynamic> toJson() => {"email": email, "otp": otp};
}
