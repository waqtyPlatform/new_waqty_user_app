import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';

class LoginDonNotAlreadyHaveAccountWidget extends StatelessWidget {
  const LoginDonNotAlreadyHaveAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: context.tr('login.noAccountText'),
              style: AppTextStyles.bodyMdMuted,
            ),
            TextSpan(
              text: context.tr('login.registerNowText'),
              style: AppTextStyles.label,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // كان `pop()` — بيفترض إن Login اتفتحت من Register.
                  // بعد تسجيل الخروج الـ stack بيتمسح فـ Login بتبقى الجذر،
                  // والـ pop ساعتها بيدي **شاشة بيضا**.
                  context.pushReplacementNamed(Routes.registerScreen);
                },
            ),
          ],
        ),
      ),
    );
  }
}
