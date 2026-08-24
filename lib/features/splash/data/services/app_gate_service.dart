import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';

abstract class AppGateService {
  /// [version] و[platform] بيتحسبوا في الـservice مش في الـcubit.
  Future<Either<Failure, AppGateUiModel>> evaluate();

  /// بيسجّل توكن الإشعارات على السيرفر.
  ///
  /// ⚠ **بيتجمّع ومحدش بيقراه.** مفيش `app/Listeners` ولا `EventServiceProvider`
  /// ولا مرسل FCM في الباك-إند. بنبعته عشان يبقى جاهز يوم ما المرسل ينزل —
  /// تكلفته نداء واحد وقت الإقلاع.
  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken);
}
