import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/confirm_phone/logic/confirm_phone_cubit.dart';
import 'package:waqty_user_application/features/account/confirm_phone/logic/confirm_phone_state.dart';

class ConfirmPhoneResendTimer extends StatelessWidget {
  const ConfirmPhoneResendTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfirmPhoneCubit, ConfirmPhoneState>(
      buildWhen: (previous, current) {
        return current is ConfirmPhoneResendTimerTickState ||
            current is ConfirmPhoneResendTimerFinishedState;
      },
      builder: (context, state) {
        final cubit = ConfirmPhoneCubit.get(context);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: cubit.canResend ? cubit.resendCode : null,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.tr('confirmPhone.resendPrefix'),
                  style: TextStyles.font12greyColor500W400,
                ),
                TextSpan(
                  text: cubit.canResend
                      ? context.tr('verifyCode.resend')
                      : '${context.tr('verifyCode.resendIn')}${cubit.resendTime}',
                  style: TextStyles.font12greyColor500W600.copyWith(
                    color: cubit.canResend
                        ? AppColors.greenColor600
                        : AppColors.greyColor900,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
