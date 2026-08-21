import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';
import 'package:waqty_user_application/features/splash/data/services/app_gate_service.dart';

/// البوابة في الوضع الوهمي **دايمًا مفتوحة**.
///
/// السيناريوهات مالهاش حالة صيانة ولا تحديث إجباري — الاتنين حاجز بيقفل
/// الأبلكيشن، وحد بيراجع تصميم مش محتاج يتحاصر. لو احتجنا نراجع الحاجز
/// نفسه، بيتزوّد سيناريو مخصّص.
class AppGateMockService implements AppGateService {
  const AppGateMockService();

  @override
  Future<Either<Failure, AppGateUiModel>> evaluate() async =>
      const Right(AppGateUiModel());

  @override
  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken) async =>
      const Right(unit);
}
