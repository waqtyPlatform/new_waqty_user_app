import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

class RegisterTermsAndConditionsWidget extends StatelessWidget {
  const RegisterTermsAndConditionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: context.tr('register.accptedWithText'),
              style: AppTextStyles.caption,
            ),
            TextSpan(
              text: context.tr('register.termsAndConditionsText'),
              style: AppTextStyles.captionAccent,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO(nav): شاشة الشروط والأحكام لسه مش موجودة.
                },
            ),
            TextSpan(text: ' و ', style: AppTextStyles.caption),
            TextSpan(
              text: context.tr('register.privacyPolicyText'),
              style: AppTextStyles.captionAccent,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO(nav): شاشة سياسة الخصوصية لسه مش موجودة.
                },
            ),
          ],
        ),
      ),
    );
  }
}
