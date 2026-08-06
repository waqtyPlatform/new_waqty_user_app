import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/widgets/app_pin_field_widget.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';

class RegisterCodeTextFieldWidget extends StatelessWidget {
  final String email;
  const RegisterCodeTextFieldWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AppPinFieldWidget(
      controller: RegisterVerifyCodeCubit.get(context).verifyCodeController,
      onCompleted: (_) {
        if (MyConnectivity.isOnline()) {
          RegisterVerifyCodeCubit.get(context).verifyCode(email);
        } else {
          AppConstant.toast(
            context.tr('registerVerifyCode.noInternet'),
            false,
            context,
          );
        }
      },
    );
  }
}
