import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_service.dart';

class WaitlistRemoteService implements WaitlistService {
  final ApiClient _client;

  const WaitlistRemoteService(this._client);

  @override
  Future<Either<Failure, List<WaitlistUiModel>>> list() => _client.get(
    ApiPaths.waitlist,
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map(WaitlistUiModel.fromJson).toList(),
  );

  @override
  Future<Either<Failure, Unit>> cancel(String uuid) =>
      _client.post(ApiPaths.cancelWaitlist(uuid), parse: (_) => unit);

  @override
  Future<Either<Failure, Unit>> accept({
    required String uuid,
    String? offerUuid,
  }) => _client.post(
    ApiPaths.acceptWaitlist(uuid),
    body: {
      if (offerUuid != null && offerUuid.isNotEmpty) 'offer_uuid': offerUuid,
    },
    parse: (_) => unit,
  );

  @override
  Future<Either<Failure, Unit>> requestChange({
    required String uuid,
    required String offerUuid,
    required String note,
  }) => _client.post(
    ApiPaths.requestWaitlistChange(uuid),
    body: {'offer_uuid': offerUuid, 'note': note},
    parse: (_) => unit,
  );

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) => _client.post(
    ApiPaths.waitlistConversation(uuid),
    body: {'message': body},
    parse: (_) => unit,
  );
}
