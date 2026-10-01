import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingBookingCopySection extends StatelessWidget {
  const OnboardingBookingCopySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Positioned(
      left: 24.w,
      right: 24.w,
      top: 526.h,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isArabic
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            textDirection: ui.TextDirection.ltr,
            children: isArabic
                ? [
                    Text(
                      context.tr('onboardingBooking.category'),
                      style: TextStyles.font12greyColor500W600,
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 22.w,
                      height: 1.h,
                      color: AppColors.greenColor600.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '\u200E02 / 05',
                      style: TextStyles.font12greenColor500W600.copyWith(
                        color: AppColors.greenColor600,
                        fontSize: 11.sp,
                        letterSpacing: 1.1,
                        height: 1.5,
                      ),
                    ),
                  ]
                : [
                    Text(
                      '\u200E02 / 05',
                      style: TextStyles.font12greenColor500W600.copyWith(
                        color: AppColors.greenColor600,
                        fontSize: 11.sp,
                        letterSpacing: 1.1,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 22.w,
                      height: 1.h,
                      color: AppColors.greenColor600.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr('onboardingBooking.category'),
                      style: TextStyles.font12greyColor500W600,
                    ),
                  ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingBooking.title'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font32greyColor900Weight600.copyWith(
                letterSpacing: -0.8,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingBooking.description'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font16greyColor500Weight400.copyWith(
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
