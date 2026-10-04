import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterPasswordWidget extends StatelessWidget {
  const RegisterPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is IsPasswordVisibleState ||
            current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: context.tr('register.enterPasswordText'),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 17.h,
            horizontal: 14.w,
          ),

          textStyle: TextStyles.font16greyColor900Weight400,
          controller: RegisterCubit.get(context).registerPasswordController,

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
              return context.tr('register.enterPasswordText2');
            }
            if (value.length < 8) {
              return context.tr('register.enterPasswordText2');
            }
            return null;
          },
          backgroundColor: AppColors.whiteColor,
          onTap: () {
            RegisterCubit.get(context).changeSelectedField(6);
          },
          onTapOutside: () {
            RegisterCubit.get(context).changeSelectedField(0);
          },
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }
}
