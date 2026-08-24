import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
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
          context.pushNamed(
            Routes.registerVerifyCodeScreen,
            arguments: {
              'email': state.registerResponseModel.data.email,
              'isSndCodeFrommServer': false,
            },
          );
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
        return AppButtonWidget(
          label: context.tr('register.registerNowText'),
          isLoading: state is OnRegisterLoadingState,
          onPressed: () => validateRegister(context),
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
