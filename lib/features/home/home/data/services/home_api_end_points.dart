import 'package:waqty_user_application/core/api/end_points.dart';

class HomeApiEndPoints {
  static String categories = '${EndPoints.baseUrl}/user/home/categories';
  static String location = '${EndPoints.baseUrl}/user/location';
  static String updateLocation =
      '${EndPoints.baseUrl}/user/location/coordinates';
}
