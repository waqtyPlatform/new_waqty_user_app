import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';

class RegisterCodeTextFieldWidget extends StatelessWidget {
  final String email;
  const RegisterCodeTextFieldWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 4,
      enableSuggestions: true,
      showCursor: true,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      controller: RegisterVerifyCodeCubit.get(context).verifyCodeController,
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
        if (MyConnectivity.isOnline()) {
          RegisterVerifyCodeCubit.get(context).verifyCode(email);
        } else {
          AppConstant.toast(
            context.tr('registerVerifyCode.noInternet'),
            false,
            context,
          );
        }
      },
    );
  }
}
