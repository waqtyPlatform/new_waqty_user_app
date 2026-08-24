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
  // `selectedFieldNumber` اتشال — التركيز بقى بيتقال بحد باللمسة من
  // `inputDecorationTheme` مش بخلفية خضرا فاتحة.

  // **حالة إظهار كلمة السر اتشالت من هنا.**
  //
  // كانت `bool` + دالة + `State` في تلات cubits — تسع أعضاء كل
  // شغلهم يقلبوا أيقونة عين. `AppPasswordFieldWidget` بتاع الكيت
  // شايلها جواه، فضغطة العين بقت تبني الحقل بس بدل ما تبني الشاشة
  // كلها (٦ حقول في التسجيل).

  Future<void> resetPassword(String email, String otp) async {
    emit(ResetPasswordLoadingState());

    final result = await _reseatPasswordRepo
        .resetPassword(
          ResetPasswordRequestModel(
            email: email,
            otp: otp,
            newPassword: reseatNewPasswordController.text,
            newPasswordConfirmation: reseatConfirmNewPasswordController.text,
          ),
        )
        .catchError((error) {
          emit(ResetPasswordCatchErrorState());
        });

    result.fold((failure) {
      if (failure.message.isNotEmpty) {
        emit(ResetPasswordErrorState(message: failure.message));
      } else {
        emit(ResetPasswordCatchErrorState());
      }
    }, (response) => emit(ResetPasswordSuccessState(response: response)));
  }

  static ReseatPasswordCubit get(context) => BlocProvider.of(context);
}
