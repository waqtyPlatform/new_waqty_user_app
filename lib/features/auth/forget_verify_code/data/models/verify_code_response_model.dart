class VerifyCodeResponseModel {
  final bool success;
  final String message;
  final bool valid;

  VerifyCodeResponseModel({
    required this.success,
    required this.message,
    required this.valid,
  });

  factory VerifyCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      valid: json['data']?['valid'] ?? false,
    );
  }
}
