import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/widgets/resend_code_widget.dart'
    as shared;
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_state.dart';

/// وصلة الـ cubit بالـ[shared.ResendCodeWidget] المشترك.
///
/// اللي فضل هنا هو **اللي بيخص الشاشة دي بس**: نوع الـ cubit ومفاتيح
/// الترجمة. العرض كله انتقل للمشترك — كان متكرر بالحرف مع نسخة التسجيل.
class ForgetResendCodeWidget extends StatelessWidget {
  final String email;
  const ForgetResendCodeWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetVerifyCodeCubit, ForgetVerifyCodeState>(
      buildWhen: (previous, current) {
        return current is ResendTimerTickState ||
            current is ResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = ForgetVerifyCodeCubit.get(context);

        return shared.ResendCodeWidget(
          canResend: cubit.canResend,
          timerText: cubit.timerText,
          resendLabel: context.tr('verifyCode.resend'),
          countdownPrefix: context.tr('verifyCode.resendIn'),
          countdownSuffix: context.tr('verifyCode.seconds'),
          onResend: () {
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
        );
      },
    );
  }
}
