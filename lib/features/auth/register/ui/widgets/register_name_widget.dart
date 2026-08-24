import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';

class RegisterNameWidget extends StatelessWidget {
  const RegisterNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFieldWidget(
      label: context.tr('register.nameText'),
      child: AppTextFormField(
        hintText: context.tr('register.enterNameText'),
        controller: RegisterCubit.get(context).registerNameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.tr('register.enterNameText2')
            : null,
      ),
    );
  }
}
