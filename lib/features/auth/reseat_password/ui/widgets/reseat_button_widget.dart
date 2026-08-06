import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_state.dart';

class ReseatButtonWidget extends StatelessWidget {
  final String email;
  final String code;
  const ReseatButtonWidget({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReseatPasswordCubit, ReseatPasswordState>(
      buildWhen: (previous, current) {
        return current is ResetPasswordLoadingState ||
            current is ResetPasswordSuccessState ||
            current is ResetPasswordErrorState ||
            current is ResetPasswordCatchErrorState;
      },
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          AppConstant.toast(state.response.message, true, context);
          showDialogChangePasswordDone(context);
        } else if (state is ResetPasswordErrorState) {
          AppConstant.toast(state.message, false, context);
        } else if (state is ResetPasswordCatchErrorState) {
          AppConstant.toast(
            context.tr('reseatPassword.errorMessage'),
            false,
            context,
          );
        }
      },
      builder: (context, state) {
        return AppButtonWidget(
          label: context.tr('reseatPassword.newPasswordText2'),
          isLoading: state is ResetPasswordLoadingState,
          onPressed: () => validateResetPassword(email, code, context),
        );
      },
    );
  }

  void validateResetPassword(String email, String code, BuildContext context) {
    if (ReseatPasswordCubit.get(context).reseatKey.currentState!.validate()) {
      if (MyConnectivity.isOnline()) {
        ReseatPasswordCubit.get(context).resetPassword(email, code);
      } else {
        AppConstant.toast(
          context.tr('reseatPassword.noInternet'),
          false,
          context,
        );
      }
    }
  }

  /// شكل الـ dialog كله من `dialogTheme` — كان مكتوب بالإيد بأبيض صريح
  /// وستايلات من `TextStyles` القديمة.
  static void showDialogChangePasswordDone(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter.w,
          vertical: AppSpacing.s24.h,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Image.asset(ImageAsset.doneImage)),
            verticalSpace(AppSpacing.s24),
            Text(
              context.tr('passwordChangedDone.title'),
              style: AppTextStyles.sectionHeader,
              textAlign: TextAlign.center,
            ),
            verticalSpace(AppSpacing.s8),
            Text(
              context.tr('passwordChangedDone.description'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMdMuted,
            ),
            verticalSpace(AppSpacing.s24),
            AppButtonWidget(
              label: context.tr('passwordChangedDone.buttonText'),
              // أربع `pop()` ورا بعض: الـ dialog + إعادة التعيين + الكود +
              // نسيت كلمة السر — يعني بيرجع لشاشة الدخول.
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pop();
                context.pop();
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
