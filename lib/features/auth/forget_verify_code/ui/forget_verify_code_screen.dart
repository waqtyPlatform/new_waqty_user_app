import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_code_text_field_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_verify_button_widget.dart';

class ForgetVerifyCodeScreen extends StatelessWidget {
  const ForgetVerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: ForgetVerifyCodeCubit.get(context).forgetVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.greyColor900,
                    size: 24.r,
                  ),
                ),
                verticalSpace(24),

                Text(
                  'verifyCode.title'.tr(),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  'verifyCode.description'.tr(),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                ForgetCodeTextFieldWidget(),
                verticalSpace(48),
                Center(
                  child: Text(
                    'verifyCode.resendCodeSecondsText'.tr(),
                    style: TextStyles.font14greyColor4002Weight400,
                  ),
                ),
                verticalSpace(6),
                Center(
                  child: Text(
                    'verifyCode.resendCodeText'.tr(),
                    style: TextStyles.font14greenColor500Weight600,
                  ),
                ),
                verticalSpace(60),
                ForgetVerifyButtonWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
