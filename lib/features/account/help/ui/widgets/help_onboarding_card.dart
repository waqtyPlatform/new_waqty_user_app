import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HelpOnboardingCard extends StatelessWidget {
  const HelpOnboardingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return SizedBox(
      height: 84.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.greyColor50),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.03),
              blurRadius: 2.r,
              offset: Offset(0, 1.h),
            ),
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.16),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
              spreadRadius: -14.r,
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.greenColor505,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: AppColors.greenColor600,
                  size: 22,
                ),
              ),
            ),
            Positioned.fill(
              left: isArabic ? 34.w : 54.w,
              right: isArabic ? 54.w : 34.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('help.onboardingTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyles.font16greyColor900Weight600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('help.onboardingSubtitle'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyles.font12greyColor500W400.copyWith(
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Icon(
                isArabic
                    ? Icons.keyboard_arrow_left_rounded
                    : Icons.keyboard_arrow_right_rounded,
                color: AppColors.greyColor500,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
