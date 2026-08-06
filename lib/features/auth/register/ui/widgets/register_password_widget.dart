import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterPasswordWidget extends StatelessWidget {
  const RegisterPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => current is IsPasswordVisibleState,
      builder: (context, state) {
        final cubit = RegisterCubit.get(context);
        final isHidden = cubit.isPasswordVisibleLogin;

        return AppTextFormField(
          label: context.tr('register.passwordText'),
          hintText: context.tr('register.enterPasswordText'),
          controller: cubit.registerPasswordController,
          obscureText: isHidden,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          suffixIcon: IconButton(
            onPressed: cubit.changePasswordLoginState,
            tooltip: isHidden ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
            icon: Icon(
              isHidden
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppSemanticColors.textTertiary,
            ),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? context.tr('register.enterPasswordText2')
              : null,
        );
      },
    );
  }
}
