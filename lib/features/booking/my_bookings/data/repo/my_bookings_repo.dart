import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_service.dart';

class MyBookingsRepo extends BaseRepo<MyBookingsService> {
  const MyBookingsRepo(super.remote, super.mock);

  Future<Either<Failure, PaginatedUiModel<BookingUiModel>>> bookings({
    required bool upcoming,
    int page = 1,
    int perPage = 15,
  }) => guard(
    () => source.bookings(upcoming: upcoming, page: page, perPage: perPage),
  );
}
