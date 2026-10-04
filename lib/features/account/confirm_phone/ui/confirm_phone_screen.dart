import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/confirm_phone/ui/widgets/confirm_phone_content.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ConfirmPhoneScreen extends StatelessWidget {
  const ConfirmPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      bottomNavigationBar: AccountFlowFooter(
        primaryKey: 'confirmPhone.confirmButton',
        secondaryKey: 'confirmPhone.editPhoneButton',
        onSecondaryTap: context.pop,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: const ConfirmPhoneContent(),
        ),
      ),
    );
  }
}
