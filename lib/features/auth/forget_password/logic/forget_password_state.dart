import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_response_model.dart';

abstract class ForgetPasswordState {}

class InitialState extends ForgetPasswordState {}

class ForgetPasswordInitialState extends ForgetPasswordState {}

class ForgetPasswordLoadingState extends ForgetPasswordState {}

class ForgetPasswordSuccessState extends ForgetPasswordState {
  final ForgetPasswordResponseModel response;
  ForgetPasswordSuccessState({required this.response});
}

class ForgetPasswordErrorState extends ForgetPasswordState {
  final String message;
  ForgetPasswordErrorState({required this.message});
}

class ForgetPasswordCatchErrorState extends ForgetPasswordState {}

class OnChangeSelectedFieldState extends ForgetPasswordState {}
