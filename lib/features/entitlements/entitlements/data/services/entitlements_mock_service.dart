import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_service.dart';

class EntitlementsMockService implements EntitlementsService {
  const EntitlementsMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) =>
      result.fold((message) => Left(ServerFailure(message: message)), Right.new);

  @override
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages() async =>
      _lift(await MockSource.fetchList(MockEntitlements.packages));

  @override
  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps() async =>
      _lift(await MockSource.fetchList(MockEntitlements.followUps));

  @override
  Future<Either<Failure, Unit>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }

    // ⚠ **الميعاد اللي راح — الحالة اللي السيرفر مايقدرش يطلّعها عند الطلب.**
    //
    // بين ما العميلة تختار الميعاد وتدوس تأكيد، ممكن حد يخطفه. ده 422
    // حقيقي بيرجع من `PackageBookingService`، والشيت **لازم يفضل مفتوح**
    // برسالة السيرفر عشان ماتضيعش اختيارها.
    if (MockConfig.scenario == MockScenario.slotLostAtConfirm) {
      return const Left(
        ValidationFailure(
          message: 'الميعاد ده اتحجز توّه — اختار ميعاد تاني',
          fields: <String, List<String>>{
            'start_time': <String>['الميعاد ده اتحجز توّه — اختار ميعاد تاني'],
          },
        ),
      );
    }

    return const Right(unit);
  }
}
