import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HelpBookingCard extends StatelessWidget {
  const HelpBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.25),
            blurRadius: 45.r,
            offset: Offset(0, 16.h),
            spreadRadius: -16.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('help.bookingProblemTitle'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font16whiteColorWeight600.copyWith(height: 1.3),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('help.bookingProblemBody'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12whiteColorWeight600.copyWith(
                color: AppColors.whiteColor.withValues(alpha: 0.65),
                fontWeight: FontWeight.w400,
                height: 1.65,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                context.tr('help.goToBookings'),
                style: TextStyles.font12greyColor900Weight400.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
