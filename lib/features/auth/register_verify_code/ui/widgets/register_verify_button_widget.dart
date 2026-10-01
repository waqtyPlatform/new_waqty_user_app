import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';

class RegisterVerifyButtonWidget extends StatelessWidget {
  final String email;
  const RegisterVerifyButtonWidget({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      isLoading: false,
      borderRadius: 999,
      buttonHeight: 52.h,
      buttonText: context.tr('registerVerifyCode.confirmCodeText'),
      backGroundColor: AppColors.greyColor900,
      borderColor: AppColors.greyColor900,
      textStyle: TextStyles.font16whiteColorWeight600,
      onPressed: () {
        validateVerifyCode(context);
      },
    );
  }

  void validateVerifyCode(BuildContext context) {
    final code = RegisterVerifyCodeCubit.get(context).verifyCodeController.text;
    if (code.length != 4) {
      AppConstant.toast(
        context.tr('registerVerifyCode.codeError'),
        false,
        context,
      );
      return;
    }
    if (RegisterVerifyCodeCubit.get(
      context,
    ).registerVerifyCodeKey.currentState!.validate()) {
      context.pushNamed(Routes.loginScreen);
    }
  }
}
