import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsServicesWidget extends StatelessWidget {
  const ServiceProviderDetailsServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Our Services', style: TextStyles.font18greyColor900Weight600),
            Spacer(),
            Text(
              'home.SeeAllText'.tr(),
              style: TextStyles.font14greenColor500Weight600,
            ),
          ],
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 21.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Row(
            children: [
              Text('Hair Cut', style: TextStyles.font14greyColor900Weight400),
              Spacer(),
              Text('11 types', style: TextStyles.font14greyColor900Weight600),
              horizontalSpace(8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greenColor500,
                size: 12.r,
              ),
            ],
          ),
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 21.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Row(
            children: [
              Text('Hair Cut', style: TextStyles.font14greyColor900Weight400),
              Spacer(),
              Text('11 types', style: TextStyles.font14greyColor900Weight600),
              horizontalSpace(8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greenColor500,
                size: 12.r,
              ),
            ],
          ),
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 21.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Row(
            children: [
              Text('Hair Cut', style: TextStyles.font14greyColor900Weight400),
              Spacer(),
              Text('11 types', style: TextStyles.font14greyColor900Weight600),
              horizontalSpace(8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greenColor500,
                size: 12.r,
              ),
            ],
          ),
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 21.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Row(
            children: [
              Text('Hair Cut', style: TextStyles.font14greyColor900Weight400),
              Spacer(),
              Text('11 types', style: TextStyles.font14greyColor900Weight600),
              horizontalSpace(8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.greenColor500,
                size: 12.r,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
