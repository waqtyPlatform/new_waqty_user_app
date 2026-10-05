import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class LegalSupportCard extends StatelessWidget {
  const LegalSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
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
            left: 0,
            right: null,
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
            left: 106.w,
            right: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
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
                      textAlign: TextAlign.start,
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
                      textAlign: TextAlign.start,
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
