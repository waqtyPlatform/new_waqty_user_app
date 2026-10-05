import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ProfileTextFieldBlock extends StatelessWidget {
  final String labelKey;
  final String hintKey;
  final TextEditingController controller;
  final bool border;
  final TextAlign? textAlign;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const ProfileTextFieldBlock({
    super.key,
    required this.labelKey,
    required this.hintKey,
    required this.controller,
    this.border = true,
    this.textAlign,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountFlowLabel(textKey: labelKey),
        AppTextFormField(
          hintText: context.tr(hintKey),
          controller: controller,
          textAlign: textAlign ?? (TextAlign.right),
          keyboardType: keyboardType,
          suffixIcon: suffixIcon,
          onTap: onTap,
          hintStyle: TextStyles.font16greyColor4002Weight500,
          textStyle: TextStyles.font16greyColor900Weight400.copyWith(
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 17.h,
            horizontal: 14.w,
          ),
          backgroundColor: AppColors.whiteColor,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: border
                  ? AppColors.greyColor900.withValues(alpha: 0.10)
                  : AppColors.whiteColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenColor500, width: 1.5),
            borderRadius: BorderRadius.circular(18.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(18.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(18.r),
          ),
          validator: (String? value) => null,
        ),
      ],
    );
  }
}
