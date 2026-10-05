import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HelpSearchBar extends StatelessWidget {
  const HelpSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.greyColor50),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.04),
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.20),
            blurRadius: 28.r,
            offset: Offset(0, 12.h),
            spreadRadius: -14.r,
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: AppColors.greenColor505,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.greenColor600,
                size: 20,
              ),
            ),
          ),
          Positioned.fill(
            left: 0,
            right: 50.w,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.tr('help.searchHint'),
                textAlign: TextAlign.start,
                style: TextStyles.font14greyColor500W400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
