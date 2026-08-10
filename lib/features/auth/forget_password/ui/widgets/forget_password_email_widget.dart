import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';

class ForgetPasswordEmailWidget extends StatelessWidget {
  const ForgetPasswordEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFieldWidget(
      label: context.tr("forgetPassword.emailText"),
      child: AppTextFormField(
        hintText: context.tr('forgetPassword.enterEmailText'),
        controller: ForgetPasswordCubit.get(
          context,
        ).forgetPasswordEmailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.email],
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.tr('forgetPassword.enterEmailText2')
            : null,
      ),
    );
  }
}
