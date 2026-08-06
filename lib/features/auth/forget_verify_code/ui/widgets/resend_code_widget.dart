import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

class ResendCodeWidget extends StatelessWidget {
  final String email;
  const ResendCodeWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetVerifyCodeCubit, ForgetVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is ResendTimerTickState ||
            current is ResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = ForgetVerifyCodeCubit.get(context);

        // زرار حقيقي وقت ما ينفع الإرسال، ونص وقت العد. كان `GestureDetector`
        // — مالوش هدف لمس ولا ripple ولا دور لقارئ الشاشة.
        if (cubit.canResend) {
          return Center(
            child: TextButton(
              onPressed: () {
                if (MyConnectivity.isOnline()) {
                  cubit.resendCode(email);
                } else {
                  AppConstant.toast(
                    context.tr('verifyCode.noInternet'),
                    false,
                    context,
                  );
                }
              },
              child: Text(context.tr('verifyCode.resend')),
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('verifyCode.resendIn'),
              style: AppTextStyles.bodyMdMuted,
            ),
            Text(cubit.timerText, style: AppTextStyles.label),
            Text(
              context.tr('verifyCode.seconds'),
              style: AppTextStyles.bodyMdMuted,
            ),
          ],
        );
      },
    );
  }
}
