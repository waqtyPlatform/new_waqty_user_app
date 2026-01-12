class GetMyAddressResponseModel {
  String message;
  List<DataModel> dataModel;

  GetMyAddressResponseModel({required this.message, required this.dataModel});

  factory GetMyAddressResponseModel.fromJson(Map<String, dynamic> json) =>
      GetMyAddressResponseModel(
        message: json['message'] ?? '',
        dataModel: List<DataModel>.from(
          json['data'].map((item) => DataModel.fromJson(item)),
        ).toList(),
      );
}

class DataModel {
  int id;
  String name;
  String type;
  bool isDefault;
  String fullAddress;
  String mobileNumber;
  String country;
  String city;
  String area;
  String landmark;
  String latitude;
  String longitude;

  DataModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.fullAddress,
    required this.mobileNumber,
    required this.country,
    required this.city,
    required this.area,
    required this.landmark,
    required this.latitude,
    required this.longitude,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    id: json['id'],
    name: json['title'] ?? '',
    type: json['type'] ?? '',
    isDefault: json['is_default'] ?? false,
    fullAddress: json['full_address'] ?? '',
    mobileNumber: json['mobile_number'] ?? '',
    country: json['country'] ?? '',
    city: json['city'] ?? '',
    area: json['area'] ?? '',
    landmark: json['landmark'] ?? '',
    latitude: json['latitude'] ?? '',
    longitude: json['longitude'] ?? '',
  );
}
