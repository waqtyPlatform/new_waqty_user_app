import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_request_model.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(InitialState());

  GlobalKey<FormState> loginKey = GlobalKey();
  TextEditingController loginCountryCodeController = TextEditingController();
  TextEditingController loginPhoneController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  int selectedFieldNumber = 0;
  changeSelectedField(int value) {
    selectedFieldNumber = value;
    emit(OnChangeSelectedFieldState());
  }

  bool isPasswordVisibleLogin = true;

  changePasswordLoginState() {
    isPasswordVisibleLogin = !isPasswordVisibleLogin;
    emit(IsPasswordVisibleState());
  }

  Future<void> login() async {
    emit(OnLoginLoadingState());
    final result = await _loginRepo
        .login(
          LoginRequestModel(
            login:
                (loginCountryCodeController.text.isEmpty
                    ? '+20'
                    : loginCountryCodeController.text) +
                loginPhoneController.text.trim(),
            password: loginPasswordController.text,
          ),
        )
        .catchError((error) {
          emit(OnLoginCatchErrorState());
        });

    result.fold(
      (failure) {
        emit(OnLoginErrorState(failure.message));
      },
      (loginResponse) async {
        await cashUserData(loginResponse);
        emit(OnLoginSuccessState(loginResponse));
      },
    );
  }

  Future<void> cashUserData(LoginResponseModel response) async {
    await CacheHelper.setSecuredString(
      ConstantKeys.saveTokenToShared,
      response.data.token,
    );
  }

  static LoginCubit get(context) => BlocProvider.of(context);
}
