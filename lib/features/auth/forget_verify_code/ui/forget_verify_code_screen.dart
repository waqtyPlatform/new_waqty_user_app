import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_code_text_field_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_verify_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/resend_code_widget.dart';

class ForgetVerifyCodeScreen extends StatelessWidget {
  final String email;
  const ForgetVerifyCodeScreen({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back, color: AppColors.greyColor900),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: ForgetVerifyCodeCubit.get(context).forgetVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),

                Text(
                  context.tr('verifyCode.title'),

                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  context.tr('verifyCode.description'),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                ForgetCodeTextFieldWidget(email: email),

                verticalSpace(48),
                ResendCodeWidget(email: email),
                verticalSpace(32),
                ForgetVerifyButtonWidget(email: email),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
