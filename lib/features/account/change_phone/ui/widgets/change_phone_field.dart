import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';

class ChangePhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool highlighted;
  final bool readOnly;
  final bool showCountryCode;
  final Widget? leading;
  final ValueChanged<CountryCode>? onCountryChanged;

  const ChangePhoneField({
    super.key,
    required this.controller,
    this.highlighted = false,
    this.readOnly = false,
    this.showCountryCode = true,
    this.leading,
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      hintText: context.tr('register.enterPhoneText'),
      controller: controller,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.left,
      isEnable: !readOnly,
      hintStyle: TextStyles.font16greyColor4002Weight500,
      textStyle: TextStyles.font16greyColor900Weight400.copyWith(
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 14.w),
      prefixIcon: leading == null && !showCountryCode
          ? null
          : SizedBox(
              width: showCountryCode ? 126.w : 66.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8.w),
                  if (leading != null) ...[leading!, SizedBox(width: 6.w)],
                  if (showCountryCode)
                    Expanded(
                      child: CountryCodePicker(
                        onChanged: onCountryChanged ?? (_) {},
                        initialSelection: 'EG',
                        favorite: const ['EG'],
                        flagWidth: 20,
                        showFlag: true,
                        showCountryOnly: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: true,
                        textStyle: TextStyle(color: AppColors.greyColor4002),
                        flagDecoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      backgroundColor: AppColors.whiteColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: highlighted
              ? AppColors.greenColor500
              : AppColors.greyColor900.withValues(alpha: 0.10),
          width: highlighted ? 1.5 : 1,
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
    );
  }
}
