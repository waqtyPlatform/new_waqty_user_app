class RegisterVerifyCodeRequestModel {
  String email;
  String otp;

  RegisterVerifyCodeRequestModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {"email": email, "otp": otp};
}
