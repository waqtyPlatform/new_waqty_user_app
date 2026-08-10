import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatButtonWidget extends StatelessWidget {
  final String email;
  final String code;
  const ReseatButtonWidget({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) {
        return current is ResetPasswordLoadingState ||
            current is ResetPasswordSuccessState ||
            current is ResetPasswordErrorState ||
            current is ResetPasswordCatchErrorState;
      },
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          AppConstant.toast(state.response.message, true, context);
          showDialogChangePasswordDone(context);
        } else if (state is ResetPasswordErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is ResetPasswordCatchErrorState) {
          AppConstant.toast(
            context.tr('reseatPassword.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return AppButtonWidget(
          label: context.tr('reseatPassword.newPasswordText2'),
          isLoading: state is ResetPasswordLoadingState,
          onPressed: () => validateResetPassword(email, code, context),
        );
      },
    );
  }

  void validateResetPassword(String email, String code, BuildContext context) {
    if (ReseatPasswordCubit.get(context).reseatKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        ReseatPasswordCubit.get(context).resetPassword(email, code);
      } else {
        AppConstant.toast(
          context.tr('reseatPassword.noInternet'),
          false,
          context,
        );
      }
    }
  }

  /// **[AppDialogWidget] مش `AlertDialog` مكتوب بالإيد.**
  ///
  /// اللي اتشال: `insetPadding` محسوب بالإيد، و`Column` بحشوات
  /// `verticalSpace` متكتوبة، و`Image.asset(doneImage)`.
  ///
  /// صورة الـ«تمام» بقت أيقونة: الـPNG كان أصل براند مالوش مقاس معلن،
  /// وبيتمدّ على عرض الـdialog من غير سقف. أيقونة الكيت (٤٠ نقطة بلون
  /// `accentText`) نفس الرسالة، وبتتبع الوضع الغامق لوحدها — الـPNG لأ.
  static void showDialogChangePasswordDone(BuildContext context) {
    AppDialogWidget.show<void>(
      context,
      barrierDismissible: false,
      icon: Icons.check_circle_rounded,
      title: context.tr('passwordChangedDone.title'),
      message: context.tr('passwordChangedDone.description'),
      actions: (dialogContext) => [
        AppButtonWidget(
          label: context.tr('passwordChangedDone.buttonText'),
          // أربع `pop()` ورا بعض: الـ dialog + إعادة التعيين + الكود +
          // نسيت كلمة السر — يعني بيرجع لشاشة الدخول.
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.pop();
            context.pop();
            context.pop();
          },
        ),
      ],
    );
  }
}
