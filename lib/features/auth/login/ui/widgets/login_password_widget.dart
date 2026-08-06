import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';

/// حقل كلمة السر.
///
/// الـ `BlocBuilder` هنا **لسه له لزمة** — بيتفرّج على إظهار/إخفاء الحروف
/// بس. اللي اتشال هو الاشتراك في حالة «الحقل المركّز» اللي كانت بتلوّن
/// الخلفية؛ التركيز بقى بيتقال بالحد من الثيم.
class LoginPasswordWidget extends StatelessWidget {
  const LoginPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => current is IsPasswordVisibleState,
      builder: (context, state) {
        final cubit = LoginCubit.get(context);
        final isHidden = cubit.isPasswordVisibleLogin;

        return AppTextFormField(
          label: context.tr("login.passwordText"),
          hintText: context.tr('login.enterPasswordText'),
          controller: cubit.loginPasswordController,
          obscureText: isHidden,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
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
              ? context.tr('login.enterPasswordText2')
              : null,
        );
      },
    );
  }
}
