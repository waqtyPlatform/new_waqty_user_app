import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/change_phone/ui/widgets/change_phone_content.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ChangePhoneScreen extends StatelessWidget {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      bottomNavigationBar: AccountFlowFooter(
        primaryKey: 'changePhone.sendCodeButton',
        secondaryKey: 'changePhone.backButton',
        onPrimaryTap: () => context.pushNamed(Routes.confirmPhoneScreen),
        onSecondaryTap: context.pop,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 130.h),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: ChangePhoneContent(),
          ),
        ),
      ),
    );
  }
}
