import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsPlaceDataWidget extends StatelessWidget {
  const ServiceProviderDetailsPlaceDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الدكتور محمد خالد',
                maxLines: 2,
                style: TextStyles.font20greyColor900W600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.successColor0,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'مفتوح',
                style: TextStyles.font14successColor100W500,
              ),
            ),
          ],
        ),
        verticalSpace(8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.greenColor500,
            ),
            horizontalSpace(8),
            Expanded(
              child: Text(
                '123 Main Street, Anytown, USA',
                maxLines: 2,
                style: TextStyles.font14greyColor500W400,
              ),
            ),
          ],
        ),
        verticalSpace(4),
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: AppColors.greenColor500,
            ),
            horizontalSpace(8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '4.8',
                      style: TextStyles.font14greenColor500W500,
                    ),
                    TextSpan(
                      text: '(3,279 reviews)',
                      style: TextStyles.font14greyColor500W400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        verticalSpace(28),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor505,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.wifi_calling_3_sharp,
                      color: AppColors.greenColor500,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    'Call',
                    textAlign: TextAlign.center,
                    style: TextStyles.font14greyColor500W400,
                  ),
                ],
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor505,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.greenColor500,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    'Direction',
                    textAlign: TextAlign.center,
                    style: TextStyles.font14greyColor500W400,
                  ),
                ],
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor505,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.share,
                      color: AppColors.greenColor500,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    'Share',
                    textAlign: TextAlign.center,
                    style: TextStyles.font14greyColor500W400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
