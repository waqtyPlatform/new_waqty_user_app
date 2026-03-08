class ForgetPasswordRequestModel {
  String email;

  ForgetPasswordRequestModel({required this.email});

  Map<String, dynamic> toJson() => {"email": email};
}
