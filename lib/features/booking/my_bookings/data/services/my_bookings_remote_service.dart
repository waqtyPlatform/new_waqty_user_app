import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_service.dart';

class MyBookingsRemoteService implements MyBookingsService {
  final ApiClient _client;

  const MyBookingsRemoteService(this._client);

  @override
  Future<Either<Failure, PaginatedUiModel<BookingUiModel>>> bookings({
    required bool upcoming,
    int page = 1,
    int perPage = 15,
  }) => _client.get(
    ApiPaths.bookings,
    // ⚠ الفلتر بيتبعت بمفتاح واحد بس: `upcoming=true` **أو** `past=true`.
    // `UserBookingIndexRequest` بيقرا الاتنين، ولو اتبعتوا مع بعض النتيجة
    // بتبقى مجموعة فاضية.
    query: {
      if (upcoming) 'upcoming': true else 'past': true,
      'page': page,
      'per_page': perPage,
    },
    parse: (envelope) => PaginatedUiModel<BookingUiModel>.fromJson(
      {'data': envelope.data, 'meta': envelope.meta},
      BookingUiModel.fromJson,
    ),
  );
}
