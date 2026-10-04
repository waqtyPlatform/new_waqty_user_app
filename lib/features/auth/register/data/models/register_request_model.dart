class RegisterRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String dateBirth;
  final String gender;
  final String countryIso2;
  final String otpChannel;
  final String? fcmToken;
  final String platform;
  final String deviceId;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.dateBirth,
    required this.gender,
    required this.countryIso2,
    required this.otpChannel,
    required this.fcmToken,
    required this.platform,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (email.isNotEmpty) 'email': email,
    'password': password,
    if (phone.isNotEmpty) 'phone': phone,
    'country_iso2': countryIso2,
    if (dateBirth.isNotEmpty) 'date_birth': dateBirth,
    'gender': gender,
    if (fcmToken != null) 'fcm_token': fcmToken,
    'platform': platform,
    'device_id': deviceId,
    'otp_channel': otpChannel,
  };
}
