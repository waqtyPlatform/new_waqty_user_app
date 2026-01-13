import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/login/logic/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(InitialState());

  GlobalKey<FormState> loginKey = GlobalKey();
  TextEditingController loginCountryCodeController = TextEditingController();
  TextEditingController loginPhoneController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool isPasswordVisibleLogin = true;

  changePasswordLoginState() {
    isPasswordVisibleLogin = !isPasswordVisibleLogin;
    emit(IsPasswordVisibleState());
  }

  static LoginCubit get(context) => BlocProvider.of(context);
}
