import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_response_model.dart';

abstract class ReseatPasswordState {}

class InitialState extends ReseatPasswordState {}

class IsNewPasswordVisibleState extends ReseatPasswordState {}

class IsConfirmNewPasswordVisibleState extends ReseatPasswordState {}

class OnChangeSelectedFieldState extends ReseatPasswordState {}

class ResetPasswordLoadingState extends ReseatPasswordState {}

class ResetPasswordSuccessState extends ReseatPasswordState {
  final ResetPasswordResponseModel response;
  ResetPasswordSuccessState({required this.response});
}

class ResetPasswordErrorState extends ReseatPasswordState {
  final String message;
  ResetPasswordErrorState({required this.message});
}

class ResetPasswordCatchErrorState extends ReseatPasswordState {}
