import 'package:waqty_user_application/core/api/end_points.dart';

class BookingCartApiEndPoints {
  static const String cart = '${EndPoints.baseUrl}/user/booking-cart';
  static const String items = '$cart/items';
  static const String checkout = '$cart/checkout';

  static String item(String itemUuid) =>
      '$items/${Uri.encodeComponent(itemUuid)}';
}
