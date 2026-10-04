import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/widgets/waqty_pin_code_field.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';

class ForgetCodeTextFieldWidget extends StatelessWidget {
  final String email;
  const ForgetCodeTextFieldWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return WaqtyPinCodeField(
      controller: ForgetVerifyCodeCubit.get(context).verifyCodeController,
      onCompleted: (value) {
        if (MyConnectivity.isOnline()) {
          ForgetVerifyCodeCubit.get(context).verifyCode(email);
        } else {
          AppConstant.toast(
            context.tr('verifyCode.noInternet'),
            false,
            context,
          );
        }
      },
    );
  }
}
