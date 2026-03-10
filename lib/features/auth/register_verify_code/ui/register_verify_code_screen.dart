import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
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
            key: RegisterVerifyCodeCubit.get(context).registerVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),

                Text(
                  context.tr('registerVerifyCode.title'),

                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  context.tr('registerVerifyCode.description'),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                RegisterCodeTextFieldWidget(email: email),

                verticalSpace(48),
                RegisterResendCodeWidget(email: email),
                verticalSpace(32),
                RegisterVerifyButtonWidget(email: email),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
