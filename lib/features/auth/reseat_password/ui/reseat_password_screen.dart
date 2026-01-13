import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_button_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_confirm_new_password_widget.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/widgets/reseat_new_password_widget.dart';

class ReseatPasswordScreen extends StatelessWidget {
  const ReseatPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: ReseatPasswordCubit.get(context).reseatKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(16),
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.greyColor900,
                    size: 24.r,
                  ),
                ),
                verticalSpace(24),

                Text(
                  'reseatPassword.title'.tr(),
                  style: TextStyles.font24greyColor900Weight600,
                ),
                verticalSpace(6),
                Text(
                  'reseatPassword.description'.tr(),
                  style: TextStyles.font14greyColor4002Weight400,
                ),
                verticalSpace(32),

                Text(
                  "reseatPassword.newPasswordText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                ReseatNewPasswordWidget(),
                verticalSpace(16),
                Text(
                  "reseatPassword.confirmNewPasswordText".tr(),
                  style: TextStyles.font14greyColor900Weight500,
                ),
                verticalSpace(6),
                ReseatConfirmNewPasswordWidget(),
                verticalSpace(16),

                verticalSpace(60),
                ReseatButtonWidget(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
