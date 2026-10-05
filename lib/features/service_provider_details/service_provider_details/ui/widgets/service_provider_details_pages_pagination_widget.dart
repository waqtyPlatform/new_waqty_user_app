import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsPagesPaginationWidget extends StatelessWidget {
  const ServiceProviderDetailsPagesPaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.greenColor505,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'About',
              maxLines: 1,
              style: TextStyles.font14greenColor500Weight500,
            ),
          ),
          horizontalSpace(8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.greyColor25,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Services',
              maxLines: 1,
              style: TextStyles.font14greyColor500W500,
            ),
          ),
          horizontalSpace(8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.greyColor25,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Package',
              maxLines: 1,
              style: TextStyles.font14greyColor500W500,
            ),
          ),
          horizontalSpace(8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.greyColor25,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Review',
              maxLines: 1,
              style: TextStyles.font14greyColor500W500,
            ),
          ),
        ],
      ),
    );
  }
}
