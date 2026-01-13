import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatConfirmNewPasswordWidget extends StatelessWidget {
  const ReseatConfirmNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState ||
            current is IsConfirmNewPasswordVisibleState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: 'reseatPassword.enterConfirmNewPasswordText'.tr(),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 12.w,
          ),

          textStyle: TextStyles.font16greyColor900Weight400,
          controller: ReseatPasswordCubit.get(
            context,
          ).reseatConfirmNewPasswordController,

          isObscureText: ReseatPasswordCubit.get(
            context,
          ).isConfirmNewPasswordVisible,

          suffixIcon: IconButton(
            icon: Icon(
              ReseatPasswordCubit.get(context).isConfirmNewPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppColors.greyColor3003,
            ),
            onPressed: () {
              ReseatPasswordCubit.get(
                context,
              ).changeConfirmNewPasswordLoginState();
            },
          ),
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
              return 'reseatPassword.enterConfirmNewPasswordText2'.tr();
            }
            return null;
          },
          backgroundColor:
              ReseatPasswordCubit.get(context).selectedFieldNumber == 2
              ? AppColors.greenColor505
              : AppColors.whiteColor,
          onTap: () {
            ReseatPasswordCubit.get(context).changeSelectedField(2);
          },
          onTapOutside: () {
            ReseatPasswordCubit.get(context).changeSelectedField(0);
          },
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }
}
