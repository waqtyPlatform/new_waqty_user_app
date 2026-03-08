import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterButtonWidget extends StatelessWidget {
  const RegisterButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is OnRegisterLoadingState ||
            current is OnRegisterSuccessState ||
            current is OnRegisterErrorState ||
            current is OnRegisterCatchErrorState;
      },
      listener: (context, state) {
        if (state is OnRegisterSuccessState) {
          AppConstant.toast(state.registerResponseModel.message, true, context);
        } else if (state is OnRegisterErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is OnRegisterCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is OnRegisterLoadingState,
          borderRadius: 12,
          buttonHeight: 50.h,
          buttonText: context.tr('register.registerNowText'),
          backGroundColor: AppColors.greenColor500,
          borderColor: AppColors.greenColor500,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateRegister(context);
          },
        );
      },
    );
  }

  void validateRegister(BuildContext context) {
    if (RegisterCubit.get(context).registerKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        RegisterCubit.get(context).register();
      } else {
        AppConstant.toast(context.tr('register.noInternet'), false, context);
      }
    }
  }
}
