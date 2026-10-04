import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_state.dart';

class ForgetPasswordButtonWidget extends StatelessWidget {
  const ForgetPasswordButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listener: (context, state) {
        if (state is ForgetPasswordSuccessState) {
          final cubit = ForgetPasswordCubit.get(context);
          AppConstant.toast(state.response.message, true, context);
          Navigator.pushNamed(
            context,
            Routes.forgetVerifyCodeScreen,
            arguments: {
              'email': cubit.forgetPasswordEmailController.text.trim(),
              'method': cubit.recoveryMethod,
              'channel': state.response.channel.isNotEmpty
                  ? state.response.channel
                  : cubit.selectedChannel,
              'sent_to': state.response.sentTo,
            },
          );
        } else if (state is ForgetPasswordErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is ForgetPasswordCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is ForgetPasswordLoadingState,
          borderRadius: 999,
          buttonHeight: 52.h,
          buttonText: context.tr("forgetPassword.sendCodeText"),
          backGroundColor: AppColors.greyColor900,
          borderColor: AppColors.greyColor900,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateForgetPassword(context);
          },
        );
      },
    );
  }

  void validateForgetPassword(BuildContext context) {
    final cubit = ForgetPasswordCubit.get(context);
    if (cubit.forgetPasswordKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        cubit.forgetPassword();
      } else {
        AppConstant.toast(context.tr('register.noInternet'), false, context);
      }
    }
  }
}
