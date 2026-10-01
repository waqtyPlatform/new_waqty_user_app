import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/change_language_icon.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_button_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_birth_date_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_email_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_name_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_password_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_phone_number_widget.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.pageColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: RegisterCubit.get(context).registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace(24),
                Row(
                  textDirection: ui.TextDirection.ltr,
                  children: isEnglish
                      ? [
                          SvgPicture.asset(
                            ImageAsset.waqtySymbolGreen,
                            width: 56.w,
                            height: 56.w,
                          ),
                          const Spacer(),
                          const ChangeLanguageIconWidget(),
                        ]
                      : [
                          const ChangeLanguageIconWidget(),
                          const Spacer(),
                          SvgPicture.asset(
                            ImageAsset.waqtySymbolGreen,
                            width: 56.w,
                            height: 56.w,
                          ),
                        ],
                ),

                verticalSpace(18),
                Text(
                  context.tr('register.title'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    fontSize: 24.sp,
                    height: 1.28,
                  ),
                ),
                verticalSpace(6),
                Text(
                  context.tr('register.description'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 16.sp,
                    height: 1.65,
                  ),
                ),
                verticalSpace(30),

                _RegisterFieldLabel(text: context.tr('register.nameText')),
                RegisterNameWidget(),
                verticalSpace(14),

                _RegisterFieldLabel(text: context.tr('register.phoneText')),
                RegisterPhoneNumberWidget(),
                verticalSpace(14),

                _RegisterFieldLabel(text: context.tr('register.emailText')),
                RegisterEmailWidget(),
                verticalSpace(14),

                _RegisterFieldLabel(text: context.tr('register.genderText')),
                RegisterGenderWidget(),
                verticalSpace(14),

                _RegisterFieldLabel(text: context.tr('register.birthDateText')),
                RegisterBirthDateWidget(),
                verticalSpace(14),

                _RegisterFieldLabel(text: context.tr('register.passwordText')),
                RegisterPasswordWidget(),
                verticalSpace(44),

                RegisterButtonWidget(),
                verticalSpace(16),
                const _RegisterLoginFooter(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterFieldLabel extends StatelessWidget {
  const _RegisterFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyles.font12greyColor500W600,
      ),
    );
  }
}

class _RegisterLoginFooter extends StatelessWidget {
  const _RegisterLoginFooter();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: context.tr('register.haveAccountText'),
            style: TextStyles.font14greyColor500W400,
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => context.pushNamed(Routes.loginScreen),
              child: Text(
                context.tr('register.loginText'),
                style: TextStyles.font14greenColor500Weight600,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
