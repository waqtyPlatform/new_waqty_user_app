import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/features/home/home/data/models/home_profile_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/upcoming_booking_model.dart';
import 'package:waqty_user_application/features/home/home/data/models/pending_rating_model.dart';

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
}
