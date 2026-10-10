import 'package:waqty_user_application/core/api/end_points.dart';

class HomeApiEndPoints {
  static String profile = '${EndPoints.baseUrl}/user/auth/me';
  static String categories = '${EndPoints.baseUrl}/user/home/categories';
  static String upcomingBooking =
      '${EndPoints.baseUrl}/user/home/upcoming-booking';
  static String pendingRatings =
      '${EndPoints.baseUrl}/user/home/pending-ratings';
  static String waitlistOffer = '${EndPoints.baseUrl}/user/home/waitlist-offer';
  static String availableNow = '${EndPoints.baseUrl}/user/home/available-now';
  static String nearbyOffers = '${EndPoints.baseUrl}/user/home/nearby-offers';
  static String bookAgain = '${EndPoints.baseUrl}/user/home/book-again';
  static String topRated = '${EndPoints.baseUrl}/user/home/top-rated';
  static String rateBooking(String bookingUuid) =>
      '${EndPoints.baseUrl}/user/bookings/${Uri.encodeComponent(bookingUuid)}/rate';
  static String announceOnWay(String bookingUuid) =>
      '${EndPoints.baseUrl}/user/home/bookings/${Uri.encodeComponent(bookingUuid)}/on-my-way';
  static String location = '${EndPoints.baseUrl}/user/location';
  static String updateLocation =
      '${EndPoints.baseUrl}/user/location/coordinates';
}
