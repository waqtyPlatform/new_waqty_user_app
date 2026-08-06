import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.pageGutter.w,
          ),
          child: Form(
            key: ForgetVerifyCodeCubit.get(context).forgetVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(AppSpacing.s16),
                Text(
                  context.tr('verifyCode.title'),
                  style: AppTextStyles.titleXl,
                ),
                verticalSpace(AppSpacing.s8),
                Text(
                  context.tr('verifyCode.description'),
                  style: AppTextStyles.bodyMdMuted,
                ),
                verticalSpace(AppSpacing.s32),
                ForgetCodeTextFieldWidget(email: email),
                verticalSpace(AppSpacing.s32),
                ResendCodeWidget(email: email),
                verticalSpace(AppSpacing.s32),
                ForgetVerifyButtonWidget(email: email),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
