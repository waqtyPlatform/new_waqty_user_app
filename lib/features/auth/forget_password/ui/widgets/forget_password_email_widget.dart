import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';

class ForgetPasswordEmailWidget extends StatelessWidget {
  const ForgetPasswordEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      label: context.tr("forgetPassword.emailText"),
      hintText: context.tr('forgetPassword.enterEmailText'),
      controller:
          ForgetPasswordCubit.get(context).forgetPasswordEmailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      validator: (value) => (value == null || value.trim().isEmpty)
          ? context.tr('forgetPassword.enterEmailText2')
          : null,
    );
  }
}
