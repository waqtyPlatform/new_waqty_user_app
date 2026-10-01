import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/register_verify_code_response_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/models/resend_verification_request_model.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/repo/register_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_state.dart';

class RegisterVerifyCodeCubit extends Cubit<RegisterVerifyCodeState> {
  final bool isSndCodeFrommServer;
  final String email;
  final RegisterVerifyCodeRepo _registerVerifyCodeRepo;

  RegisterVerifyCodeCubit(
    this._registerVerifyCodeRepo,
    this.email,
    this.isSndCodeFrommServer,
  ) : super(InitialState()) {
    ///if the user come from login screen not from register screen send code from server
    if (isSndCodeFrommServer) {
      sendInitialCode(email);
    }
    startResendTimer();
  }

  GlobalKey<FormState> registerVerifyCodeKey = GlobalKey();
  TextEditingController verifyCodeController = TextEditingController();

  int selectedFieldNumber = 0;
  changeSelectedField(int value) {
    selectedFieldNumber = value;
    emit(OnChangeSelectedFieldState());
  }

  /// Resend timer
  Timer? _resendTimer;
  int resendTimerSeconds = 120;
  bool get canResend => resendTimerSeconds == 0;

  String get timerText {
    final minutes = (resendTimerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (resendTimerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startResendTimer() {
    resendTimerSeconds = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimerSeconds > 0) {
        resendTimerSeconds--;
        emit(ResendTimerTickState(remainingSeconds: resendTimerSeconds));
      } else {
        timer.cancel();
        emit(ResendTimerFinishedState());
      }
    });
  }

  /// Called when user taps "Resend Code"
  void resendCode(String email) {
    if (canResend) {
      startResendTimer();
      resendCodeFromServer(email);
    }
  }

  /// Called when screen opens to send the initial verification code
  Future<void> sendInitialCode(String email) async {
    await resendCodeFromServer(email);
  }

  /// Send/Resend verification OTP via the dedicated endpoint
  Future<void> resendCodeFromServer(String email) async {
    emit(ResendCodeLoadingState());
    try {
      final result = await _registerVerifyCodeRepo.resendVerificationCode(
        ResendVerificationRequestModel(email: email),
      );

      result.fold(
        (failure) => emit(ResendCodeErrorState(message: failure.message)),
        (response) => emit(ResendCodeSuccessState(response: response)),
      );
    } catch (_) {
      emit(ResendCodeCatchErrorState());
    }
  }

  /// Verify the OTP code entered by the user
  Future<void> verifyCode(String email) async {
    emit(VerifyCodeLoadingState());

    try {
      final result = await _registerVerifyCodeRepo.verifyCode(
        RegisterVerifyCodeRequestModel(
          email: email,
          otp: verifyCodeController.text,
        ),
      );

      result.fold(
        (failure) {
          if (failure.message.isNotEmpty) {
            emit(VerifyCodeErrorState(message: failure.message));
          } else {
            emit(VerifyCodeCatchErrorState());
          }
        },
        (response) async {
          await cashUserData(response);
          emit(VerifyCodeSuccessState(response: response));
        },
      );
    } catch (_) {
      emit(VerifyCodeCatchErrorState());
    }
  }

  Future<void> cashUserData(RegisterVerifyCodeResponseModel response) async {
    await CacheHelper.setSecuredString(
      ConstantKeys.saveTokenToShared,
      response.data.token,
    );
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    verifyCodeController.dispose();
    return super.close();
  }

  static RegisterVerifyCodeCubit get(context) => BlocProvider.of(context);
}
