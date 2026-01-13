import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_button_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_divider_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_don_not_already_have_account_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_password_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_phone_number_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_with_apple_widget.dart';
import 'package:waqty_user_application/features/login/ui/widgets/login_with_google_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: LoginCubit.get(context).loginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),
                Text(
                  'login.title'.tr(),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  'login.description'.tr(),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  "login.phoneText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                LoginPhoneNumberWidget(),
                verticalSpace(16),

                Text(
                  "login.passwordText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                LoginPasswordWidget(),
                verticalSpace(54),

                LoginButtonWidget(),
                verticalSpace(16),
                LoginDividerWidget(),
                verticalSpace(16),

                LoginWithGoogleWidget(),
                verticalSpace(16),

                LoginWithAppleWidget(),

                verticalSpace(70),
                LoginDonNotAlreadyHaveAccountWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
