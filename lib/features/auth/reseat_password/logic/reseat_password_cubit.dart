import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/models/reset_password_request_model.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/repo/reseat_password_repo.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatPasswordCubit extends Cubit<ReseatPasswordState> {
  final ReseatPasswordRepo _reseatPasswordRepo;

  ReseatPasswordCubit(this._reseatPasswordRepo) : super(InitialState());

  GlobalKey<FormState> reseatKey = GlobalKey();
  TextEditingController reseatNewPasswordController = TextEditingController();
  TextEditingController reseatConfirmNewPasswordController =
      TextEditingController();
  int selectedFieldNumber = 0;
  changeSelectedField(int value) {
    selectedFieldNumber = value;
    emit(OnChangeSelectedFieldState());
  }

  bool isNewPasswordVisible = true;

  changeNewPasswordLoginState() {
    isNewPasswordVisible = !isNewPasswordVisible;
    emit(IsNewPasswordVisibleState());
  }

  bool isConfirmNewPasswordVisible = true;

  changeConfirmNewPasswordLoginState() {
    isConfirmNewPasswordVisible = !isConfirmNewPasswordVisible;
    emit(IsConfirmNewPasswordVisibleState());
  }

  Future<void> resetPassword(String email, String otp) async {
    emit(ResetPasswordLoadingState());

    try {
      final result = await _reseatPasswordRepo.resetPassword(
        ResetPasswordRequestModel(
          email: email,
          otp: otp,
          newPassword: reseatNewPasswordController.text,
          newPasswordConfirmation: reseatConfirmNewPasswordController.text,
        ),
      );

      await result.fold<Future<void>>(
        (failure) async {
          if (failure.message.isNotEmpty) {
            emit(ResetPasswordErrorState(message: failure.message));
          } else {
            emit(ResetPasswordCatchErrorState());
          }
        },
        (response) async {
          emit(ResetPasswordSuccessState(response: response));
        },
      );
    } catch (_) {
      emit(ResetPasswordCatchErrorState());
    }
  }

  static ReseatPasswordCubit get(context) => BlocProvider.of(context);
}
