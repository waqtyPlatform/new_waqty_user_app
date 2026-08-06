import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';

class RegisterEmailWidget extends StatelessWidget {
  const RegisterEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      label: context.tr('register.emailText'),
      hintText: context.tr('register.enterEmailText'),
      controller: RegisterCubit.get(context).registerEmailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: (value) => (value == null || value.trim().isEmpty)
          ? context.tr('register.enterEmailText2')
          : null,
    );
  }
}
