import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatNewPasswordWidget extends StatelessWidget {
  const ReseatNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) => current is IsNewPasswordVisibleState,
      builder: (context, state) {
        final cubit = ReseatPasswordCubit.get(context);
        final isHidden = cubit.isNewPasswordVisible;

        return AppTextFormField(
          label: context.tr('reseatPassword.newPasswordText'),
          hintText: context.tr('reseatPassword.enterNewPasswordText'),
          controller: cubit.reseatNewPasswordController,
          obscureText: isHidden,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          suffixIcon: IconButton(
            onPressed: cubit.changeNewPasswordLoginState,
            tooltip: isHidden ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
            icon: Icon(
              isHidden
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppSemanticColors.textTertiary,
            ),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? context.tr('reseatPassword.enterNewPasswordText2')
              : null,
        );
      },
    );
  }
}
