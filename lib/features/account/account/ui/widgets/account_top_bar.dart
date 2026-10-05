import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class AccountTopBar extends StatelessWidget {
  const AccountTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Expanded(
      child: Text(
        context.tr('account.title'),
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font24greyColor900Weight600.copyWith(height: 1.3),
      ),
    );
    final notesButton = Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.18),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: -8.r,
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            blurRadius: 1.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        color: AppColors.greyColor900,
        size: 18.sp,
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 8.h),
      child: Row(
        children: [
          notesButton,
          SizedBox(width: 12.w),
          title,
        ],
      ),
    );
  }
}
