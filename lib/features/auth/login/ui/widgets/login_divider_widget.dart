import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class LoginDividerWidget extends StatelessWidget {
  const LoginDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.greyColor1001)),
        horizontalSpace(8),
        Text(
          context.tr('login.continueWithText'),
          style: TextStyles.font12greyColor4002Weight400,
        ),
        horizontalSpace(8),
        Expanded(child: Divider(color: AppColors.greyColor1001)),
      ],
    );
  }
}
