import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/profile/ui/widgets/profile_form.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      bottomNavigationBar: const AccountFlowFooter(
        primaryKey: 'accountProfile.saveButton',
        secondaryKey: 'accountProfile.backButton',
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 130.h),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountFlowHeader(titleKey: 'accountProfile.title'),
              ProfileForm(),
            ],
          ),
        ),
      ),
    );
  }
}
