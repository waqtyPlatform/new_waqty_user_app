import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';

abstract class SplashState {}

class InitialState extends SplashState {}

class SplashLoadingState extends SplashState {}

/// معاه توكن — يروح على التبويبات على طول.
class GoToHomeState extends SplashState {}

/// مفيش توكن — يروح على تسجيل الدخول، مش التسجيل الجديد.
/// بعد أول أسبوع، اللي بيرجعوا أكتر من اللي بيسجلوا لأول مرة.
class GoToLoginState extends SplashState {}

/// **الأبلكيشن مايكملش** — صيانة أو تحديث إجباري.
///
/// الحوار غير قابل للإغلاق: مفيش «تخطّي» على حاجز.
class AppGateBlockedState extends SplashState {
  final AppGateUiModel gate;

  AppGateBlockedState({required this.gate});
}
