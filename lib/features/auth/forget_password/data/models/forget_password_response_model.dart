class ForgetPasswordResponseModel {
  final bool success;
  final String message;

  ForgetPasswordResponseModel({required this.success, required this.message});

  factory ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
