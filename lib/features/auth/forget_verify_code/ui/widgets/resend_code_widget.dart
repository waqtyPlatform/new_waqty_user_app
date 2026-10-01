import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ResendCodeWidget extends StatelessWidget {
  final String email;
  final String method;
  const ResendCodeWidget({
    super.key,
    required this.email,
    this.method = 'email',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetVerifyCodeCubit, ForgetVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is ResendTimerTickState ||
            current is ResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = ForgetVerifyCodeCubit.get(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!cubit.canResend)
              Text(
                context.tr('verifyCode.resendIn'),
                style: TextStyles.font14greyColor500W400,
              ),
            if (cubit.canResend)
              GestureDetector(
                onTap: () {
                  if (MyConnectivity.isOnline()) {
                    cubit.resendCode(email, method: method);
                  } else {
                    AppConstant.toast(
                      context.tr('verifyCode.noInternet'),
                      false,
                      context,
                    );
                  }
                },
                child: Text(
                  context.tr('verifyCode.resend'),
                  style: TextStyles.font14greenColor500Weight600,
                ),
              )
            else
              Text(
                cubit.timerText,
                style: TextStyles.font14greenColor500Weight400,
              ),
            if (!cubit.canResend)
              Text(
                context.tr('verifyCode.seconds'),
                style: TextStyles.font14greyColor500W400,
              ),
          ],
        );
      },
    );
  }
}
