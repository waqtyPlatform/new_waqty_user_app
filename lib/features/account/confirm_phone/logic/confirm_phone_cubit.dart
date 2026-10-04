import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/confirm_phone/logic/confirm_phone_state.dart';

class ConfirmPhoneCubit extends Cubit<ConfirmPhoneState> {
  ConfirmPhoneCubit() : super(ConfirmPhoneInitialState());

  final TextEditingController otpController = TextEditingController(
    text: '7391',
  );
  Timer? _resendTimer;
  int resendTimerSeconds = 120;
  bool get canResend => resendTimerSeconds == 0;

  String get resendTime {
    final minutes = (resendTimerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (resendTimerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startResendTimer() {
    resendTimerSeconds = 120;
    _resendTimer?.cancel();
    emit(
      ConfirmPhoneResendTimerTickState(remainingSeconds: resendTimerSeconds),
    );
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimerSeconds > 0) {
        resendTimerSeconds--;
        emit(
          ConfirmPhoneResendTimerTickState(
            remainingSeconds: resendTimerSeconds,
          ),
        );
      } else {
        timer.cancel();
        emit(ConfirmPhoneResendTimerFinishedState());
      }
    });
  }

  void resendCode() {
    if (!canResend) return;
    startResendTimer();
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    otpController.dispose();
    return super.close();
  }

  static ConfirmPhoneCubit get(context) => BlocProvider.of(context);
}
