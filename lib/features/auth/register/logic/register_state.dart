import 'package:waqty_user_application/features/auth/register/data/models/register_response_model.dart';

abstract class RegisterState {}

class InitialState extends RegisterState {}

class OnChangeSelectedFieldState extends RegisterState {}

class IsPasswordVisibleState extends RegisterState {}

class OnRegisterLoadingState extends RegisterState {}

class OnRegisterSuccessState extends RegisterState {
  final RegisterResponseModel registerResponseModel;

  OnRegisterSuccessState(this.registerResponseModel);
}

class OnRegisterErrorState extends RegisterState {
  final String message;

  OnRegisterErrorState(this.message);
}

class OnRegisterCatchErrorState extends RegisterState {}

class OnChangeGenderState extends RegisterState {}

class OnChangeBirthDateState extends RegisterState {}
