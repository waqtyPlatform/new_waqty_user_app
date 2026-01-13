import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

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
              text: 'بتسجيلك، أنت موافق على ',
              style: TextStyles.font14greyColor4002Weight400,
            ),
            TextSpan(
              text: '\n الشروط والأحكام',
              style: TextStyles.font14greenColor500Weight600,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // // TODO: navigate to Terms & Conditions page
                  // print('Terms & Conditions tapped');
                },
            ),

            TextSpan(
              text: ' و ',
              style: TextStyles.font14greyColor4002Weight400,
            ),
            TextSpan(
              text: 'سياسة الخصوصية',
              style: TextStyles.font14greenColor500Weight600,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // // TODO: navigate to Terms & Conditions page
                  // print('Terms & Conditions tapped');
                },
            ),
          ],
        ),
      ),
    );
  }
}
