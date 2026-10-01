import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ChangeLanguageIconWidget extends StatelessWidget {
  const ChangeLanguageIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.locale == const Locale('en', 'US')) {
          context.setLocale(const Locale('ar', 'EG'));
        } else {
          context.setLocale(const Locale('en', 'US'));
        }
      },
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        decoration: BoxDecoration(
          color: const Color(0xffF1F0EB),
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          context.locale == const Locale('en', 'US') ? 'ع' : 'EN',
          style: TextStyles.font14Weight700.copyWith(
            color: AppColors.greenColor500,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
