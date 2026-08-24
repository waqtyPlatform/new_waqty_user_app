import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';

abstract class MyBookingsService {
  /// [upcoming] بيتحوّل لفلتر `upcoming` أو `past` على السيرفر —
  /// **مش فلتر في الأبلكيشن**، عشان التقسيم يبقى صح.
  Future<Either<Failure, PaginatedUiModel<BookingUiModel>>> bookings({
    required bool upcoming,
    int page = 1,
    int perPage = 15,
  });
}
