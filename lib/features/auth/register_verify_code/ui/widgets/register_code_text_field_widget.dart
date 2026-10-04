import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/waqty_pin_code_field.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';

class RegisterCodeTextFieldWidget extends StatelessWidget {
  final String email;
  const RegisterCodeTextFieldWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return WaqtyPinCodeField(
      controller: RegisterVerifyCodeCubit.get(context).verifyCodeController,
    );
  }
}
