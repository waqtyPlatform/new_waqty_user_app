import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_email_widget.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

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
            key: ForgetPasswordCubit.get(context).forgetPasswordKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),

                Text(
                  context.tr("forgetPassword.title"),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  context.tr("forgetPassword.description"),

                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  context.tr("forgetPassword.emailText"),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                ForgetPasswordEmailWidget(),
                verticalSpace(54),
                ForgetPasswordButtonWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
