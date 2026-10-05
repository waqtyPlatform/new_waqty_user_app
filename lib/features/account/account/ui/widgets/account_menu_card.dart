import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/account/data/models/account_menu_item_model.dart';

class AccountMenuCard extends StatelessWidget {
  final List<AccountMenuItemModel> items;

  const AccountMenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.05),
            blurRadius: 1,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.16),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
            spreadRadius: -14.r,
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => AccountMenuTile(item: item)).toList(),
      ),
    );
  }
}

class AccountMenuTile extends StatelessWidget {
  final AccountMenuItemModel item;

  const AccountMenuTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    const crossAxisAlignment = CrossAxisAlignment.start;
    final arrow = Icon(
      Icons.chevron_left_rounded,
      color: AppColors.greyColor3003,
      size: 18.sp,
    );
    final iconBox = Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xffF1F0EB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(item.icon, color: AppColors.greyColor900, size: 18.sp),
    );
    final textContent = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font16greyColor900Weight600.copyWith(height: 1.3),
          ),
          if (item.subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              item.subtitle!,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font12greyColor500W400,
            ),
          ],
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 60.h),
        child: Row(
          children: [
            arrow,
            if (item.trailing != null) ...[
              item.trailing!,
              SizedBox(width: 8.w),
            ],
            textContent,
            SizedBox(width: 12.w),
            iconBox,
          ],
        ),
      ),
    );
  }
}

class AccountVerifiedPill extends StatelessWidget {
  const AccountVerifiedPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.greenColor505,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        context.tr('account.verified'),
        style: TextStyles.font12greenColor500W600.copyWith(
          color: AppColors.greenColor600,
        ),
      ),
    );
  }
}

class AccountBadgePill extends StatelessWidget {
  final String text;

  const AccountBadgePill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.greenColor505,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyles.font12greenColor500W600.copyWith(
          color: AppColors.greenColor600,
        ),
      ),
    );
  }
}
