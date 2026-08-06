import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_state.dart';

class RegisterResendCodeWidget extends StatelessWidget {
  final String email;
  const RegisterResendCodeWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterVerifyCodeCubit, RegisterVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is ResendTimerTickState ||
            current is ResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = RegisterVerifyCodeCubit.get(context);

        if (cubit.canResend) {
          return Center(
            child: TextButton(
              onPressed: () {
                if (MyConnectivity.isOnline()) {
                  cubit.resendCode(email);
                } else {
                  AppConstant.toast(
                    context.tr('registerVerifyCode.noInternet'),
                    false,
                    context,
                  );
                }
              },
              child: Text(context.tr('registerVerifyCode.resend')),
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('registerVerifyCode.resendIn'),
              style: AppTextStyles.bodyMdMuted,
            ),
            Text(cubit.timerText, style: AppTextStyles.label),
            Text(
              context.tr('registerVerifyCode.seconds'),
              style: AppTextStyles.bodyMdMuted,
            ),
          ],
        );
      },
    );
  }
}
