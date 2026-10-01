import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatNewPasswordWidget extends StatelessWidget {
  const ReseatNewPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState ||
            current is IsNewPasswordVisibleState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: context.tr('reseatPassword.enterNewPasswordText'),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 16.w,
          ),

          textStyle: TextStyles.font16greyColor900Weight400,
          controller: ReseatPasswordCubit.get(
            context,
          ).reseatNewPasswordController,

          isObscureText: ReseatPasswordCubit.get(context).isNewPasswordVisible,

          suffixIcon: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ReseatPasswordCubit.get(context).changeNewPasswordLoginState();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(
                ReseatPasswordCubit.get(context).isNewPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.greyColor3003,
                size: 18.sp,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenColor500, width: 1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return context.tr('reseatPassword.enterNewPasswordText2');
            }
            return null;
          },
          backgroundColor:
              ReseatPasswordCubit.get(context).selectedFieldNumber == 1
              ? AppColors.whiteColor
              : AppColors.whiteColor,
          onTap: () {
            ReseatPasswordCubit.get(context).changeSelectedField(1);
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
