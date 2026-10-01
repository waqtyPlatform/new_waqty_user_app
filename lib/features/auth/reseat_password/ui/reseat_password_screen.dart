import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_button_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_confirm_new_password_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_new_password_widget.dart';

class ReseatPasswordScreen extends StatelessWidget {
  final String email;
  final String code;

  const ReseatPasswordScreen({
    required this.email,
    required this.code,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: ReseatPasswordCubit.get(context).reseatKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace(24),
                Row(
                  children: [
                    _ReseatBackButton(),
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
                  context.tr('reseatPassword.title'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    fontSize: 24.sp,
                    height: 1.28,
                  ),
                ),
                verticalSpace(6),
                Text(
                  context.tr('reseatPassword.description'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 16.sp,
                    height: 1.65,
                  ),
                ),
                verticalSpace(32),

                _ReseatFieldLabel(
                  text: context.tr('reseatPassword.newPasswordText'),
                ),
                ReseatNewPasswordWidget(),
                verticalSpace(18),
                _ReseatFieldLabel(
                  text: context.tr('reseatPassword.confirmNewPasswordText'),
                ),
                ReseatConfirmNewPasswordWidget(),

                verticalSpace(54),
                ReseatButtonWidget(email: email, code: code),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReseatBackButton extends StatelessWidget {
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

class _ReseatFieldLabel extends StatelessWidget {
  const _ReseatFieldLabel({required this.text});

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
