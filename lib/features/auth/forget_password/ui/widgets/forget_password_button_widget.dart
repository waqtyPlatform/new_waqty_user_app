import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';

class ForgetPasswordButtonWidget extends StatelessWidget {
  const ForgetPasswordButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      isLoading: false,
      borderRadius: 999,
      buttonHeight: 52.h,
      buttonText: context.tr("forgetPassword.sendCodeText"),
      backGroundColor: AppColors.greyColor900,
      borderColor: AppColors.greyColor900,
      textStyle: TextStyles.font16whiteColorWeight600,
      onPressed: () {
        validateForgetPassword(context);
      },
    );
  }

  void validateForgetPassword(BuildContext context) {
    final cubit = ForgetPasswordCubit.get(context);
    if (cubit.forgetPasswordKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        Routes.forgetVerifyCodeScreen,
        arguments: {
          'email': cubit.forgetPasswordEmailController.text,
          'method': cubit.recoveryMethod,
        },
      );
    }
  }
}
