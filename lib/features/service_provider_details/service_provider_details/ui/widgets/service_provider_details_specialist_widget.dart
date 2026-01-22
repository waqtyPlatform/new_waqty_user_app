import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsSpecialistWidget extends StatelessWidget {
  const ServiceProviderDetailsSpecialistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Our Specialist',
              style: TextStyles.font18greyColor900Weight600,
            ),
            Spacer(),
            Text(
              'home.SeeAllText'.tr(),
              style: TextStyles.font14greenColor500Weight600,
            ),
          ],
        ),
        verticalSpace(16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.greyColor50),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56.r,
                      width: 56.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      'A. Walker',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font14greyColor900Weight600,
                    ),
                    Text(
                      'Sr. Barber',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
              horizontalSpace(16),
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.greyColor50),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56.r,
                      width: 56.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      'A. Walker',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font14greyColor900Weight600,
                    ),
                    Text(
                      'Sr. Barber',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
              horizontalSpace(16),
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.greyColor50),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56.r,
                      width: 56.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      'A. Walker',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font14greyColor900Weight600,
                    ),
                    Text(
                      'Sr. Barber',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
              horizontalSpace(16),
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.greyColor50),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56.r,
                      width: 56.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      'A. Walker',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font14greyColor900Weight600,
                    ),
                    Text(
                      'Sr. Barber',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
              horizontalSpace(16),
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.greyColor50),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56.r,
                      width: 56.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.r),
                        child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
                      ),
                    ),
                    verticalSpace(8),
                    Text(
                      'A. Walker',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font14greyColor900Weight600,
                    ),
                    Text(
                      'Sr. Barber',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
