import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class WaqtyPinCodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  const WaqtyPinCodeField({
    super.key,
    required this.controller,
    this.onCompleted,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 60.w,
      height: 64.h,
      textStyle: TextStyles.font24greyColor900Weight600.copyWith(height: 1.3),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.greyColor900.withValues(alpha: 0.10),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );

    return Pinput(
      length: 4,
      autofocus: autofocus,
      enableSuggestions: false,
      showCursor: true,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      defaultPinTheme: pinTheme,
      focusedPinTheme: pinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.greenColor500, width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      submittedPinTheme: pinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.greenColor500, width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      errorPinTheme: pinTheme.copyDecorationWith(
        border: Border.all(color: AppColors.errorColor100, width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      onCompleted: onCompleted,
    );
  }
}
