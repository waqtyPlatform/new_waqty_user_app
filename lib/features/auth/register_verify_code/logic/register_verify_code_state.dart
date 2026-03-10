import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_response_model.dart';

abstract class RegisterVerifyCodeState {}

class InitialState extends RegisterVerifyCodeState {}

class VerifyCodeLoadingState extends RegisterVerifyCodeState {}

class VerifyCodeSuccessState extends RegisterVerifyCodeState {
  final RegisterVerifyCodeResponseModel response;
  VerifyCodeSuccessState({required this.response});
}

class VerifyCodeErrorState extends RegisterVerifyCodeState {
  final String message;
  VerifyCodeErrorState({required this.message});
}

class VerifyCodeCatchErrorState extends RegisterVerifyCodeState {}

class OnChangeSelectedFieldState extends RegisterVerifyCodeState {}

class ResendTimerTickState extends RegisterVerifyCodeState {
  final int remainingSeconds;
  ResendTimerTickState({required this.remainingSeconds});
}

class ResendTimerFinishedState extends RegisterVerifyCodeState {}

class ResendCodeLoadingState extends RegisterVerifyCodeState {}

class ResendCodeSuccessState extends RegisterVerifyCodeState {
  final ResendVerificationResponseModel response;
  ResendCodeSuccessState({required this.response});
}

class ResendCodeErrorState extends RegisterVerifyCodeState {
  final String message;
  ResendCodeErrorState({required this.message});
}

class ResendCodeCatchErrorState extends RegisterVerifyCodeState {}
