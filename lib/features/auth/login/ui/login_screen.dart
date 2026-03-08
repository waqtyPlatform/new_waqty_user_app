import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_button_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_divider_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_don_not_already_have_account_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_password_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_phone_number_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_with_apple_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_with_google_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: LoginCubit.get(context).loginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),

                Image.asset(ImageAsset.logoImage, height: 50),
                verticalSpace(16),
                Text(
                  context.tr('login.title'),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  context.tr('login.description'),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  context.tr("login.phoneText"),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                LoginPhoneNumberWidget(),
                verticalSpace(16),

                Text(
                  context.tr("login.passwordText"),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                LoginPasswordWidget(),
                verticalSpace(16),

                GestureDetector(
                  onTap: () {
                    context.pushNamed(Routes.forgetPasswordScreen);
                  },
                  child: Text(
                    context.tr("login.forgetPasswordText"),
                    style: TextStyles.font14greenColor500Weight600,
                  ),
                ),

                verticalSpace(48),

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
