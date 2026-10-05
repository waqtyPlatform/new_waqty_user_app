import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class PackagesFollowingHeader extends StatelessWidget {
  const PackagesFollowingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Expanded(
      child: Text(
        context.tr('packagesFollowing.title'),
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font20greyColor900W600.copyWith(height: 1.3),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
      child: SizedBox(
        height: 44.h,
        child: Row(
          children: [
            const _AddPackageButton(),
            SizedBox(width: 12.w),
            title,
            SizedBox(width: 12.w),
            const WaqtyBackButton(),
          ],
        ),
      ),
    );
  }
}

class _AddPackageButton extends StatelessWidget {
  const _AddPackageButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.18),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: -8.r,
          ),
        ],
      ),
      child: Icon(
        Icons.add_rounded,
        size: 20.sp,
        color: AppColors.greyColor900,
      ),
    );
  }
}
