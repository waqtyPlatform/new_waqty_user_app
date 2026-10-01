import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';

class ForgetVerifyButtonWidget extends StatelessWidget {
  final String email;
  const ForgetVerifyButtonWidget({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      isLoading: false,
      borderRadius: 999,
      buttonHeight: 52.h,
      buttonText: context.tr('verifyCode.confirmCodeText'),
      backGroundColor: AppColors.greyColor900,
      borderColor: AppColors.greyColor900,
      textStyle: TextStyles.font16whiteColorWeight600,
      onPressed: () {
        validateVerifyCode(context);
      },
    );
  }

  void validateVerifyCode(BuildContext context) {
    final code = ForgetVerifyCodeCubit.get(context).verifyCodeController.text;
    if (code.length != 4) {
      AppConstant.toast(context.tr('verifyCode.codeError'), false, context);
      return;
    }
    if (ForgetVerifyCodeCubit.get(
      context,
    ).forgetVerifyCodeKey.currentState!.validate()) {
      context.pushNamed(
        Routes.reseatPasswordScreen,
        arguments: {'email': email, 'code': code},
      );
    }
  }
}
