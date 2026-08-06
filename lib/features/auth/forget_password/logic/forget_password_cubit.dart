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

  // `selectedFieldNumber` اتشال — التركيز بقى بيتقال بحد باللمسة من
  // `inputDecorationTheme` مش بخلفية خضرا فاتحة.

  Future<void> forgetPassword() async {
    emit(ForgetPasswordLoadingState());

    final result = await _forgetPasswordRepo
        .forgetPassword(
          ForgetPasswordRequestModel(email: forgetPasswordEmailController.text),
        )
        .catchError((error) {
          emit(ForgetPasswordCatchErrorState());
        });

    result.fold(
      (failure) => emit(ForgetPasswordErrorState(message: failure.message)),
      (response) => emit(ForgetPasswordSuccessState(response: response)),
    );
  }

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);
}
