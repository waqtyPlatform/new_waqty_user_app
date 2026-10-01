class ForgetPasswordRequestModel {
  final String key;
  final String value;

  ForgetPasswordRequestModel({required this.key, required this.value});

  Map<String, dynamic> toJson() => {key: value};
}
