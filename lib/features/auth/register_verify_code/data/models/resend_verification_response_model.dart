class ResendVerificationResponseModel {
  final bool success;
  final String message;
  final ResendVerificationDataModel data;

  ResendVerificationResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ResendVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendVerificationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ResendVerificationDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class ResendVerificationDataModel {
  final String message;

  ResendVerificationDataModel({required this.message});

  factory ResendVerificationDataModel.fromJson(Map<String, dynamic> json) {
    return ResendVerificationDataModel(message: json['message'] ?? '');
  }
}
