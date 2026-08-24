import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_service.dart';

class ReassignmentRepo extends BaseRepo<ReassignmentService> {
  const ReassignmentRepo(super.remote, super.mock);

  Future<Either<Failure, List<ReassignmentUiModel>>> list() =>
      guard(() => source.list());

  Future<Either<Failure, ReassignmentUiModel>> detail(String uuid) =>
      guard(() => source.detail(uuid));

  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) => guard(() => source.sendMessage(uuid: uuid, body: body));

  Future<Either<Failure, Unit>> acceptProposal(String proposalUuid) =>
      guard(() => source.acceptProposal(proposalUuid));

  Future<Either<Failure, Unit>> requestChange({
    required String proposalUuid,
    required String note,
  }) => guard(
    () => source.requestChange(proposalUuid: proposalUuid, note: note),
  );

  Future<Either<Failure, Unit>> cancelProposal(String proposalUuid) =>
      guard(() => source.cancelProposal(proposalUuid));
}
