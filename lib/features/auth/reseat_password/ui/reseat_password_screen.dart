import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_button_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_confirm_new_password_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_new_password_widget.dart';

class ReseatPasswordScreen extends StatelessWidget {
  final String email;
  final String code;

  const ReseatPasswordScreen({
    required this.email,
    required this.code,
    super.key,
  });

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
            key: ReseatPasswordCubit.get(context).reseatKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(AppSpacing.s16),
                Text(
                  context.tr('reseatPassword.title'),
                  style: AppTextStyles.titleXl,
                ),
                verticalSpace(AppSpacing.s8),
                Text(
                  context.tr('reseatPassword.description'),
                  style: AppTextStyles.bodyMdMuted,
                ),
                verticalSpace(AppSpacing.s32),
                const ReseatNewPasswordWidget(),
                verticalSpace(AppSpacing.s16),
                const ReseatConfirmNewPasswordWidget(),
                verticalSpace(AppSpacing.s32),
                ReseatButtonWidget(email: email, code: code),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
