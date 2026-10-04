import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/models/forget_password_request_model.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepo _forgetPasswordRepo;

  ForgetPasswordCubit(this._forgetPasswordRepo) : super(InitialState());

  GlobalKey<FormState> forgetPasswordKey = GlobalKey();
  TextEditingController forgetPasswordEmailController = TextEditingController();
  String recoveryMethod = 'email';

  bool get isEmailRecovery => recoveryMethod == 'email';

  String get selectedChannel => isEmailRecovery ? 'email' : 'whatsapp';

  int selectedFieldNumber = 0;
  changeSelectedField(int value) {
    selectedFieldNumber = value;
    emit(OnChangeSelectedFieldState());
  }

  void changeRecoveryMethod(String value) {
    if (recoveryMethod == value) return;
    recoveryMethod = value;
    forgetPasswordEmailController.clear();
    emit(OnChangeSelectedFieldState());
  }

  Future<void> forgetPassword() async {
    emit(ForgetPasswordLoadingState());

    try {
      final result = await _forgetPasswordRepo.forgetPassword(
        ForgetPasswordRequestModel(
          email: forgetPasswordEmailController.text.trim(),
          channel: selectedChannel,
        ),
      );

      result.fold(
        (failure) => emit(ForgetPasswordErrorState(message: failure.message)),
        (response) => emit(ForgetPasswordSuccessState(response: response)),
      );
    } catch (_) {
      emit(ForgetPasswordCatchErrorState());
    }
  }

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);
}
