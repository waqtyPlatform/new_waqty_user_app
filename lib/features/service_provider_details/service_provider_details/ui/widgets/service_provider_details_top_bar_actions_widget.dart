import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsTopBarActionsWidget extends StatelessWidget {
  const ServiceProviderDetailsTopBarActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: .5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.whiteColor,
                  size: 24.r,
                ),
              ),
            ),
            Spacer(),
            Text('Details', style: TextStyles.font18whiteColorWeight600),
            Spacer(),
            GestureDetector(
              onTap: () {
                // context.pop();
              },
              child: Icon(
                Icons.more_vert,
                color: AppColors.whiteColor,
                size: 24.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
