import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class SplashTitleBlock extends StatelessWidget {
  final Animation<double> opacityAnimation;

  const SplashTitleBlock({required this.opacityAnimation, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 75.w,
          top: 402.h,
          width: 225.w,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Text(
              context.tr('splash.title'),
              textAlign: TextAlign.center,
              style: TextStyles.font32greyColor900Weight600.copyWith(
                color: AppColors.whiteColor,
                fontSize: 44.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ),
        Positioned(
          left: 176.w,
          top: 468.h,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: 24.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: AppColors.greenColor500,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ),
        ),
        Positioned(
          left: 22.w,
          top: 487.h,
          width: 331.w,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Text(
              context.tr('splash.tagline'),
              textAlign: TextAlign.center,
              style: TextStyles.font14whiteColorWeight400.copyWith(
                color: AppColors.whiteColor.withValues(alpha: 0.72),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
