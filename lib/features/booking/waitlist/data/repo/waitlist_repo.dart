import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_service.dart';

class WaitlistRepo extends BaseRepo<WaitlistService> {
  const WaitlistRepo(super.remote, super.mock);

  Future<Either<Failure, List<WaitlistUiModel>>> list() =>
      guard(() => source.list());

  Future<Either<Failure, Unit>> cancel(String uuid) =>
      guard(() => source.cancel(uuid));

  Future<Either<Failure, Unit>> accept({
    required String uuid,
    String? offerUuid,
  }) => guard(() => source.accept(uuid: uuid, offerUuid: offerUuid));

  Future<Either<Failure, Unit>> requestChange({
    required String uuid,
    required String offerUuid,
    required String note,
  }) => guard(
    () => source.requestChange(uuid: uuid, offerUuid: offerUuid, note: note),
  );

  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) => guard(() => source.sendMessage(uuid: uuid, body: body));
}
