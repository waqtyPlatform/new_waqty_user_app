import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';

class WaqtyBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const WaqtyBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? context.pop,
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.18),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
              spreadRadius: -8.r,
            ),
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.06),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.greyColor900,
          size: 20.sp,
        ),
      ),
    );
  }
}
