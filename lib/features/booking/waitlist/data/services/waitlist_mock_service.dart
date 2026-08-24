import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_service.dart';

/// ⚠ **بيفضل للأبد.** `waitlistOffered` و`waitlistExpired` حالات بمهلة
/// ٥ دقايق — مراجعتها على سيرفر حقيقي معناها إن حد يقعد يستنى.
class WaitlistMockService implements WaitlistService {
  const WaitlistMockService();

  @override
  Future<Either<Failure, List<WaitlistUiModel>>> list() async {
    await Future.delayed(MockConfig.effectiveDelay);
    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }
    return Right(MockWaitlist.forUser(DateTime.now()));
  }

  @override
  Future<Either<Failure, Unit>> cancel(String uuid) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockWaitlist.cancel(uuid);
    MockWaitlist.removeByUuid(uuid);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> accept({
    required String uuid,
    String? offerUuid,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockWaitlist.accept(uuid);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> requestChange({
    required String uuid,
    required String offerUuid,
    required String note,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockWaitlist.requestChange(uuid, note);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockWaitlist.sendMessage(uuid, body);
    return const Right(unit);
  }
}
