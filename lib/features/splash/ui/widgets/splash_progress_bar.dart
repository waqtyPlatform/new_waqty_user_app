import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

class SplashProgressBar extends StatelessWidget {
  final AnimationController progressController;
  final Animation<double> opacityAnimation;

  const SplashProgressBar({
    required this.progressController,
    required this.opacityAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 137.w,
          top: 738.h,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: 145.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
        Positioned(
          left: 137.w,
          top: 738.h,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: Container(
                width: 145.w,
                height: 3.h,
                alignment: Alignment.centerRight,
                child: Container(
                  width: (145 * progressController.value).w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
