import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_button_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_password_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_phone_number_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/change_language_icon.dart';
import 'package:waqty_user_application/features/auth/shared/widgets/social_auth_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.pageColor,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: LoginCubit.get(context).loginKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          context.tr('login.title'),
                          textAlign: TextAlign.start,
                          style: TextStyles.font24greyColor900Weight600
                              .copyWith(fontSize: 24.sp, height: 1.28),
                        ),
                        verticalSpace(6),
                        Text(
                          context.tr('login.description'),
                          textAlign: TextAlign.start,
                          style: TextStyles.font14greyColor4002Weight400
                              .copyWith(fontSize: 16.sp, height: 1.65),
                        ),
                        verticalSpace(24),

                        const _LoginMethodSelector(),
                        verticalSpace(18),
                        BlocBuilder<LoginCubit, LoginState>(
                          buildWhen: (previous, current) {
                            return current is OnChangeSelectedFieldState;
                          },
                          builder: (context, state) {
                            final cubit = LoginCubit.get(context);
                            return _LoginFieldLabel(
                              text: context.tr(
                                cubit.isPhoneLogin
                                    ? 'login.phoneText'
                                    : 'login.emailText',
                              ),
                            );
                          },
                        ),
                        LoginPhoneNumberWidget(),
                        verticalSpace(14),

                        _LoginFieldLabel(
                          text: context.tr("login.passwordText"),
                        ),
                        LoginPasswordWidget(),
                        verticalSpace(12),

                        Align(
                          alignment: isEnglish
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              context.pushNamed(Routes.forgetPasswordScreen);
                            },
                            child: Text(
                              context.tr("login.forgetPasswordText"),
                              style: TextStyles.font12greenColor500W600,
                            ),
                          ),
                        ),

                        verticalSpace(78),
                        LoginButtonWidget(),
                        verticalSpace(18),
                        SocialAuthButtons(
                          googleSemanticLabelKey: 'login.loginWithGoogleText',
                          appleSemanticLabelKey: 'login.loginWithAppleText',
                          onGoogleTap: () =>
                              LoginCubit.get(context).loginWithGoogle(),
                        ),
                        verticalSpace(18),
                        const _LoginFooter(),
                        verticalSpace(26),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginMethodSelector extends StatelessWidget {
  const _LoginMethodSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        final cubit = LoginCubit.get(context);
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: _LoginMethodOption(
                  text: context.tr('login.phoneOption'),
                  selected: cubit.isPhoneLogin,
                  onTap: () => cubit.changeLoginMethod('phone'),
                ),
              ),
              Expanded(
                child: _LoginMethodOption(
                  text: context.tr('login.emailOption'),
                  selected: !cubit.isPhoneLogin,
                  onTap: () => cubit.changeLoginMethod('email'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoginMethodOption extends StatelessWidget {
  const _LoginMethodOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.whiteColor : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.greyColor900.withValues(alpha: 0.10),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyles.font14greyColor900Weight600.copyWith(
            color: selected ? AppColors.greyColor900 : AppColors.greyColor500,
          ),
        ),
      ),
    );
  }
}

class _LoginFieldLabel extends StatelessWidget {
  const _LoginFieldLabel({required this.text});

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

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () => context.pushNamed(Routes.registerScreen),
                  child: Text(
                    context.tr('login.registerNowText'),
                    style: TextStyles.font12greenColor500W600,
                  ),
                ),
              ),
              TextSpan(
                text: '  ${context.tr('login.noAccountText')}',
                style: TextStyles.font12greyColor500W400,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: isArabic ? ui.TextDirection.ltr : ui.TextDirection.rtl,
        ),
        verticalSpace(16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
            await CacheHelper.setData(
              ConstantKeys.saveIsShowIsBoardingToShared,
              false,
            );
            if (!context.mounted) return;
            context.pushNamedAndRemoveUntil(
              Routes.buttonNavigationBarScreen,
              predicate: (_) => false,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Text(
              context.tr('login.guestContinueText'),
              textAlign: TextAlign.center,
              style: TextStyles.font12greyColor500W600,
            ),
          ),
        ),
        verticalSpace(12),
        Text(
          context.tr('login.termsText'),
          textAlign: TextAlign.center,
          style: TextStyles.font12greyColor3003Weight400.copyWith(height: 1.65),
        ),
      ],
    );
  }
}
