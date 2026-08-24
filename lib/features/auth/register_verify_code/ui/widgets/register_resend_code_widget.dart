import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/widgets/resend_code_widget.dart'
    as shared;
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_state.dart';

/// وصلة الـ cubit بالـ[shared.ResendCodeWidget] المشترك.
///
/// شوف `ForgetResendCodeWidget` — الاتنين كانوا نسخة واحدة.
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

        return shared.ResendCodeWidget(
          canResend: cubit.canResend,
          timerText: cubit.timerText,
          resendLabel: context.tr('registerVerifyCode.resend'),
          countdownPrefix: context.tr('registerVerifyCode.resendIn'),
          countdownSuffix: context.tr('registerVerifyCode.seconds'),
          onResend: () {
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
        );
      },
    );
  }
}
