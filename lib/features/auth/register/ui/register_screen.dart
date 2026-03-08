import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/change_language_icon.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_already_have_account_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_button_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_email_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_name_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_birth_date_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_password_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_phone_number_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_terms_and_conditions_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: RegisterCubit.get(context).registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),
                Row(
                  children: [
                    Image.asset(ImageAsset.logoImage, height: 50),
                    const Spacer(),
                    const ChangeLanguageIconWidget(),
                  ],
                ),

                verticalSpace(16),
                Text(
                  context.tr('register.title'),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  context.tr('register.description'),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  context.tr('register.nameText'),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterNameWidget(),
                verticalSpace(16),

                Text(
                  context.tr('register.phoneText'),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterPhoneNumberWidget(),
                verticalSpace(16),

                Text(
                  context.tr('register.emailText'),
                  style: TextStyles.font14greyColor900Weight500,
                ),

                verticalSpace(6),
                RegisterEmailWidget(),
                verticalSpace(16),

                Text(
                  context.tr('register.genderText'),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterGenderWidget(),
                verticalSpace(16),

                Text(
                  context.tr('register.birthDateText'),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                RegisterBirthDateWidget(),
                verticalSpace(16),

                Text(
                  context.tr('register.passwordText'),
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
