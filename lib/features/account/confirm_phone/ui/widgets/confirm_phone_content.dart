import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';
import 'package:waqty_user_application/core/widgets/waqty_pin_code_field.dart';
import 'package:waqty_user_application/features/account/confirm_phone/logic/confirm_phone_cubit.dart';
import 'package:waqty_user_application/features/account/confirm_phone/ui/widgets/confirm_phone_resend_timer.dart';
import 'package:waqty_user_application/features/account/confirm_phone/ui/widgets/confirm_phone_title.dart';

class ConfirmPhoneContent extends StatelessWidget {
  const ConfirmPhoneContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ConfirmPhoneCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        verticalSpace(24),
        const Row(children: [WaqtyBackButton(), Spacer()]),
        verticalSpace(18),
        const ConfirmPhoneTitle(),
        verticalSpace(30),
        WaqtyPinCodeField(controller: cubit.otpController, autofocus: false),
        verticalSpace(24),
        const ConfirmPhoneResendTimer(),
        verticalSpace(40),
      ],
    );
  }
}
