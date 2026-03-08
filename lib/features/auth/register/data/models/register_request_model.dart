class RegisterRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String dateBirth;
  final String gender;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.dateBirth,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'date_birth': dateBirth,
    'gender': gender,
  };
}
