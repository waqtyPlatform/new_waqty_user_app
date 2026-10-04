class ForgetPasswordRequestModel {
  final String email;
  final String channel;

  ForgetPasswordRequestModel({required this.email, required this.channel});

  Map<String, dynamic> toJson() => {"email": email, "channel": channel};
}
