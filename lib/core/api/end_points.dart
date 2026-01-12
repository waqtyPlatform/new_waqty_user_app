
class EndPoints {
  static const String baseUrl = "https://app.egkcompany.com/";
  static const String _imageBaseUrl = "public/";

  static String getImageFromApi(String imageUrl) {
    return baseUrl + _imageBaseUrl + imageUrl;
  }
}
