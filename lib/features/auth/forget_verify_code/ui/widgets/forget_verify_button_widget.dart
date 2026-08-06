import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ForgetVerifyButtonWidget extends StatelessWidget {
  final String email;
  const ForgetVerifyButtonWidget({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgetVerifyCodeCubit, ForgetVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is VerifyCodeLoadingState ||
            current is VerifyCodeSuccessState ||
            current is VerifyCodeErrorState ||
            current is VerifyCodeCatchErrorState;
      },
      listener: (context, state) {
        if (state is VerifyCodeSuccessState) {
          AppConstant.toast(state.response.message, true, context);
          context.pushNamed(
            Routes.reseatPasswordScreen,
            arguments: {
              'email': email,
              'code': ForgetVerifyCodeCubit.get(
                context,
              ).verifyCodeController.text,
            },
          ); // Assuming home screen is the destination
        } else if (state is VerifyCodeErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is VerifyCodeCatchErrorState) {
          AppConstant.toast(
            context.tr('verifyCode.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return AppButtonWidget(
          label: context.tr('verifyCode.confirmCodeText'),
          isLoading: state is VerifyCodeLoadingState,
          onPressed: () => validateVerifyCode(context),
        );
      },
    );
  }

  void validateVerifyCode(BuildContext context) {
    final code = ForgetVerifyCodeCubit.get(context).verifyCodeController.text;
    if (code.length != 4) {
      AppConstant.toast(context.tr('verifyCode.codeError'), false, context);
      return;
    }
    if (ForgetVerifyCodeCubit.get(
      context,
    ).forgetVerifyCodeKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        ForgetVerifyCodeCubit.get(context).verifyCode(email);
      } else {
        AppConstant.toast(context.tr('verifyCode.noInternet'), false, context);
      }
    }
  }
}
