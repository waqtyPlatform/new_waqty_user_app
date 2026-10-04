import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 104.w,
            height: 104.w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.whiteColor, width: 4.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyColor900.withValues(alpha: 0.30),
                        blurRadius: 28.r,
                        offset: Offset(0, 12.h),
                        spreadRadius: -12.r,
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xffC2AE8A),
                        AppColors.greyColor600,
                        AppColors.blackColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 3.h,
                  end: 4.w,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.greyColor900,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.pageColor,
                        width: 3.w,
                      ),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.whiteColor,
                      size: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          context.tr('accountProfile.changePhoto'),
          textAlign: TextAlign.center,
          style: TextStyles.font12greenColor500W600.copyWith(
            color: AppColors.greenColor600,
          ),
        ),
      ],
    );
  }
}
