import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';

abstract class LoginState {}

class InitialState extends LoginState {}

class IsPasswordVisibleState extends LoginState {}

class OnChangeSelectedFieldState extends LoginState {}

class OnLoginLoadingState extends LoginState {}

class OnLoginSuccessState extends LoginState {
  final LoginResponseModel loginResponseModel;
  OnLoginSuccessState(this.loginResponseModel);
}

class OnLoginErrorState extends LoginState {
  final String error;
  OnLoginErrorState(this.error);
}

class OnLoginCatchErrorState extends LoginState {}
