class ResetPasswordResponseModel {
  final bool success;
  final String message;
  final ResetPasswordDataModel? data;

  ResetPasswordResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ResetPasswordDataModel.fromJson(json['data'])
          : null,
    );
  }
}

class ResetPasswordDataModel {
  final String token;
  final String tokenType;
  final int expiresIn;
  final bool profileComplete;

  ResetPasswordDataModel({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.profileComplete,
  });

  factory ResetPasswordDataModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordDataModel(
      token: json['token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? '',
      expiresIn: json['expires_in'] is int ? json['expires_in'] : 0,
      profileComplete: json['profile_complete'] ?? true,
    );
  }
}
