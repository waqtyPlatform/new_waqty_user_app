class LoginRequestModel {
  final String login;
  final String password;

  LoginRequestModel({required this.login, required this.password});

  Map<String, dynamic> toJson() => {'login': login, 'password': password};
}
