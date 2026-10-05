import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class LegalSupportCard extends StatelessWidget {
  const LegalSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Container(
      height: 76.h,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
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
          Positioned(
            left: isArabic ? 0 : null,
            right: isArabic ? null : 0,
            top: 7.h,
            child: Container(
              height: 38.h,
              constraints: BoxConstraints(minWidth: 88.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                context.tr('legal.supportButton'),
                style: TextStyles.font12greenColor500W600,
              ),
            ),
          ),
          Positioned.fill(
            left: isArabic ? 106.w : 0,
            right: isArabic ? 0 : 106.w,
            child: Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('legal.supportTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyles.font16greyColor900Weight600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('legal.supportSubtitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
