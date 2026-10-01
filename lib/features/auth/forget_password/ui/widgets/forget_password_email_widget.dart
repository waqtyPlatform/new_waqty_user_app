import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_state.dart';

class ForgetPasswordEmailWidget extends StatelessWidget {
  const ForgetPasswordEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        final cubit = ForgetPasswordCubit.get(context);
        return AppTextFormField(
          hintText: context.tr(
            cubit.isEmailRecovery
                ? "forgetPassword.enterEmailText"
                : "forgetPassword.enterPhoneText",
          ),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 17.h,
            horizontal: 14.w,
          ),
          textStyle: TextStyles.font16greyColor900Weight400,
          controller: cubit.forgetPasswordEmailController,
          prefixIcon: cubit.isEmailRecovery
              ? null
              : SizedBox(
                  width: 115,
                  child: CountryCodePicker(
                    initialSelection: 'Eg',
                    favorite: const ['Eg'],
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.greyColor900.withValues(alpha: 0.10),
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
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return context.tr(
                cubit.isEmailRecovery
                    ? "forgetPassword.enterEmailText2"
                    : "forgetPassword.enterPhoneText2",
              );
            }
            return null;
          },
          backgroundColor: AppColors.whiteColor,
          onTap: () {
            cubit.changeSelectedField(1);
          },
          onTapOutside: () {
            cubit.changeSelectedField(0);
          },
          keyboardType: cubit.isEmailRecovery
              ? TextInputType.emailAddress
              : TextInputType.phone,
        );
      },
    );
  }
}
