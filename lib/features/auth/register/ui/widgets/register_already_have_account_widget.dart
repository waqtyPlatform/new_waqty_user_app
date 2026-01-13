import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

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
              text: 'register.haveAccountText'.tr(),
              style: TextStyles.font14greyColor4002Weight400,
            ),
            TextSpan(
              text: 'register.loginText'.tr(),
              style: TextStyles.font14greenColor500Weight600,
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
