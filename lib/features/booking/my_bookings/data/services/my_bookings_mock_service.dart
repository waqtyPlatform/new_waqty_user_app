import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_service.dart';

class MyBookingsMockService implements MyBookingsService {
  const MyBookingsMockService();

  @override
  Future<Either<Failure, PaginatedUiModel<BookingUiModel>>> bookings({
    required bool upcoming,
    int page = 1,
    int perPage = 15,
  }) async {
    final result = await MockSource.fetchPage(
      MockBookings.forTab(upcoming: upcoming),
      page: page,
      perPage: perPage,
    );
    return result.fold(
      (message) => Left(ServerFailure(message: message)),
      Right.new,
    );
  }
}
