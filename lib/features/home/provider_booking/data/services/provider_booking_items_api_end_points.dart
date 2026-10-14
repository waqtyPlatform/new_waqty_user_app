import 'package:waqty_user_application/core/api/end_points.dart';

class ProviderBookingItemsApiEndPoints {
  static String catalogue(String providerUuid) =>
      '${EndPoints.baseUrl}/user/providers/${Uri.encodeComponent(providerUuid)}/catalogue';

  static const String entitlements =
      '${EndPoints.baseUrl}/user/my-entitlements';
}
