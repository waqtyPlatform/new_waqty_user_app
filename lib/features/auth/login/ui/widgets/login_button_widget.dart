import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      buildWhen: (previous, current) {
        return current is InitialState ||
            current is OnLoginLoadingState ||
            current is OnLoginSuccessState ||
            current is OnLoginErrorState ||
            current is OnLoginCatchErrorState ||
            current is OnGoogleLoginLoadingState ||
            current is OnGoogleLoginSuccessState ||
            current is OnGoogleLoginErrorState ||
            current is OnGoogleLoginCatchErrorState ||
            current is OnAppleLoginLoadingState ||
            current is OnAppleLoginSuccessState ||
            current is OnAppleLoginErrorState ||
            current is OnAppleLoginCatchErrorState;
      },
      listener: (context, state) {
        if (state is OnLoginSuccessState) {
          AppConstant.toast(state.loginResponseModel.message, true, context);
          if (state.loginResponseModel.code == StatusCode.notVerified ||
              _isSelectedLoginUnverified(context, state.loginResponseModel)) {
            _openVerifyCode(context, state.loginResponseModel);
          } else {
            _openNextScreen(context, state.loginResponseModel);
          }
        } else if (state is OnGoogleLoginSuccessState) {
          AppConstant.toast(state.loginResponseModel.message, true, context);
          _openSocialNextScreen(context, state.loginResponseModel);
        } else if (state is OnAppleLoginSuccessState) {
          AppConstant.toast(state.loginResponseModel.message, true, context);
          _openSocialNextScreen(context, state.loginResponseModel);
        } else if (state is OnLoginErrorState) {
          AppConstant.toast(state.error, false, context);
        } else if (state is OnGoogleLoginErrorState) {
          AppConstant.toast(state.error, false, context);
        } else if (state is OnAppleLoginErrorState) {
          AppConstant.toast(state.error, false, context);
        } else if (state is OnLoginCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        } else if (state is OnGoogleLoginCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        } else if (state is OnAppleLoginCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is OnLoginLoadingState,
          borderRadius: 999,
          buttonHeight: 52.h,
          buttonText: context.tr("login.loginNowText"),
          backGroundColor: AppColors.greyColor900,
          borderColor: AppColors.greyColor900,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateLogin(context);
          },
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

  bool _isSelectedLoginUnverified(
    BuildContext context,
    LoginResponseModel loginResponseModel,
  ) {
    final cubit = LoginCubit.get(context);
    final user = loginResponseModel.data?.user;
    if (user == null) return false;
    return cubit.isPhoneLogin
        ? user.phoneVerifiedAt.isEmpty
        : user.emailVerifiedAt.isEmpty;
  }

  void _openVerifyCode(
    BuildContext context,
    LoginResponseModel loginResponseModel,
  ) {
    final cubit = LoginCubit.get(context);
    final isPhone = cubit.isPhoneLogin;
    context.pushNamed(
      Routes.registerVerifyCodeScreen,
      arguments: {
        'email': loginResponseModel.login.isNotEmpty
            ? loginResponseModel.login
            : cubit.currentLoginValue,
        'method': isPhone ? 'phone' : 'email',
        'otp_channel': isPhone ? 'whatsapp' : 'email',
        'verify_endpoint': isPhone
            ? '/api/user/auth/verify-phone-signup'
            : '/api/user/auth/verify-email',
        'can_choose_otp_channel': false,
        'isSndCodeFrommServer': true,
      },
    );
  }

  void _openNextScreen(
    BuildContext context,
    LoginResponseModel loginResponseModel,
  ) {
    if (loginResponseModel.data?.profileComplete == false) {
      context.pushNamed(
        Routes.registerScreen,
        arguments: {
          'social_user': loginResponseModel.data?.user,
          'missing_profile_fields':
              loginResponseModel.data?.missingProfileFields ?? const [],
        },
      );
    } else {
      context.pushNamed(Routes.buttonNavigationBarScreen);
    }
  }

  void _openSocialNextScreen(
    BuildContext context,
    LoginResponseModel loginResponseModel,
  ) {
    context.pushNamed(Routes.buttonNavigationBarScreen);
  }
}
