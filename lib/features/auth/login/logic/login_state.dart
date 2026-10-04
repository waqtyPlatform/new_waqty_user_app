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

class OnGoogleLoginLoadingState extends LoginState {}

class OnGoogleLoginSuccessState extends LoginState {
  final LoginResponseModel loginResponseModel;
  OnGoogleLoginSuccessState(this.loginResponseModel);
}

class OnGoogleLoginErrorState extends LoginState {
  final String error;
  OnGoogleLoginErrorState(this.error);
}

class OnGoogleLoginCatchErrorState extends LoginState {}

class OnAppleLoginLoadingState extends LoginState {}

class OnAppleLoginSuccessState extends LoginState {
  final LoginResponseModel loginResponseModel;
  OnAppleLoginSuccessState(this.loginResponseModel);
}

class OnAppleLoginErrorState extends LoginState {
  final String error;
  OnAppleLoginErrorState(this.error);
}

class OnLoginErrorState extends LoginState {
  final String error;
  OnLoginErrorState(this.error);
}

class OnLoginCatchErrorState extends LoginState {}

class OnAppleLoginCatchErrorState extends LoginState {}
