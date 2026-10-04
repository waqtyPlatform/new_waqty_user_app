import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_code_text_field_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_verify_button_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/widgets/register_resend_code_widget.dart';

class RegisterVerifyCodeScreen extends StatelessWidget {
  final String email;
  final String method;
  final String otpChannel;
  final String verifyEndpoint;
  const RegisterVerifyCodeScreen({
    required this.email,
    this.method = 'email',
    this.otpChannel = 'email',
    this.verifyEndpoint = '/api/user/auth/verify-email',
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
            key: RegisterVerifyCodeCubit.get(context).registerVerifyCodeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace(24),
                Row(
                  children: [
                    _VerifyBackButton(),
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
                  context.tr(
                    method == 'phone'
                        ? 'registerVerifyCode.titlePhone'
                        : 'registerVerifyCode.titleEmail',
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    fontSize: 24.sp,
                    height: 1.28,
                  ),
                ),
                verticalSpace(6),
                Text(
                  context.tr(
                    method == 'phone'
                        ? 'registerVerifyCode.descriptionPhone'
                        : 'registerVerifyCode.descriptionEmail',
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 16.sp,
                    height: 1.65,
                  ),
                ),
                verticalSpace(30),

                RegisterCodeTextFieldWidget(email: email),

                verticalSpace(24),
                RegisterResendCodeWidget(email: email),
                verticalSpace(40),
                RegisterVerifyButtonWidget(email: email),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyBackButton extends StatelessWidget {
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
