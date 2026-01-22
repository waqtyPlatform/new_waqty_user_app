import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

class ServiceProviderDetailsReviewsWidget extends StatelessWidget {
  const ServiceProviderDetailsReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews', style: TextStyles.font18greyColor900Weight600),
            Spacer(),
            Text(
              'home.SeeAllText'.tr(),
              style: TextStyles.font14greenColor500Weight600,
            ),
          ],
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 54.r,
                    width: 54.r,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.greenColor500,
                    ),
                  ),
                  horizontalSpace(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rhonda Rhodes',
                          style: TextStyles.font14greyColor900Weight600,
                        ),
                        Text(
                          '3 days ago',
                          style: TextStyles.font12greyColor500W400,
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.star_rounded, color: AppColors.greenColor500),
                  horizontalSpace(4),
                  Text('3', style: TextStyles.font14greenColor500W500),
                  horizontalSpace(16),
                  Icon(Icons.more_vert, color: AppColors.greyColor900),
                ],
              ),
              verticalSpace(12),
              Text(
                "It's encouraging to see the government taking proactive steps towards addressing climate change. This legislation demonstrates a comm",
                maxLines: 4,
                style: TextStyles.font14greyColor500W400,
              ),
            ],
          ),
        ),
        verticalSpace(16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyColor50, width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 54.r,
                    width: 54.r,
                    decoration: BoxDecoration(
                      color: AppColors.greenColor100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.greenColor500,
                    ),
                  ),
                  horizontalSpace(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rhonda Rhodes',
                          style: TextStyles.font14greyColor900Weight600,
                        ),
                        Text(
                          '3 days ago',
                          style: TextStyles.font12greyColor500W400,
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.star_rounded, color: AppColors.greenColor500),
                  horizontalSpace(4),
                  Text('3', style: TextStyles.font14greenColor500W500),
                  horizontalSpace(16),
                  Icon(Icons.more_vert, color: AppColors.greyColor900),
                ],
              ),
              verticalSpace(12),
              Text(
                "It's encouraging to see the government taking proactive steps towards addressing climate change. This legislation demonstrates a comm",
                maxLines: 4,
                style: TextStyles.font14greyColor500W400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
