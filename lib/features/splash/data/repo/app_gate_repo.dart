import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';
import 'package:waqty_user_application/features/splash/data/services/app_gate_service.dart';

class AppGateRepo extends BaseRepo<AppGateService> {
  const AppGateRepo(super.remote, super.mock);

  /// ⚠ **الفشل بيرجّع بوابة مفتوحة مش خطأ.**
  ///
  /// لو السيرفر مردّش، إحنا **مش متأكدين** إن فيه صيانة. الافتراض بالحاجز
  /// بيقفل الأبلكيشن على كل الناس أول ما الشبكة تتهزهز — والبوابة المفروض
  /// تحمي المستخدم مش تحبسه.
  Future<AppGateUiModel> evaluate() async {
    final result = await guard(() => source.evaluate());
    return result.getOrElse(() => const AppGateUiModel());
  }

  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken) =>
      guard(() => source.registerDeviceToken(fcmToken));
}
