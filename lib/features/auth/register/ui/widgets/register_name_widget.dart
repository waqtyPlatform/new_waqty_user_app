import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';

class RegisterNameWidget extends StatelessWidget {
  const RegisterNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      label: context.tr('register.nameText'),
      hintText: context.tr('register.enterNameText'),
      controller: RegisterCubit.get(context).registerNameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      validator: (value) => (value == null || value.trim().isEmpty)
          ? context.tr('register.enterNameText2')
          : null,
    );
  }
}
