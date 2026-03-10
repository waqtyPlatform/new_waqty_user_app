import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
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
      buildWhen: (previous, current) {
        return current is ResetPasswordLoadingState ||
            current is ResetPasswordSuccessState ||
            current is ResetPasswordErrorState ||
            current is ResetPasswordCatchErrorState;
      },
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          AppConstant.toast(state.response.message, true, context);
          showDialogChangePasswordDone(context);
        } else if (state is ResetPasswordErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is ResetPasswordCatchErrorState) {
          AppConstant.toast(
            context.tr('reseatPassword.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is ResetPasswordLoadingState,
          borderRadius: 12,
          buttonHeight: 50.h,
          buttonText: context.tr('reseatPassword.newPasswordText2'),
          backGroundColor: AppColors.greenColor500,
          borderColor: AppColors.greenColor500,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateResetPassword(email, code, context);
          },
        );
      },
    );
  }

  void validateResetPassword(String email, String code, BuildContext context) {
    if (ReseatPasswordCubit.get(context).reseatKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        ReseatPasswordCubit.get(context).resetPassword(email, code);
      } else {
        AppConstant.toast(
          context.tr('reseatPassword.noInternet'),
          false,
          context,
        );
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
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Image.asset(ImageAsset.doneImage)),
              verticalSpace(24),
              Text(
                context.tr('passwordChangedDone.title'),
                style: TextStyles.font18greyColor900Weight600,
                textAlign: TextAlign.center,
              ),
              verticalSpace(8),
              Text(
                context.tr('passwordChangedDone.description'),
                textAlign: TextAlign.center,
                style: TextStyles.font14greyColor4002Weight400,
              ),
              verticalSpace(24),
              ButtonWidget(
                isLoading: false,
                borderRadius: 12,
                buttonHeight: 50.h,
                buttonText: context.tr('passwordChangedDone.buttonText'),
                backGroundColor: AppColors.greenColor500,
                borderColor: AppColors.greenColor500,
                textStyle: TextStyles.font16whiteColorWeight600,
                onPressed: () {
                  context.pop();
                  context.pop();
                  context.pop();
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
