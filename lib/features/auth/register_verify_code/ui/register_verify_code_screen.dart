import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_code_text_field_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_verify_button_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_resend_code_widget.dart';

class RegisterVerifyCodeScreen extends StatelessWidget {
  final String email;
  const RegisterVerifyCodeScreen({required this.email, super.key});

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
            key: RegisterVerifyCodeCubit.get(context).registerVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(AppSpacing.s16),
                Text(
                  context.tr('registerVerifyCode.title'),
                  style: AppTextStyles.titleXl,
                ),
                verticalSpace(AppSpacing.s8),
                Text(
                  context.tr('registerVerifyCode.description'),
                  style: AppTextStyles.bodyMdMuted,
                ),
                verticalSpace(AppSpacing.s32),
                RegisterCodeTextFieldWidget(email: email),
                verticalSpace(AppSpacing.s32),
                RegisterResendCodeWidget(email: email),
                verticalSpace(AppSpacing.s32),
                RegisterVerifyButtonWidget(email: email),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
