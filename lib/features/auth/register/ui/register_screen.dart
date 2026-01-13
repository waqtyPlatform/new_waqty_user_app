import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_already_have_account_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_button_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_email_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_name_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_password_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_phone_number_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_terms_and_conditions_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: RegisterCubit.get(context).registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),
                Image.asset(ImageAsset.logoImage, height: 50),
                verticalSpace(16),
                Text(
                  'register.title'.tr(),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  'register.description'.tr(),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  "register.nameText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterNameWidget(),
                verticalSpace(16),

                Text(
                  "register.phoneText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterPhoneNumberWidget(),
                verticalSpace(16),

                Text(
                  "register.emailText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                RegisterEmailWidget(),
                verticalSpace(16),

                Text(
                  "register.passwordText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                RegisterPasswordWidget(),
                verticalSpace(54),

                RegisterButtonWidget(),
                verticalSpace(24),
                RegisterTermsAndConditionsWidget(),
                verticalSpace(58),
                RegisterAlreadyHaveAccountWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
