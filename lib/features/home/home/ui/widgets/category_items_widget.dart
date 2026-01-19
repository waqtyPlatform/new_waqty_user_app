import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class CategoryItemsWidget extends StatelessWidget {
  const CategoryItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 56.r,
                width: 56.r,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.greenColor505,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cut, color: AppColors.greenColor500),
              ),
              verticalSpace(8),
              Text(
                'قص شعر',
                maxLines: 1,
                style: TextStyles.font14greyColor700Weight400,
              ),
            ],
          ),
          horizontalSpace(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 56.r,
                width: 56.r,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.greenColor505,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cut, color: AppColors.greenColor500),
              ),
              verticalSpace(8),
              Text(
                'قص شعر',
                maxLines: 1,
                style: TextStyles.font14greyColor700Weight400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
