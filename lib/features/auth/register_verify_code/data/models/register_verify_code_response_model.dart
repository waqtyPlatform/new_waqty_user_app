class RegisterVerifyCodeResponseModel {
  final bool success;
  final String message;
  final VerifyCodeDataModel data;

  RegisterVerifyCodeResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterVerifyCodeResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterVerifyCodeResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: VerifyCodeDataModel.fromJson(json['data']),
      );
}

class VerifyCodeDataModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final VerifyCodeUserModel user;
  final bool profileComplete;
  final List<String> missingProfileFields;

  VerifyCodeDataModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.profileComplete,
    required this.missingProfileFields,
  });

  factory VerifyCodeDataModel.fromJson(Map<String, dynamic> json) =>
      VerifyCodeDataModel(
        token: json['token'] ?? '',
        tokenType: json['token_type'] ?? '',
        expiresIn: json['expires_in'] ?? 0,
        user: VerifyCodeUserModel.fromJson(json['user']),
        profileComplete: json['profile_complete'] ?? true,
        missingProfileFields:
            (json['missing_profile_fields'] as List?)
                ?.map((field) => field.toString())
                .toList() ??
            const [],
      );
}

class VerifyCodeUserModel {
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

  VerifyCodeUserModel({
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

  factory VerifyCodeUserModel.fromJson(Map<String, dynamic> json) =>
      VerifyCodeUserModel(
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
