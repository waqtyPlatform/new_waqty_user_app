import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_state.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/widgets/forget_password_email_widget.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: ForgetPasswordCubit.get(context).forgetPasswordKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace(24),
                Row(
                  children: [
                    _ForgetBackButton(),
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
                  context.tr("forgetPassword.title"),
                  textAlign: TextAlign.start,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    fontSize: 24.sp,
                    height: 1.28,
                  ),
                ),
                verticalSpace(6),
                Text(
                  context.tr("forgetPassword.description"),
                  textAlign: TextAlign.start,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 16.sp,
                    height: 1.65,
                  ),
                ),
                verticalSpace(24),

                const _RecoveryMethodSelector(),
                verticalSpace(18),
                BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                  buildWhen: (previous, current) {
                    return current is OnChangeSelectedFieldState;
                  },
                  builder: (context, state) {
                    final cubit = ForgetPasswordCubit.get(context);
                    return _ForgetFieldLabel(
                      text: context.tr(
                        cubit.isEmailRecovery
                            ? "forgetPassword.emailText"
                            : "forgetPassword.phoneText",
                      ),
                    );
                  },
                ),
                ForgetPasswordEmailWidget(),
                verticalSpace(54),
                ForgetPasswordButtonWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgetBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.10),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back,
          color: AppColors.greyColor900,
          size: 17.sp,
        ),
      ),
    );
  }
}

class _ForgetFieldLabel extends StatelessWidget {
  const _ForgetFieldLabel({required this.text});

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

class _RecoveryMethodSelector extends StatelessWidget {
  const _RecoveryMethodSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        final cubit = ForgetPasswordCubit.get(context);
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: _RecoveryMethodOption(
                  text: context.tr('forgetPassword.emailOption'),
                  selected: cubit.isEmailRecovery,
                  onTap: () => cubit.changeRecoveryMethod('email'),
                ),
              ),
              Expanded(
                child: _RecoveryMethodOption(
                  text: context.tr('forgetPassword.phoneOption'),
                  selected: !cubit.isEmailRecovery,
                  onTap: () => cubit.changeRecoveryMethod('phone'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecoveryMethodOption extends StatelessWidget {
  const _RecoveryMethodOption({
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
