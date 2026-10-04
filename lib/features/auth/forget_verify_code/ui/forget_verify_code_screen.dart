import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_code_text_field_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/forget_verify_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/widgets/resend_code_widget.dart';

class ForgetVerifyCodeScreen extends StatelessWidget {
  final String email;
  final String method;
  final String channel;
  final String sentTo;
  const ForgetVerifyCodeScreen({
    required this.email,
    this.method = 'email',
    this.channel = 'email',
    this.sentTo = '',
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
            key: ForgetVerifyCodeCubit.get(context).forgetVerifyCodeKey,
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
                  context.tr('verifyCode.title'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    fontSize: 24.sp,
                    height: 1.28,
                  ),
                ),
                verticalSpace(6),
                Text(
                  _descriptionText(context),
                  textAlign: TextAlign.start,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 16.sp,
                    height: 1.65,
                  ),
                ),
                verticalSpace(30),

                ForgetCodeTextFieldWidget(email: email),

                verticalSpace(24),
                ResendCodeWidget(email: email, channel: channel),
                verticalSpace(40),
                ForgetVerifyButtonWidget(email: email),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _descriptionText(BuildContext context) {
    final description = context.tr(
      channel == 'whatsapp'
          ? 'verifyCode.descriptionPhone'
          : 'verifyCode.descriptionEmail',
    );
    if (sentTo.isEmpty) return description;
    return '$description\n$sentTo';
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
