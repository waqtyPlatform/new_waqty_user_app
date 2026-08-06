import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_email_widget.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // الخلفية والارتفاع ولون الأيقونة كلهم من `appBarTheme` — كانوا
      // متكتوبين بالإيد في أربع شاشات auth بأبيض صريح، وده اللي كان هيطلّع
      // شريط أبيض فوق صفحة سودا في الوضع الغامق.
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.pageGutter.w,
          ),
          child: Form(
            key: ForgetPasswordCubit.get(context).forgetPasswordKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(AppSpacing.s16),
                Text(
                  context.tr("forgetPassword.title"),
                  style: AppTextStyles.titleXl,
                ),
                verticalSpace(AppSpacing.s8),
                Text(
                  context.tr("forgetPassword.description"),
                  style: AppTextStyles.bodyMdMuted,
                ),
                verticalSpace(AppSpacing.s32),
                const ForgetPasswordEmailWidget(),
                verticalSpace(AppSpacing.s32),
                const ForgetPasswordButtonWidget(),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
