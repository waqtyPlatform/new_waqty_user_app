import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class LanguageInfoNote extends StatelessWidget {
  const LanguageInfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xffF1F0EB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.greyColor500,
            size: 16.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              context.tr('language.note'),
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
            ),
          ),
        ],
      ),
    );
  }
}
