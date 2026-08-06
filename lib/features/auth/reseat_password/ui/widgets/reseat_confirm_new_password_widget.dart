import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatConfirmNewPasswordWidget extends StatelessWidget {
  const ReseatConfirmNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) =>
          current is IsConfirmNewPasswordVisibleState,
      builder: (context, state) {
        final cubit = ReseatPasswordCubit.get(context);
        final isHidden = cubit.isConfirmNewPasswordVisible;

        return AppTextFormField(
          label: context.tr('reseatPassword.confirmNewPasswordText'),
          hintText: context.tr('reseatPassword.enterConfirmNewPasswordText'),
          controller: cubit.reseatConfirmNewPasswordController,
          obscureText: isHidden,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            onPressed: cubit.changeConfirmNewPasswordLoginState,
            tooltip: isHidden ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
            icon: Icon(
              isHidden
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppSemanticColors.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.tr('reseatPassword.confirmPasswordError');
            }
            if (value != cubit.reseatNewPasswordController.text) {
              return context.tr('reseatPassword.passwordMatchError');
            }
            return null;
          },
        );
      },
    );
  }
}
