class RegisterResponseModel {
  final bool success;
  final String message;
  final RegisterDataModel data;

  RegisterResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: RegisterDataModel.fromJson(json['data']),
      );
}

class RegisterDataModel {
  final String message;
  final String email;

  RegisterDataModel({required this.message, required this.email});

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) =>
      RegisterDataModel(
        message: json['message'] ?? '',
        email: json['email'] ?? '',
      );
}
