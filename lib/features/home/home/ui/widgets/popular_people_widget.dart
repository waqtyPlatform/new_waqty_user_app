import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

class PopularPeopleWidget extends StatelessWidget {
  const PopularPeopleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Text(
                'اشهر الاطباء',
                style: TextStyles.font18greyColor900Weight600,
              ),
              Spacer(),
              Text(
                'home.SeeAllText'.tr(),
                style: TextStyles.font14greenColor500Weight600,
              ),
            ],
          ),
        ),
        verticalSpace(24),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {
                          context.pushNamed(
                            Routes.serviceProviderDetailsScreen,
                          );
                        },
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
            ],
          ),
        ),
        verticalSpace(24),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Text(
                'اشهر الحلاقين',
                style: TextStyles.font18greyColor900Weight600,
              ),
              Spacer(),
              Text(
                'home.SeeAllText'.tr(),
                style: TextStyles.font14greenColor500Weight600,
              ),
            ],
          ),
        ),
        verticalSpace(24),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
            ],
          ),
        ),
        verticalSpace(24),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Text(
                'اشهر الكوافيرات',
                style: TextStyles.font18greyColor900Weight600,
              ),
              Spacer(),
              Text(
                'home.SeeAllText'.tr(),
                style: TextStyles.font14greenColor500Weight600,
              ),
            ],
          ),
        ),
        verticalSpace(24),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
              horizontalSpace(12),
              Container(
                width: 155.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: AppColors.blackColor.withValues(alpha: .05),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(ImageAsset.t3),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        'Captain Barbershop Captain Barbershop',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyles.font14greyColor900Weight600,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '123 Main Street, Anytown, USA',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                    verticalSpace(4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text(
                            '1.2 km',
                            style: TextStyles.font14greyColor500W400,
                          ),
                          Spacer(),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningColor3003,
                          ),
                          horizontalSpace(4),
                          Text('4.8', style: TextStyles.font14greyColor500W400),
                        ],
                      ),
                    ),
                    verticalSpace(14),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ButtonWidget(
                        isLoading: false,
                        buttonHeight: 38.h,
                        buttonText: 'View Details',
                        borderRadius: 6.r,
                        backGroundColor: AppColors.greenColor500,
                        borderColor: AppColors.greenColor500,
                        textStyle: TextStyles.font14whiteColorWeight500,
                        onPressed: () {},
                      ),
                    ),
                    verticalSpace(12),
                  ],
                ),
              ),
            ],
          ),
        ),
        verticalSpace(24),
      ],
    );
  }
}
