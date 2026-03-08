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
        return AppTextFormField(
          hintText: context.tr("forgetPassword.enterEmailText"),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 12.w,
          ),
          textStyle: TextStyles.font16greyColor900Weight400,
          controller: ForgetPasswordCubit.get(
            context,
          ).forgetPasswordEmailController,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenColor500, width: 1),
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
              return context.tr("forgetPassword.enterEmailText2");
            }
            return null;
          },
          backgroundColor:
              ForgetPasswordCubit.get(context).selectedFieldNumber == 1
              ? AppColors.greenColor505
              : AppColors.whiteColor,
          onTap: () {
            ForgetPasswordCubit.get(context).changeSelectedField(1);
          },
          onTapOutside: () {
            ForgetPasswordCubit.get(context).changeSelectedField(0);
          },
          keyboardType: TextInputType.emailAddress,
        );
      },
    );
  }
}
