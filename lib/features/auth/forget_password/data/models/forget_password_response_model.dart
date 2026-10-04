class ForgetPasswordResponseModel {
  final bool success;
  final String message;
  final String channel;
  final String sentTo;

  ForgetPasswordResponseModel({
    required this.success,
    required this.message,
    required this.channel,
    required this.sentTo,
  });

  factory ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      channel: json['data']?['channel']?.toString() ?? '',
      sentTo: json['data']?['sent_to']?.toString() ?? '',
    );
  }
}
