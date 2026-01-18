import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/search_home_widget.dart';

class TopHomeWidget extends StatelessWidget {
  const TopHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(color: AppColors.greyColor900),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اهلا احمد ',
                        style: TextStyles.font18whiteColorWeight600,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.greenColor500,
                          ),
                          horizontalSpace(8),
                          Expanded(
                            child: Text(
                              'California, US',
                              style: TextStyles.font14whiteColorWeight400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  child: Container(
                    height: 48.r,
                    width: 48.r,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor800,
                      border: Border.all(color: AppColors.greyColor700),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(ImageAsset.notificationIcon),
                  ),
                ),
              ],
            ),
            verticalSpace(16),
            SearchHomeWidget(),
            verticalSpace(24),
          ],
        ),
      ),
    );
  }
}
