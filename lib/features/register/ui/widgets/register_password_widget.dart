import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/register/logic/register_state.dart';

class RegisterPasswordWidget extends StatelessWidget {
  const RegisterPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is IsPasswordVisibleState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: 'register.enterPasswordText'.tr(),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 20.w,
          ),
          textStyle: TextStyles.font16greyColor900Weight400,
          controller: RegisterCubit.get(context).registerPasswordController,
          backgroundColor: AppColors.whiteColor,

          isObscureText: RegisterCubit.get(context).isPasswordVisibleLogin,

          suffixIcon: IconButton(
            icon: Icon(
              RegisterCubit.get(context).isPasswordVisibleLogin
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppColors.greyColor3003,
            ),
            onPressed: () {
              RegisterCubit.get(context).changePasswordLoginState();
            },
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(10.r),
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
              return 'register.enterPasswordText2'.tr();
            }
            return null;
          },
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }
}
