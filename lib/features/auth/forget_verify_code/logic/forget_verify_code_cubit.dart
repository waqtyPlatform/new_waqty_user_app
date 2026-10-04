import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/models/verify_code_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/repo/forget_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ForgetVerifyCodeCubit extends Cubit<ForgetVerifyCodeState> {
  final ForgetVerifyCodeRepo _forgetVerifyCodeRepo;

  final ForgetPasswordRepo _forgetPasswordRepo;
  ForgetVerifyCodeCubit(this._forgetVerifyCodeRepo, this._forgetPasswordRepo)
    : super(InitialState()) {
    startResendTimer();
  }

  GlobalKey<FormState> forgetVerifyCodeKey = GlobalKey();
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

  void resendCode(String email, {String channel = 'email'}) {
    if (canResend) {
      startResendTimer();
      resendCodeFromServer(email, channel: channel);
    }
  }

  Future<void> resendCodeFromServer(
    String email, {
    String channel = 'email',
  }) async {
    emit(ResendCodeLoadingState());

    try {
      final result = await _forgetPasswordRepo.forgetPassword(
        ForgetPasswordRequestModel(email: email, channel: channel),
      );

      result.fold(
        (failure) => emit(ResendCodeErrorState(message: failure.message)),
        (response) => emit(ResendCodeSuccessState(response: response)),
      );
    } catch (_) {
      emit(ResendCodeCatchErrorState());
    }
  }

  Future<void> verifyCode(String email) async {
    emit(VerifyCodeLoadingState());

    try {
      final result = await _forgetVerifyCodeRepo.verifyCode(
        VerifyCodeRequestModel(email: email, otp: verifyCodeController.text),
      );

      result.fold((failure) {
        if (failure.message.isNotEmpty) {
          emit(VerifyCodeErrorState(message: failure.message));
        } else {
          emit(VerifyCodeCatchErrorState());
        }
      }, (response) => emit(VerifyCodeSuccessState(response: response)));
    } catch (_) {
      emit(VerifyCodeCatchErrorState());
    }
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    verifyCodeController.dispose();
    return super.close();
  }

  static ForgetVerifyCodeCubit get(context) => BlocProvider.of(context);
}
