import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';

class AccountLogoutButton extends StatelessWidget {
  const AccountLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final logoutText = Text(
      context.tr('account.logoutButton'),
      style: TextStyles.font16greyColor900Weight600,
    );
    final logoutIcon = Icon(
      Icons.logout_rounded,
      color: AppColors.greyColor900,
      size: 18.sp,
    );

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final isLoading = state is AccountLogoutLoadingState;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isLoading ? null : () => AccountCubit.get(context).logout(),
            child: Container(
              height: 46.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF1F0EB),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.greyColor900,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isArabic
                          ? [logoutIcon, SizedBox(width: 8.w), logoutText]
                          : [logoutText, SizedBox(width: 8.w), logoutIcon],
                    ),
            ),
          ),
        );
      },
    );
  }
}
