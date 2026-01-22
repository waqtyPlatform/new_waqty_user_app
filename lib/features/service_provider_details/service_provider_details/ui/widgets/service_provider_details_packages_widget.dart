import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

class ServiceProviderDetailsPackagesWidget extends StatelessWidget {
  const ServiceProviderDetailsPackagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Our Package', style: TextStyles.font18greyColor900Weight600),
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
          child: Row(
            children: [
              Image.asset(ImageAsset.t5),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Package',
                      style: TextStyles.font16greyColor900Weight600,
                    ),

                    Text(
                      'This high-end package offers luxury grooming services ',
                      style: TextStyles.font14greyColor500W400,
                    ),
                    horizontalSpace(8),
                    Row(
                      children: [
                        Text(
                          r'$125.00',
                          style: TextStyles.font14greenColor500Weight600,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 2,
                          child: ButtonWidget(
                            isLoading: false,
                            buttonHeight: 32.h,
                            buttonText: 'Book',
                            borderRadius: 6.r,
                            backGroundColor: AppColors.greenColor500,
                            borderColor: AppColors.greenColor500,
                            textStyle: TextStyles.font12whiteColorWeight600,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          child: Row(
            children: [
              Image.asset(ImageAsset.t5),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Package',
                      style: TextStyles.font16greyColor900Weight600,
                    ),

                    Text(
                      'This high-end package offers luxury grooming services ',
                      style: TextStyles.font14greyColor500W400,
                    ),
                    horizontalSpace(8),
                    Row(
                      children: [
                        Text(
                          r'$125.00',
                          style: TextStyles.font14greenColor500Weight600,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 2,
                          child: ButtonWidget(
                            isLoading: false,
                            buttonHeight: 32.h,
                            buttonText: 'Book',
                            borderRadius: 6.r,
                            backGroundColor: AppColors.greenColor500,
                            borderColor: AppColors.greenColor500,
                            textStyle: TextStyles.font12whiteColorWeight600,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          child: Row(
            children: [
              Image.asset(ImageAsset.t5),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Package',
                      style: TextStyles.font16greyColor900Weight600,
                    ),

                    Text(
                      'This high-end package offers luxury grooming services ',
                      style: TextStyles.font14greyColor500W400,
                    ),
                    horizontalSpace(8),
                    Row(
                      children: [
                        Text(
                          r'$125.00',
                          style: TextStyles.font14greenColor500Weight600,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 2,
                          child: ButtonWidget(
                            isLoading: false,
                            buttonHeight: 32.h,
                            buttonText: 'Book',
                            borderRadius: 6.r,
                            backGroundColor: AppColors.greenColor500,
                            borderColor: AppColors.greenColor500,
                            textStyle: TextStyles.font12whiteColorWeight600,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          child: Row(
            children: [
              Image.asset(ImageAsset.t5),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Package',
                      style: TextStyles.font16greyColor900Weight600,
                    ),

                    Text(
                      'This high-end package offers luxury grooming services ',
                      style: TextStyles.font14greyColor500W400,
                    ),
                    horizontalSpace(8),
                    Row(
                      children: [
                        Text(
                          r'$125.00',
                          style: TextStyles.font14greenColor500Weight600,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          flex: 2,
                          child: ButtonWidget(
                            isLoading: false,
                            buttonHeight: 32.h,
                            buttonText: 'Book',
                            borderRadius: 6.r,
                            backGroundColor: AppColors.greenColor500,
                            borderColor: AppColors.greenColor500,
                            textStyle: TextStyles.font12whiteColorWeight600,
                            onPressed: () {},
                          ),
                        ),
                      ],
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
