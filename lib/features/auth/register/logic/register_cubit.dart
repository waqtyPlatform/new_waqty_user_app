import 'dart:math';

import 'package:easy_localization/easy_localization.dart' as context;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/services/firebase_notification_service.dart';
import 'package:waqty_user_application/core/services/google_login_service.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/register/data/models/register_request_model.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _registerRepo;

  RegisterCubit(this._registerRepo) : super(InitialState());

  GlobalKey<FormState> registerKey = GlobalKey();
  TextEditingController registerNameController = TextEditingController();
  TextEditingController registerEmailController = TextEditingController();
  TextEditingController registerCountryCodeController = TextEditingController();
  TextEditingController registerPhoneController = TextEditingController();
  TextEditingController registerPasswordController = TextEditingController();
  TextEditingController registerBirthDateController = TextEditingController();
  String? socialProvider;
  String? socialIdToken;

  GenderItem selectedGender = GenderItem(
    value: 'male',
    name: context.tr('register.maleText'),
  );

  changeGender(GenderItem value) {
    selectedGender = value;
    emit(OnChangeGenderState());
  }

  changeBirthDate(String value) {
    registerBirthDateController.text = value;
    emit(OnChangeBirthDateState());
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

  Future<void> register({required String otpChannel}) async {
    emit(OnRegisterLoadingState());
    try {
      final result = await _registerRepo.register(
        RegisterRequestModel(
          name: registerNameController.text.trim(),
          email: registerEmailController.text.trim(),
          phone: _phoneWithCountryCode(),
          dateBirth: registerBirthDateController.text,
          gender: selectedGender.value,
          password: registerPasswordController.text,
          countryIso2: 'EG',
          otpChannel: otpChannel,
          fcmToken: await getIt<FirebaseNotificationService>()
              .getCurrentFcmToken(),
          platform: _currentPlatform(),
          deviceId: await _deviceId(),
        ),
      );

      result.fold(
        (failure) {
          emit(OnRegisterErrorState(failure.message));
        },
        (registerResponse) {
          emit(OnRegisterSuccessState(registerResponse));
        },
      );
    } catch (_) {
      emit(OnRegisterCatchErrorState());
    }
  }

  Future<void> fillRegisterWithGoogle() async {
    final credential = await getIt<GoogleLoginService>().signIn();
    final user = credential?.user;
    if (user == null) return;

    final name = user.displayName?.trim() ?? '';
    final email = user.email?.trim() ?? '';
    if (name.isNotEmpty) registerNameController.text = name;
    if (email.isNotEmpty) registerEmailController.text = email;
    socialProvider = 'google';
    socialIdToken = await user.getIdToken(true);
    emit(OnChangeSelectedFieldState());
  }

  void fillFromSocialUser(dynamic user) {
    if (user is! UserModel) return;
    if (user.name.trim().isNotEmpty) registerNameController.text = user.name;
    if (user.email.trim().isNotEmpty) {
      registerEmailController.text = user.email;
    }
    if (user.phone.trim().isNotEmpty) {
      registerPhoneController.text = user.phone;
    }
  }

  String _currentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'android';
  }

  String _phoneWithCountryCode() {
    final phone = registerPhoneController.text.trim();
    if (phone.isEmpty) return '';
    return (registerCountryCodeController.text.isEmpty
            ? '+20'
            : registerCountryCodeController.text) +
        phone;
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

  static RegisterCubit get(context) => BlocProvider.of(context);
}
