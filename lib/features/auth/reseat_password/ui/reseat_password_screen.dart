import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/auth_header_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
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
                AuthHeaderWidget(
                  title: context.tr('reseatPassword.title'),
                  description: context.tr('reseatPassword.description'),
                ),
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
