import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_state.dart';

class RegisterResendCodeWidget extends StatelessWidget {
  final String email;
  const RegisterResendCodeWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterVerifyCodeCubit, RegisterVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is ResendTimerTickState ||
            current is ResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = RegisterVerifyCodeCubit.get(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!cubit.canResend)
              Text(
                context.tr('registerVerifyCode.resendIn'),
                style: TextStyles.font14greyColor500W400,
              ),
            if (cubit.canResend)
              GestureDetector(
                onTap: () {
                  if (MyConnectivity.isOnline()) {
                    if (cubit.canChooseOtpChannel) {
                      _showResendChannelDialog(context, cubit, email);
                    } else {
                      cubit.resendCode(email);
                    }
                  } else {
                    AppConstant.toast(
                      context.tr('registerVerifyCode.noInternet'),
                      false,
                      context,
                    );
                  }
                },
                child: Text(
                  context.tr('registerVerifyCode.resend'),
                  style: TextStyles.font14greenColor500Weight600,
                ),
              )
            else
              Text(
                cubit.timerText,
                style: TextStyles.font14greenColor500Weight400,
              ),
            if (!cubit.canResend)
              Text(
                context.tr('registerVerifyCode.seconds'),
                style: TextStyles.font14greyColor500W400,
              ),
          ],
        );
      },
    );
  }

  void _showResendChannelDialog(
    BuildContext context,
    RegisterVerifyCodeCubit cubit,
    String email,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.greyColor3004.withValues(alpha: .4),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('register.chooseCodeMethodTitle'),
                textAlign: TextAlign.center,
                style: TextStyles.font18greyColor900Weight600.copyWith(
                  fontSize: 20.sp,
                  height: 1.25,
                ),
              ),
              verticalSpace(18),
              _ResendChannelTile(
                title: context.tr('register.emailCodeOption'),
                icon: Icons.email_outlined,
                onTap: () {
                  Navigator.pop(dialogContext);
                  cubit.resendCode(email, selectedOtpChannel: 'email');
                },
              ),
              verticalSpace(12),
              _ResendChannelTile(
                title: context.tr('register.whatsappCodeOption'),
                icon: Icons.phone_outlined,
                onTap: () {
                  Navigator.pop(dialogContext);
                  cubit.resendCode(email, selectedOtpChannel: 'whatsapp');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResendChannelTile extends StatelessWidget {
  const _ResendChannelTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.pageColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.greyColor900.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.greenColor500, size: 21.sp),
            ),
            horizontalSpace(12),
            Expanded(
              child: Text(title, style: TextStyles.font14greyColor900Weight600),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.greyColor400,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
