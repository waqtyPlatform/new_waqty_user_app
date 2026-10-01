import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';

class RegisterCodeTextFieldWidget extends StatelessWidget {
  final String email;
  const RegisterCodeTextFieldWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 72.w,
      height: 56.h,
      textStyle: TextStyles.font20greyColor900W600,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.greyColor900.withValues(alpha: 0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
    );

    return Pinput(
      length: 4,
      autofocus: true,
      enableSuggestions: false,
      showCursor: true,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      controller: RegisterVerifyCodeCubit.get(context).verifyCodeController,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      defaultPinTheme: pinTheme,
      focusedPinTheme: pinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.greenColor500, width: 1.5),
        borderRadius: BorderRadius.circular(18.r),
      ),
      submittedPinTheme: pinTheme,
      errorPinTheme: pinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.errorColor100, width: 1),
        borderRadius: BorderRadius.circular(18.r),
      ),
    );
  }
}
