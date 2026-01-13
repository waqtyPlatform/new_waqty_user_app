import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ForgetVerifyButtonWidget extends StatelessWidget {
  const ForgetVerifyButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgetVerifyCodeCubit, ForgetVerifyCodeState>(
      // buildWhen: (previous, current) {
      //   return current is OnLoginLoadingState ||
      //       current is OnLoginSuccessState ||
      //       current is OnLoginErrorState ||
      //       current is OnLoginCatchErrorState;
      // },
      listener: (context, state) {
        // if (state is OnLoginSuccessState) {
        //   AppConstant.toast('Login successfully', true, context);
        //   if (type == 'sender') {
        //     context.pushNamed(Routes.senderButtonNavigationBarScreen);
        //   } else {
        //     context.pushNamed(Routes.buttonNavigationBarScreen);
        //   }
        //
        //   ///
        // } else if (state is OnLoginErrorState) {
        //   AppConstant.toast(state.message, false, context);
        // } else if (state is OnLoginCatchErrorState) {
        //   AppConstant.toast('Email Or Password is Wrong', false, context);
        // }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: false,
          borderRadius: 12,
          buttonHeight: 50.h,
          buttonText: "verifyCode.confirmCodeText".tr(),
          backGroundColor: AppColors.greenColor500,
          borderColor: AppColors.greenColor500,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            context.pushNamed(Routes.reseatPasswordScreen);
          },
        );
      },
    );
  }
}
