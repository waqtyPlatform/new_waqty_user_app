import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_service.dart';

class BookingDetailsRemoteService implements BookingDetailsService {
  final ApiClient _client;

  const BookingDetailsRemoteService(this._client);

  @override
  Future<Either<Failure, BookingUiModel>> booking(String bookingUuid) =>
      _client.get(
        ApiPaths.booking(bookingUuid),
        parse: (envelope) =>
            BookingUiModel.fromJson(JsonParse.mapValue(envelope.data)),
      );

  @override
  Future<Either<Failure, BookingUiModel>> cancel({
    required String bookingUuid,
    required String reason,
  }) => _client.patch(
    ApiPaths.cancelBooking(bookingUuid),
    // السبب اختياري في `CancelBookingRequest` — الفاضي مابيتبعتش أصلاً
    // بدل ما يتخزّن نص فاضي.
    body: {if (reason.isNotEmpty) 'cancellation_reason': reason},
    parse: (envelope) =>
        BookingUiModel.fromJson(JsonParse.mapValue(envelope.data)),
  );

  @override
  Future<Either<Failure, Unit>> rate({
    required String bookingUuid,
    required String bookingItemUuid,
    required int rating,
    String comment = '',
  }) => _client.post(
    ApiPaths.rateBooking(bookingUuid),
    body: {
      'rating': rating,
      if (bookingItemUuid.isNotEmpty) 'booking_item_uuid': bookingItemUuid,
      // `comment` في `StoreBookingRatingRequest` فعلاً (حد ٢٠٠٠ حرف) —
      // التعليق القديم في الـcubit كان بيقول إنه مش في العقد، وده بقى قديم.
      if (comment.isNotEmpty) 'comment': comment,
    },
    parse: (_) => unit,
  );
}
