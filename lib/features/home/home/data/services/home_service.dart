import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_category_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_location_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_profile_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/upcoming_booking_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/pending_rating_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/waitlist_offer_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/available_now_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/nearby_offer_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/book_again_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/top_rated_provider_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_api_end_points.dart';

class HomeService {
  ApiConsumer apiConsumer;

  HomeService({required this.apiConsumer});

  Future<HomeProfileModel> profile() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.profile,
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) &&
        decoded?['data'] is Map<String, dynamic>) {
      return HomeProfileModel.fromJson(
        decoded!['data'] as Map<String, dynamic>,
      );
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<UpcomingBookingModel?> upcomingBooking() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.upcomingBooking,
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded != null) {
      final data = decoded['data'];
      if (data == null) return null;
      if (data is Map<String, dynamic>) {
        final booking = UpcomingBookingModel.fromJson(data);
        if (booking.uuid.isNotEmpty) return booking;
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<List<PendingRatingModel>> pendingRatings() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.pendingRatings,
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['data'] is List) {
      return (decoded!['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(PendingRatingModel.fromJson)
          .where((rating) => rating.bookingUuid.isNotEmpty)
          .toList(growable: false);
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<WaitlistOfferModel?> waitlistOffer() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.waitlistOffer,
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded != null) {
      final data = decoded['data'];
      if (data == null) return null;
      if (data is Map<String, dynamic>) {
        final offer = WaitlistOfferModel.fromJson(data);
        if (offer.uuid.isNotEmpty) return offer;
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<AvailableNowPageModel> availableNow({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      HomeApiEndPoints.availableNow,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['data'] is List) {
      return AvailableNowPageModel.fromJson(decoded!, requestedPage: page);
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<NearbyOffersPageModel> nearbyOffers({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      HomeApiEndPoints.nearbyOffers,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['data'] is List) {
      return NearbyOffersPageModel.fromJson(decoded!, requestedPage: page);
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<BookAgainPageModel> bookAgain({int page = 1, int limit = 10}) async {
    final uri = Uri.parse(
      HomeApiEndPoints.bookAgain,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['data'] is List) {
      return BookAgainPageModel.fromJson(decoded!, requestedPage: page);
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<TopRatedProvidersPageModel> topRated({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      HomeApiEndPoints.topRated,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['data'] is List) {
      return TopRatedProvidersPageModel.fromJson(decoded!, requestedPage: page);
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<String> rateBooking({
    required String bookingUuid,
    required int rating,
  }) async {
    final response = await apiConsumer.post(
      HomeApiEndPoints.rateBooking(bookingUuid),
      {'rating': rating},
      await _authHeaders(),
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded?['success'] == true) {
      return decoded?['message']?.toString().trim() ?? '';
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<DateTime> announceOnWay(String bookingUuid) async {
    final response = await apiConsumer.post(
      HomeApiEndPoints.announceOnWay(bookingUuid),
      const {},
      await _authHeaders(),
    );
    debugPrint(
      'HOME_ON_WAY status=${response.statusCode} response=${response.body}',
    );
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) &&
        decoded?['data'] is Map<String, dynamic>) {
      final data = decoded!['data'] as Map<String, dynamic>;
      final announcedAt = DateTime.tryParse(
        (data['announced_at'] ?? data['on_way_announced_at'])?.toString() ?? '',
      );
      if (announcedAt != null) return announcedAt;
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<List<HomeCategoryModel>> categories({String? query}) async {
    final uri = Uri.parse(HomeApiEndPoints.categories).replace(
      queryParameters: query != null && query.trim().isNotEmpty
          ? {'q': query.trim()}
          : null,
    );
    final response = await apiConsumer.get(
      uri.toString(),
      await _authHeaders(),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode == StatusCode.ok &&
        decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(HomeCategoryModel.fromJson)
            .where((category) => category.hasProviders)
            .toList();
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
      ),
    );
  }

  Future<HomeLocationModel> location() async {
    final response = await apiConsumer.get(
      HomeApiEndPoints.location,
      await _authHeaders(),
    );
    _logLocationResponse('GET', response);
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode) && decoded != null) {
      final data = decoded['data'];
      final locationData = data is Map<String, dynamic>
          ? _nestedLocation(data) ?? data
          : _nestedLocation(decoded);
      if (locationData is Map<String, dynamic>) {
        return HomeLocationModel.fromJson(locationData);
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<HomeLocationModel> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiConsumer.put(HomeApiEndPoints.updateLocation, {
      'latitude': latitude,
      'longitude': longitude,
    }, await _authHeaders());
    _logLocationResponse('PUT', response);
    final decoded = _decode(response.body);
    if (_isSuccess(response.statusCode)) {
      if (decoded == null) return const HomeLocationModel.empty();

      final data = decoded['data'];
      final locationData = data is Map<String, dynamic>
          ? _nestedLocation(data) ?? data
          : _nestedLocation(decoded);
      if (locationData is Map<String, dynamic>) {
        return HomeLocationModel.fromJson(locationData);
      }
      if (decoded['success'] == true) {
        return const HomeLocationModel.empty();
      }
    }
    throw ServerException(
      serverFailure: ServerFailure.fromJson(decoded ?? <String, dynamic>{}),
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = (await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    )).trim();
    if (token.isEmpty) return {};

    return {ConstantKeys.appAuthorization: '${ConstantKeys.appBearer} $token'};
  }

  Map<String, dynamic>? _nestedLocation(Map<String, dynamic> json) {
    for (final key in ['location', 'user_location', 'current_location']) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
    }
    if (json.containsKey('needs_prompt')) return json;
    return null;
  }

  Map<String, dynamic>? _decode(String body) {
    if (body.trim().isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  void _logLocationResponse(String method, dynamic response) {
    debugPrint(
      'HOME_LOCATION_$method status=${response.statusCode} '
      'message=${_decode(response.body)?['message'] ?? ''}',
    );
    debugPrint('HOME_LOCATION_$method response=${response.body}');
  }
}
