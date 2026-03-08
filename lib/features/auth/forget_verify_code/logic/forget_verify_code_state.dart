import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_response_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_response_model.dart';

abstract class ForgetVerifyCodeState {}

class InitialState extends ForgetVerifyCodeState {}

class VerifyCodeLoadingState extends ForgetVerifyCodeState {}

class VerifyCodeSuccessState extends ForgetVerifyCodeState {
  final VerifyCodeResponseModel response;
  VerifyCodeSuccessState({required this.response});
}

class VerifyCodeErrorState extends ForgetVerifyCodeState {
  final String message;
  VerifyCodeErrorState({required this.message});
}

class VerifyCodeCatchErrorState extends ForgetVerifyCodeState {}

class OnChangeSelectedFieldState extends ForgetVerifyCodeState {}

class ResendTimerTickState extends ForgetVerifyCodeState {
  final int remainingSeconds;
  ResendTimerTickState({required this.remainingSeconds});
}

class ResendTimerFinishedState extends ForgetVerifyCodeState {}

class ResendCodeLoadingState extends ForgetVerifyCodeState {}

class ResendCodeSuccessState extends ForgetVerifyCodeState {
  final ForgetPasswordResponseModel response;
  ResendCodeSuccessState({required this.response});
}

class ResendCodeErrorState extends ForgetVerifyCodeState {
  final String message;
  ResendCodeErrorState({required this.message});
}

class ResendCodeCatchErrorState extends ForgetVerifyCodeState {}
