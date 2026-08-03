import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

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
              style: TextStyles.font14greyColor4002Weight400,
            ),
            TextSpan(
              text: context.tr('login.registerNowText'),
              style: TextStyles.font14greenColor500Weight600,
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
