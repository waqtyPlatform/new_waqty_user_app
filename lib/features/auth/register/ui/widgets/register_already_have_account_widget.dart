import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';

class RegisterAlreadyHaveAccountWidget extends StatelessWidget {
  const RegisterAlreadyHaveAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: context.tr('register.haveAccountText'),
              style: AppTextStyles.bodyMdMuted,
            ),
            TextSpan(
              text: context.tr('register.loginText'),
              style: AppTextStyles.label,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.pushNamed(Routes.loginScreen);
                },
            ),
          ],
        ),
      ),
    );
  }
}
