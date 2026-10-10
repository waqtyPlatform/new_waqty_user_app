import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/features/home/available_now/ui/available_now_screen.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_profile_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/upcoming_booking_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/pending_rating_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/waitlist_offer_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/nearby_offer_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/book_again_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/top_rated_provider_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/available_now_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_api_end_points.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_design_widgets.dart';

void main() {
  test('parses auth me profile and verification flags', () {
    final profile = HomeProfileModel.fromJson({
      'user': {'name': 'Ahmed'},
      'profile_complete': false,
      'missing_profile_fields': ['phone', 'gender'],
      'email_verified': true,
      'phone_verified': false,
      'verification_notice': {
        'type': 'phone',
        'message': 'Phone verification is pending.',
      },
    });

    expect(profile.name, 'Ahmed');
    expect(profile.profileComplete, isFalse);
    expect(profile.missingProfileFields, ['phone', 'gender']);
    expect(profile.emailVerified, isTrue);
    expect(profile.phoneVerified, isFalse);
    expect(profile.verificationNotice?.type, 'phone');
  });

  test('handles missing optional verification notice', () {
    final profile = HomeProfileModel.fromJson({
      'user': {'name': 'Ahmed'},
      'profile_complete': true,
      'missing_profile_fields': [],
      'email_verified': true,
      'phone_verified': true,
      'verification_notice': null,
    });

    expect(profile.verificationNotice, isNull);
  });

  test('parses upcoming booking server flags without date inference', () {
    final booking = UpcomingBookingModel.fromJson({
      'uuid': 'booking-1',
      'status': 'confirmed',
      'payment_status': 'paid',
      'booking_date': '2026-10-08',
      'start_time': '16:00:00',
      'is_today': true,
      'service_name': 'Haircut',
      'provider_name': 'Provider',
      'branch_name': 'Main branch',
      'employee_name': null,
      'price': 120,
      'currency': 'EGP',
      'latitude': 30.04,
      'longitude': 31.23,
      'can_announce_on_way': true,
      'on_way_announced_at': null,
    });

    expect(booking.isToday, isTrue);
    expect(booking.canAnnounceOnWay, isTrue);
    expect(booking.employeeName, isNull);
  });

  test('keeps on-my-way action available after a successful announcement', () {
    final booking = UpcomingBookingModel.fromJson({
      'uuid': 'booking-1',
      'status': 'confirmed',
      'payment_status': 'paid',
      'booking_date': '2026-10-09',
      'start_time': '16:00:00',
      'is_today': false,
      'service_name': 'Haircut',
      'provider_name': 'Provider',
      'branch_name': 'Main branch',
      'price': 120,
      'currency': 'EGP',
      'can_announce_on_way': true,
      'on_way_announced_at': null,
    });

    final announced = booking.announcedAt(DateTime.utc(2026, 10, 8, 12));
    expect(announced.canAnnounceOnWay, isTrue);
    expect(announced.onWayAnnouncedAt, isNotNull);
  });

  test('parses pending rating item with nullable employee', () {
    final rating = PendingRatingModel.fromJson({
      'booking_uuid': 'booking-1',
      'service_name': 'Haircut',
      'provider_name': 'Provider',
      'branch_name': 'Main branch',
      'employee_name': null,
      'visited_on': '2026-10-07',
    });

    expect(rating.bookingUuid, 'booking-1');
    expect(rating.employeeName, isNull);
    expect(rating.visitedOn, '2026-10-07');
  });

  test('builds the booking rating endpoint with an encoded uuid', () {
    expect(
      HomeApiEndPoints.rateBooking('booking/1'),
      endsWith('/user/bookings/booking%2F1/rate'),
    );
  });

  test('parses waitlist offer and recomputes its remaining time', () {
    final offer = WaitlistOfferModel.fromJson({
      'uuid': 'offer-1',
      'start_at': '2026-10-09T16:00:00+03:00',
      'end_at': '2026-10-09T16:45:00+03:00',
      'provider_name': 'Provider',
      'branch_name': 'Branch',
      'message': 'A slot is available',
      'expires_at': '2026-10-09T15:10:00+03:00',
      'seconds_remaining': 540,
    });

    expect(offer.uuid, 'offer-1');
    expect(offer.remainingAt(DateTime.parse('2026-10-09T15:01:00+03:00')), 540);
    expect(offer.remainingAt(DateTime.parse('2026-10-09T15:11:00+03:00')), 0);
  });

  test('builds the home waitlist offer endpoint', () {
    expect(
      HomeApiEndPoints.waitlistOffer,
      endsWith('/user/home/waitlist-offer'),
    );
  });

  test('parses available-now data and keeps closes_at as plain text', () {
    final provider = AvailableNowModel.fromJson({
      'provider_uuid': 'provider-1',
      'provider_name': 'Provider',
      'branch_uuid': 'branch-1',
      'branch_name': 'Branch',
      'category_uuid': 'category-1',
      'category_name': 'Hospital',
      'logo_path': null,
      'rating': null,
      'rating_count': 31,
      'distance_km': 12.6,
      'closes_at': '23:59:00',
    });

    expect(provider.rating, isNull);
    expect(provider.distanceKm, 12.6);
    expect(provider.closesAt, '23:59:00');
  });

  test('builds the available-now endpoint', () {
    expect(HomeApiEndPoints.availableNow, endsWith('/user/home/available-now'));
  });

  test('parses nearby offers and nullable expiry', () {
    final page = NearbyOffersPageModel.fromJson({
      'data': [
        {
          'provider_uuid': 'provider-1',
          'provider_name': 'Provider',
          'branch_uuid': 'branch-1',
          'branch_name': 'Branch',
          'package_uuid': 'package-1',
          'package_name': 'Package',
          'package_price': '650.00',
          'original_total': '860.00',
          'sessions_included': 4,
          'discount_percentage': 24,
          'savings': 210,
          'days_remaining': null,
        },
      ],
      'meta': {'page': 1, 'has_more': false},
    }, requestedPage: 1);

    expect(page.items.single.packagePrice, 650);
    expect(page.items.single.discountPercentage, 24);
    expect(page.items.single.daysRemaining, isNull);
    expect(page.hasMore, isFalse);
  });

  test('builds the nearby-offers endpoint', () {
    expect(HomeApiEndPoints.nearbyOffers, endsWith('/user/home/nearby-offers'));
  });

  test('parses book-again data and pagination', () {
    final page = BookAgainPageModel.fromJson({
      'data': [
        {
          'booking_uuid': 'booking-1',
          'service_uuid': 'service-1',
          'service_name': 'Haircut',
          'provider_uuid': 'provider-1',
          'provider_name': 'Provider',
          'branch_uuid': 'branch-1',
          'employee_name': 'Employee',
          'last_booked_on': '2026-10-05',
          'price': 120,
          'currency': 'EGP',
        },
      ],
      'meta': {'page': 1, 'has_more': true},
    }, requestedPage: 1);

    expect(page.items.single.serviceUuid, 'service-1');
    expect(page.items.single.branchName, isEmpty);
    expect(page.items.single.lastBookedOn, DateTime(2026, 10, 5));
    expect(page.hasMore, isTrue);
  });

  test('builds the book-again endpoint', () {
    expect(HomeApiEndPoints.bookAgain, endsWith('/user/home/book-again'));
  });

  test('parses top-rated providers with nullable ratings', () {
    final page = TopRatedProvidersPageModel.fromJson({
      'data': [
        {
          'provider_uuid': 'provider-1',
          'provider_name': 'Provider',
          'branch_uuid': 'branch-1',
          'branch_name': 'Branch',
          'category_uuid': 'category-1',
          'category_name': 'Category',
          'rating': null,
          'rating_count': 0,
          'distance_km': 0,
        },
      ],
      'meta': {'page': 1, 'has_more': true},
    }, requestedPage: 1);

    expect(page.items.single.rating, isNull);
    expect(page.items.single.ratingCount, 0);
    expect(page.items.single.distanceKm, 0);
    expect(page.hasMore, isTrue);
  });

  test('builds the top-rated endpoint', () {
    expect(HomeApiEndPoints.topRated, endsWith('/user/home/top-rated'));
  });

  test('parses available-now pagination metadata', () {
    final page = AvailableNowPageModel.fromJson({
      'data': [
        {
          'provider_uuid': 'provider-1',
          'provider_name': 'Provider',
          'branch_uuid': 'branch-1',
          'branch_name': 'Branch',
          'category_uuid': 'category-1',
          'category_name': 'Hospital',
          'rating_count': 0,
          'closes_at': '23:59:00',
        },
      ],
      'meta': {'page': 1, 'has_more': true},
    }, requestedPage: 1);

    expect(page.items, hasLength(1));
    expect(page.page, 1);
    expect(page.hasMore, isTrue);
  });

  test('exposes rating submit states and card', () {
    expect(const HomeRatingSubmitLoadingState(), isA<HomeState>());
    expect(const HomeRatingCard(), isA<HomeRatingCard>());
  });

  test('available-now screen is stateless', () {
    expect(const AvailableNowScreen(), isA<StatelessWidget>());
  });
}
