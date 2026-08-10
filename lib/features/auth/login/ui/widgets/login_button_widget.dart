import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      buildWhen: (previous, current) {
        return current is OnLoginLoadingState ||
            current is OnLoginSuccessState ||
            current is OnLoginErrorState ||
            current is OnLoginCatchErrorState;
      },
      listener: (context, state) {
        if (state is OnLoginSuccessState) {
          AppConstant.toast(state.loginResponseModel.message, true, context);
          if (state.loginResponseModel.code == StatusCode.notVerified) {
            context.pushNamed(
              Routes.registerVerifyCodeScreen,
              arguments: {
                'email': state.loginResponseModel.email,
                'isSndCodeFrommServer': true,
              },
            );
          } else {
            context.pushNamed(Routes.buttonNavigationBarScreen);
          }
        } else if (state is OnLoginErrorState) {
          AppConstant.toast(state.error, false, context);
        } else if (state is OnLoginCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        // المقاس والاستدارة والظل كلهم جوه `AppButtonWidget` — كان مكتوب
        // هنا `borderRadius: 12` و`buttonHeight: 50.h` بالإيد، ونفس السطرين
        // بأرقام مختلفة في تسع شاشات تانية.
        return AppButtonWidget(
          label: context.tr("login.loginNowText"),
          isLoading: state is OnLoginLoadingState,
          onPressed: () => validateLogin(context),
        );
      },
    );
  }

  void validateLogin(BuildContext context) {
    if (LoginCubit.get(context).loginKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        LoginCubit.get(context).login();
      } else {
        AppConstant.toast(context.tr('register.noInternet'), false, context);
      }
    }
  }
}
