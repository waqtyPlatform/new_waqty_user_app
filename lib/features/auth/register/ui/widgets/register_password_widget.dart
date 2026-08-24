import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';

/// حقل كلمة السر في التسجيل.
///
/// الـ `BlocBuilder` على `IsPasswordVisibleState` اتشال —
/// `AppPasswordFieldWidget` شايل حالة الإظهار جواه. التفاصيل في
/// `LoginPasswordWidget`.
class RegisterPasswordWidget extends StatelessWidget {
  const RegisterPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return AppFieldWidget(
      label: context.tr('register.passwordText'),
      child: AppPasswordFieldWidget(
        hintText: context.tr('register.enterPasswordText'),
        controller: cubit.registerPasswordController,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        validator: (value) => (value == null || value.isEmpty)
            ? context.tr('register.enterPasswordText2')
            : null,
      ),
    );
  }
}
