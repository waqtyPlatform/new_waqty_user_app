import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';

class HomeRemoteService implements HomeService {
  final ApiClient _client;

  const HomeRemoteService(this._client);

  @override
  Future<Either<Failure, List<CategoryUiModel>>> categories() => _client.get(
    ApiPaths.categories,
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map(CategoryUiModel.fromJson).toList(),
  );

  @override
  Future<Either<Failure, List<ProviderUiModel>>> providers({
    String? cityUuid,
  }) => _client.get(
    ApiPaths.providers,
    query: {'city_uuid': cityUuid, 'per_page': 15},
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map((json) => ProviderUiModel.fromJson(json)).toList(),
  );

  @override
  Future<Either<Failure, BookingUiModel?>> upcomingBooking() =>
      _firstBooking(const {'upcoming': true, 'per_page': 1});

  @override
  Future<Either<Failure, BookingUiModel?>> lastCompletedBooking() =>
      // ⚠ `status=completed` بيتبعت مع `past` — الفلتر ده على السيرفر مش
      // في الأبلكيشن، عشان `per_page: 1` يرجّع آخر **مكتمل** مش آخر ماضي
      // (اللي ممكن يبقى ملغي).
      _firstBooking(const {
        'past': true,
        'status': 'completed',
        'per_page': 1,
      });

  Future<Either<Failure, BookingUiModel?>> _firstBooking(
    Map<String, dynamic> query,
  ) => _client.get(
    ApiPaths.bookings,
    query: query,
    parse: (envelope) {
      final items = JsonParse.mapListValue(envelope.data);
      return items.isEmpty ? null : BookingUiModel.fromJson(items.first);
    },
  );
}
