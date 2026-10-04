abstract class ConfirmPhoneState {}

class ConfirmPhoneInitialState extends ConfirmPhoneState {}

class ConfirmPhoneResendTimerTickState extends ConfirmPhoneState {
  final int remainingSeconds;

  ConfirmPhoneResendTimerTickState({required this.remainingSeconds});
}

class ConfirmPhoneResendTimerFinishedState extends ConfirmPhoneState {}
