class VerifyCodeRequestModel {
  String email;
  String otp;

  VerifyCodeRequestModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {"email": email, "otp": otp};
}
