import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_reassignments.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_service.dart';

class ReassignmentMockService implements ReassignmentService {
  const ReassignmentMockService();

  @override
  Future<Either<Failure, List<ReassignmentUiModel>>> list() async {
    await Future.delayed(MockConfig.effectiveDelay);
    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }
    return Right(MockReassignments.forUser(DateTime.now()));
  }

  @override
  Future<Either<Failure, ReassignmentUiModel>> detail(String uuid) async {
    await Future.delayed(MockConfig.effectiveDelay);
    final entry = MockReassignments.byUuid(uuid, DateTime.now());
    return entry == null
        ? const Left(ServerFailure(message: 'الطلب مش موجود'))
        : Right(entry);
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockReassignments.sendMessage(uuid, body);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> acceptProposal(String proposalUuid) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockReassignments.accept(proposalUuid);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> requestChange({
    required String proposalUuid,
    required String note,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockReassignments.requestChange(proposalUuid, note);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> cancelProposal(String proposalUuid) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockReassignments.cancel(proposalUuid);
    return const Right(unit);
  }
}
