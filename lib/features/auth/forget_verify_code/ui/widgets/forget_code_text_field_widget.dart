import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';

class ForgetCodeTextFieldWidget extends StatelessWidget {
  const ForgetCodeTextFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 4,
      enableSuggestions: true,
      showCursor: true,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      controller: ForgetVerifyCodeCubit.get(context).verifyCodeController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      defaultPinTheme: PinTheme(
        width: 70.w,
        height: 50.h,
        textStyle: TextStyles.font16greyColor900Weight400,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(color: AppColors.greyColor1001, width: 1.3),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 70.w,
        height: 50.h,
        textStyle: TextStyles.font16greyColor900Weight400,
        decoration: BoxDecoration(
          color: AppColors.greenColor505,
          border: Border.all(color: AppColors.greenColor500, width: 1.3),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 70.w,
        height: 50.h,
        textStyle: TextStyles.font16greyColor900Weight400,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(color: AppColors.greyColor1001, width: 1.3),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      onCompleted: (String? value) {
        // if (MyConnectivity.isOnline()) {
        // SendCodeCubit.get(context).verifyCode();
        // } else {
        //   AppConstant.toast("Check Internet Connection", AppColors.redColor);
        // }
      },
    );
  }
}
