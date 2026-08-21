import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_service.dart';

class BookingDetailsMockService implements BookingDetailsService {
  const BookingDetailsMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) =>
      result.fold((message) => Left(ServerFailure(message: message)), Right.new);

  @override
  Future<Either<Failure, BookingUiModel>> booking(String bookingUuid) async =>
      _lift(await MockSource.fetch(MockBookings.byUuid(bookingUuid)));

  @override
  Future<Either<Failure, BookingUiModel>> cancel({
    required String bookingUuid,
    required String reason,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockBookings.markCancelled(bookingUuid, reason: reason);
    return _lift(await MockSource.fetch(MockBookings.byUuid(bookingUuid)));
  }

  @override
  Future<Either<Failure, Unit>> rate({
    required String bookingUuid,
    required String bookingItemUuid,
    required int rating,
    String comment = '',
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    return const Right(unit);
  }
}
