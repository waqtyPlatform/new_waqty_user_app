class HomeProfileModel {
  final String name;
  final bool profileComplete;
  final List<String> missingProfileFields;
  final bool emailVerified;
  final bool phoneVerified;
  final VerificationNoticeModel? verificationNotice;

  const HomeProfileModel({
    required this.name,
    required this.profileComplete,
    required this.missingProfileFields,
    required this.emailVerified,
    required this.phoneVerified,
    this.verificationNotice,
  });

  factory HomeProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return HomeProfileModel(
      name: user['name']?.toString().trim() ?? '',
      profileComplete: json['profile_complete'] == true,
      missingProfileFields: json['missing_profile_fields'] is List
          ? (json['missing_profile_fields'] as List)
                .map((field) => field.toString())
                .toList(growable: false)
          : const [],
      emailVerified: json['email_verified'] == true,
      phoneVerified: json['phone_verified'] == true,
      verificationNotice: json['verification_notice'] is Map<String, dynamic>
          ? VerificationNoticeModel.fromJson(
              json['verification_notice'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class VerificationNoticeModel {
  final String type;
  final String message;

  const VerificationNoticeModel({required this.type, required this.message});

  factory VerificationNoticeModel.fromJson(Map<String, dynamic> json) =>
      VerificationNoticeModel(
        type: json['type']?.toString().trim() ?? '',
        message: json['message']?.toString().trim() ?? '',
      );
}
