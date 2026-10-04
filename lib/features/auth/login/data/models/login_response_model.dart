class LoginResponseModel {
  final bool success;
  final int code;
  final String message;
  final String email;
  final String status;
  final String login;
  final String otpChannel;
  final String verifyEndpoint;
  final String authAction;
  final LoginDataModel? data;

  LoginResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.email,
    required this.status,
    required this.login,
    required this.otpChannel,
    required this.verifyEndpoint,
    required this.authAction,
    required this.data,
  });

  factory LoginResponseModel.fromJson(
    Map<String, dynamic> json, {
    int? code,
  }) => LoginResponseModel(
    success: json['success'] ?? false,
    code: code ?? 0,
    message: json['message'] ?? '',
    email: json['email'] ?? '',
    status: json['status'] ?? '',
    login: json['login']?.toString() ?? json['email']?.toString() ?? '',
    otpChannel: json['otp_channel'] ?? 'email',
    verifyEndpoint:
        json['verify_endpoint']?.toString() ?? '/api/user/auth/verify-email',
    authAction: _authActionFromJson(json),
    data: json['data'] != null ? LoginDataModel.fromJson(json['data']) : null,
  );

  bool get isRegisterAction =>
      _isRegisterAuthAction(authAction) || data?.isRegisterAction == true;
}

class LoginDataModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;
  final bool profileComplete;
  final List<String> missingProfileFields;
  final String authAction;

  LoginDataModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.profileComplete,
    required this.missingProfileFields,
    required this.authAction,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
    token: json['token'] ?? '',
    tokenType: json['token_type'] ?? '',
    expiresIn: json['expires_in'] ?? 0,
    user: UserModel.fromJson(json['user']),
    profileComplete: json['profile_complete'] ?? true,
    missingProfileFields:
        (json['missing_profile_fields'] as List?)
            ?.map((field) => field.toString())
            .toList() ??
        const [],
    authAction: _authActionFromJson(json),
  );

  bool get isRegisterAction => _isRegisterAuthAction(authAction);
}

String _authActionFromJson(Map<String, dynamic> json) {
  const keys = [
    'auth_action',
    'action',
    'auth_flow',
    'flow',
    'auth_state',
    'state',
    'mode',
    'type',
    'result',
    'account_action',
    'next_step',
  ];

  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }

  if (_isTrue(json['register']) ||
      _isTrue(json['is_register']) ||
      _isTrue(json['is_new']) ||
      _isTrue(json['is_new_user']) ||
      _isTrue(json['created'])) {
    return 'register';
  }

  if (_isTrue(json['login']) ||
      _isTrue(json['is_login']) ||
      _isFalse(json['register']) ||
      _isFalse(json['is_register']) ||
      _isFalse(json['is_new']) ||
      _isFalse(json['is_new_user']) ||
      _isFalse(json['created'])) {
    return 'login';
  }

  return '';
}

bool _isRegisterAuthAction(String value) {
  final normalized = value.toLowerCase().trim().replaceAll('-', '_');
  return normalized == 'register' ||
      normalized == 'registered' ||
      normalized == 'signup' ||
      normalized == 'sign_up' ||
      normalized == 'new' ||
      normalized == 'new_user' ||
      normalized == 'created' ||
      normalized == 'complete_profile';
}

bool _isTrue(dynamic value) => value == true || value?.toString() == 'true';

bool _isFalse(dynamic value) => value == false || value?.toString() == 'false';

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
  final String emailVerifiedAt;
  final String phoneVerifiedAt;

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
    required this.emailVerifiedAt,
    required this.phoneVerifiedAt,
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
    emailVerifiedAt: json['email_verified_at'] ?? '',
    phoneVerifiedAt: json['phone_verified_at'] ?? '',
  );
}
