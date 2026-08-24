import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';

/// كلمة السر الجديدة.
///
/// الـ `BlocBuilder` على `IsNewPasswordVisibleState` اتشال —
/// `AppPasswordFieldWidget` شايل حالة الإظهار جواه.
class ReseatNewPasswordWidget extends StatelessWidget {
  const ReseatNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReseatPasswordCubit.get(context);

    return AppFieldWidget(
      label: context.tr('reseatPassword.newPasswordText'),
      child: AppPasswordFieldWidget(
        hintText: context.tr('reseatPassword.enterNewPasswordText'),
        controller: cubit.reseatNewPasswordController,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.newPassword],
        validator: (value) => (value == null || value.isEmpty)
            ? context.tr('reseatPassword.enterNewPasswordText2')
            : null,
      ),
    );
  }
}
