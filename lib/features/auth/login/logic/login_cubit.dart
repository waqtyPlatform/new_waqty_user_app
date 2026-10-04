import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/services/firebase_notification_service.dart';
import 'package:waqty_user_application/core/services/google_login_service.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
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
  String loginMethod = 'phone';

  bool get isPhoneLogin => loginMethod == 'phone';

  String get currentLoginValue => isPhoneLogin
      ? (loginCountryCodeController.text.isEmpty
                ? '+20'
                : loginCountryCodeController.text) +
            loginPhoneController.text.trim()
      : loginPhoneController.text.trim();

  void changeLoginMethod(String value) {
    if (loginMethod == value) return;
    loginMethod = value;
    loginPhoneController.clear();
    emit(OnChangeSelectedFieldState());
  }

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
    try {
      final result = await _loginRepo.login(
        LoginRequestModel(
          login: currentLoginValue,
          password: loginPasswordController.text,
        ),
      );

      result.fold(
        (failure) {
          emit(OnLoginErrorState(failure.message));
        },
        (loginResponse) async {
          if (loginResponse.data != null &&
              _isSelectedLoginVerified(loginResponse)) {
            await cashUserData(loginResponse);
          }

          emit(OnLoginSuccessState(loginResponse));
        },
      );
    } catch (_) {
      emit(OnLoginCatchErrorState());
    }
  }

  Future<void> loginWithGoogle() async {
    emit(OnGoogleLoginLoadingState());
    final googleLoginService = getIt<GoogleLoginService>();
    try {
      final credential = await googleLoginService.signIn();
      if (credential == null) {
        emit(InitialState());
        return;
      }

      final firebaseIdToken = await credential.user?.getIdToken(true);

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        await googleLoginService.resetSession();
        emit(OnGoogleLoginCatchErrorState());
        return;
      }

      final result = await _loginRepo.loginWithGoogle(
        idToken: firebaseIdToken,
        fcmToken: await getIt<FirebaseNotificationService>()
            .getCurrentFcmToken(),
        platform: _currentPlatform(),
        deviceId: await _deviceId(),
      );

      await result.fold<Future<void>>(
        (failure) async {
          debugPrint('GOOGLE_LOGIN_ERROR: ${failure.message}');
          await googleLoginService.resetSession();
          emit(OnGoogleLoginErrorState(failure.message));
        },
        (loginResponse) async {
          if (loginResponse.data != null) {
            await cashUserData(loginResponse);
          }

          emit(OnGoogleLoginSuccessState(loginResponse));
        },
      );
    } catch (error) {
      debugPrint('GOOGLE_LOGIN_CATCH_ERROR: $error');
      await googleLoginService.resetSession();
      emit(OnGoogleLoginCatchErrorState());
    }
  }

  Future<void> cashUserData(LoginResponseModel response) async {
    await CacheHelper.setSecuredString(
      ConstantKeys.saveTokenToShared,
      response.data!.token,
    );
  }

  bool _isSelectedLoginVerified(LoginResponseModel response) {
    final user = response.data?.user;
    if (user == null) return false;
    return isPhoneLogin
        ? user.phoneVerifiedAt.isNotEmpty
        : user.emailVerifiedAt.isNotEmpty;
  }

  String _currentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'android';
  }

  Future<String> _deviceId() async {
    final cachedDeviceId = await CacheHelper.getSecuredString(
      ConstantKeys.saveDeviceIdToShared,
    );
    if (cachedDeviceId.isNotEmpty) return cachedDeviceId;

    final random = Random.secure();
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final generated = List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    await CacheHelper.setSecuredString(
      ConstantKeys.saveDeviceIdToShared,
      generated,
    );
    return generated;
  }

  static LoginCubit get(context) => BlocProvider.of(context);
}
