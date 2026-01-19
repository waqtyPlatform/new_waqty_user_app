import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class NearByLocationWidget extends StatelessWidget {
  const NearByLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenColor505,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'الكل',
                    maxLines: 1,
                    style: TextStyles.font14greenColor500Weight500,
                  ),
                ),
                horizontalSpace(6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyColor25,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'قص شعر',
                    maxLines: 1,
                    style: TextStyles.font14greyColor500W500,
                  ),
                ),
                horizontalSpace(6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyColor25,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'دقن',
                    maxLines: 1,
                    style: TextStyles.font14greyColor500W500,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(ImageAsset.t2),
              horizontalSpace(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waqty Barbershop',
                      maxLines: 1,
                      style: TextStyles.font16greyColor900Weight600,
                    ),
                    verticalSpace(4),
                    Text(
                      '123 Main Street, Anytown, USA',
                      style: TextStyles.font14greyColor500W400,
                    ),
                    verticalSpace(7),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.greenColor500),
                        horizontalSpace(4),
                        Text(
                          '1.2 km',
                          style: TextStyles.font14greyColor500W400,
                        ),
                        Spacer(flex: 1),
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.greenColor500,
                        ),
                        horizontalSpace(4),
                        Text('4.8', style: TextStyles.font14greyColor500W400),
                        Spacer(flex: 2),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
