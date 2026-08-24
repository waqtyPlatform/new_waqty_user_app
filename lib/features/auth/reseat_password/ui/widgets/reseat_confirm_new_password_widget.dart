import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';

/// تأكيد كلمة السر الجديدة.
///
/// الـ `BlocBuilder` على `IsConfirmNewPasswordVisibleState` اتشال —
/// `AppPasswordFieldWidget` شايل حالة الإظهار جواه.
class ReseatConfirmNewPasswordWidget extends StatelessWidget {
  const ReseatConfirmNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReseatPasswordCubit.get(context);

    return AppFieldWidget(
      label: context.tr('reseatPassword.confirmNewPasswordText'),
      child: AppPasswordFieldWidget(
        hintText: context.tr('reseatPassword.enterConfirmNewPasswordText'),
        controller: cubit.reseatConfirmNewPasswordController,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return context.tr('reseatPassword.confirmPasswordError');
          }
          if (value != cubit.reseatNewPasswordController.text) {
            return context.tr('reseatPassword.passwordMatchError');
          }
          return null;
        },
      ),
    );
  }
}
