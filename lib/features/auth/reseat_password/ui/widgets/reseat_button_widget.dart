import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatButtonWidget extends StatelessWidget {
  final String email;
  final String code;
  const ReseatButtonWidget({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReseatPasswordCubit, ReseatPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          showDialogChangePasswordDone(context);
        } else if (state is ResetPasswordErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is ResetPasswordCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is ResetPasswordLoadingState,
          borderRadius: 999,
          buttonHeight: 52.h,
          buttonText: context.tr('reseatPassword.newPasswordText2'),
          backGroundColor: AppColors.greyColor900,
          borderColor: AppColors.greyColor900,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateResetPassword(context);
          },
        );
      },
    );
  }

  void validateResetPassword(BuildContext context) {
    if (ReseatPasswordCubit.get(context).reseatKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        ReseatPasswordCubit.get(context).resetPassword(email, code);
      } else {
        AppConstant.toast(context.tr('register.noInternet'), false, context);
      }
    }
  }

  static showDialogChangePasswordDone(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.greyColor3004.withValues(alpha: .4),
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          contentPadding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 22.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  ImageAsset.waqtySymbolGreen,
                  width: 92.w,
                  height: 92.w,
                ),
                verticalSpace(22),
                Text(
                  context.tr('passwordChangedDone.title'),
                  style: TextStyles.font18greyColor900Weight600.copyWith(
                    fontSize: 20.sp,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(8),
                Text(
                  context.tr('passwordChangedDone.description'),
                  textAlign: TextAlign.center,
                  style: TextStyles.font14greyColor4002Weight400.copyWith(
                    fontSize: 13.sp,
                    height: 1.55,
                  ),
                ),
                verticalSpace(30),
                ButtonWidget(
                  isLoading: false,
                  borderRadius: 999,
                  buttonHeight: 52.h,
                  buttonText: context.tr('passwordChangedDone.buttonText'),
                  backGroundColor: AppColors.greyColor900,
                  borderColor: AppColors.greyColor900,
                  textStyle: TextStyles.font16whiteColorWeight600,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.loginScreen,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
