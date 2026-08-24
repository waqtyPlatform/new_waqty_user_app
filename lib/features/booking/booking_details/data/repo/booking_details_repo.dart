import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_service.dart';

class BookingDetailsRepo extends BaseRepo<BookingDetailsService> {
  const BookingDetailsRepo(super.remote, super.mock);

  Future<Either<Failure, BookingUiModel>> booking(String bookingUuid) =>
      guard(() => source.booking(bookingUuid));

  Future<Either<Failure, BookingUiModel>> cancel({
    required String bookingUuid,
    required String reason,
  }) => guard(() => source.cancel(bookingUuid: bookingUuid, reason: reason));

  Future<Either<Failure, Unit>> rate({
    required String bookingUuid,
    required String bookingItemUuid,
    required int rating,
    String comment = '',
  }) => guard(
    () => source.rate(
      bookingUuid: bookingUuid,
      bookingItemUuid: bookingItemUuid,
      rating: rating,
      comment: comment,
    ),
  );
}
