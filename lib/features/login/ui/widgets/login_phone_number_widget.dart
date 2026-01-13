import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/login/logic/login_cubit.dart';

class LoginPhoneNumberWidget extends StatelessWidget {
  const LoginPhoneNumberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      hintText: 'login.enterPhoneText'.tr(),
      hintStyle: TextStyles.font16greyColor4002Weight500,
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      textStyle: TextStyles.font16greyColor900Weight400,
      controller: LoginCubit.get(context).loginPhoneController,
      backgroundColor: AppColors.whiteColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),

      prefixIcon: SizedBox(
        width: 130,
        child: CountryCodePicker(
          onChanged: (CountryCode code) {
            LoginCubit.get(context).loginCountryCodeController.text = code
                .toString();
          },
          initialSelection: 'Eg',
          favorite: const ['Eg'],
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
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'login.enterPhoneText2'.tr();
        }
        return null;
      },
      keyboardType: TextInputType.phone,
    );
  }
}
