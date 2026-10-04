import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterButtonWidget extends StatelessWidget {
  const RegisterButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is OnRegisterLoadingState ||
            current is OnRegisterSuccessState ||
            current is OnRegisterErrorState ||
            current is OnRegisterCatchErrorState;
      },
      listener: (context, state) {
        if (state is OnRegisterSuccessState) {
          AppConstant.toast(state.registerResponseModel.message, true, context);
          _openVerifyCode(
            context: context,
            login: state.registerResponseModel.data.login,
            method: state.registerResponseModel.data.otpChannel == 'whatsapp'
                ? 'phone'
                : 'email',
            otpChannel: state.registerResponseModel.data.otpChannel,
            verifyEndpoint: state.registerResponseModel.data.verifyEndpoint,
            canChooseOtpChannel:
                RegisterCubit.get(
                  context,
                ).registerEmailController.text.trim().isNotEmpty &&
                RegisterCubit.get(
                  context,
                ).registerPhoneController.text.trim().isNotEmpty,
          );
        } else if (state is OnRegisterErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is OnRegisterCatchErrorState) {
          AppConstant.toast(
            context.tr('register.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return ButtonWidget(
          isLoading: state is OnRegisterLoadingState,
          borderRadius: 999,
          buttonHeight: 52.h,
          buttonText: context.tr('register.registerNowText'),
          backGroundColor: AppColors.greyColor900,
          borderColor: AppColors.greyColor900,
          textStyle: TextStyles.font16whiteColorWeight600,
          onPressed: () {
            validateRegister(context);
          },
        );
      },
    );
  }

  void validateRegister(BuildContext context) {
    final cubit = RegisterCubit.get(context);
    if (cubit.registerKey.currentState!.validate()) {
      final email = cubit.registerEmailController.text.trim();
      final phone = cubit.registerPhoneController.text.trim();
      final countryCode = cubit.registerCountryCodeController.text.isEmpty
          ? '+20'
          : cubit.registerCountryCodeController.text;

      if (email.isEmpty && phone.isEmpty) {
        AppConstant.toast(
          context.tr('register.enterEmailOrPhoneText'),
          false,
          context,
        );
        return;
      }

      if (email.isNotEmpty && phone.isNotEmpty) {
        _showVerificationMethodDialog(
          context: context,
          email: email,
          phone: '$countryCode$phone',
        );
        return;
      }

      _submitRegister(
        context,
        otpChannel: phone.isNotEmpty && email.isEmpty ? 'whatsapp' : 'email',
      );
    }
  }

  void _submitRegister(BuildContext context, {required String otpChannel}) {
    if (MyConnectivity.isOnline()) {
      RegisterCubit.get(context).register(otpChannel: otpChannel);
    } else {
      AppConstant.toast(context.tr('register.noInternet'), false, context);
    }
  }

  void _openVerifyCode({
    required BuildContext context,
    required String login,
    required String method,
    required String otpChannel,
    required String verifyEndpoint,
    required bool canChooseOtpChannel,
  }) {
    context.pushNamed(
      Routes.registerVerifyCodeScreen,
      arguments: {
        'email': login,
        'method': method,
        'otp_channel': otpChannel,
        'verify_endpoint': verifyEndpoint,
        'can_choose_otp_channel': canChooseOtpChannel,
        'isSndCodeFrommServer': false,
      },
    );
  }

  void _showVerificationMethodDialog({
    required BuildContext context,
    required String email,
    required String phone,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.greyColor3004.withValues(alpha: .4),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('register.chooseCodeMethodTitle'),
                textAlign: TextAlign.center,
                style: TextStyles.font18greyColor900Weight600.copyWith(
                  fontSize: 20.sp,
                  height: 1.25,
                ),
              ),
              verticalSpace(8),
              Text(
                context.tr('register.chooseCodeMethodDescription'),
                textAlign: TextAlign.center,
                style: TextStyles.font14greyColor4002Weight400.copyWith(
                  height: 1.55,
                ),
              ),
              verticalSpace(22),
              _VerificationMethodTile(
                title: context.tr('register.emailCodeOption'),
                subtitle: email,
                icon: Icons.email_outlined,
                onTap: () {
                  Navigator.pop(dialogContext);
                  _submitRegister(context, otpChannel: 'email');
                },
              ),
              verticalSpace(12),
              _VerificationMethodTile(
                title: context.tr('register.whatsappCodeOption'),
                subtitle: phone,
                icon: Icons.phone_outlined,
                onTap: () {
                  Navigator.pop(dialogContext);
                  _submitRegister(context, otpChannel: 'whatsapp');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerificationMethodTile extends StatelessWidget {
  const _VerificationMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.pageColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.greyColor900.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.greenColor500, size: 21.sp),
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyles.font14greyColor900Weight600),
                  verticalSpace(3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font12greyColor500W600,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.greyColor400,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
