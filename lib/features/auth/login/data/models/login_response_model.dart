class LoginResponseModel {
  final bool success;
  final String message;
  final LoginDataModel data;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: LoginDataModel.fromJson(json['data']),
      );
}

class LoginDataModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  LoginDataModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
    token: json['token'] ?? '',
    tokenType: json['token_type'] ?? '',
    expiresIn: json['expires_in'] ?? 0,
    user: UserModel.fromJson(json['user']),
  );
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? dateBirth;
  final String? gender;
  final bool active;
  final bool blocked;
  final bool banned;
  final String uuid;
  final String updatedAt;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateBirth,
    required this.gender,
    required this.active,
    required this.blocked,
    required this.banned,
    required this.uuid,
    required this.updatedAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dateBirth: json['date_birth'] ?? '',
    gender: json['gender'] ?? '',
    active: json['active'] ?? false,
    blocked: json['blocked'] ?? false,
    banned: json['banned'] ?? false,
    uuid: json['uuid'] ?? '',
    updatedAt: json['updated_at'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}
