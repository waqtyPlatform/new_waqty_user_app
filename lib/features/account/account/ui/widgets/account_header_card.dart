import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class AccountHeaderCard extends StatelessWidget {
  final bool isGuest;

  const AccountHeaderCard({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.25),
            blurRadius: 45.r,
            offset: Offset(0, 16.h),
            spreadRadius: -16.r,
          ),
        ],
      ),
      child: isGuest ? _GuestHeaderContent() : _UserHeaderContent(),
    );
  }
}

class _UserHeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;
    const crossAxisAlignment = CrossAxisAlignment.start;

    final avatar = Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.12),
          width: 3.w,
        ),
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
    );
    final arrow = Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: AppColors.whiteColor,
        size: 20.sp,
        textDirection: TextDirection.ltr,
      ),
    );
    final userInfo = Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            context.tr('account.userName'),
            textAlign: textAlign,
            style: TextStyles.font20greyColor900W600.copyWith(
              color: AppColors.whiteColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            context.tr('account.userPhone'),
            textAlign: textAlign,
            style: TextStyles.font12greyColor500W400.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.65),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: isArabic
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isArabic) ...[
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: const Color(0xff7BE3A8),
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
              ],
              Flexible(
                child: Text(
                  context.tr('account.autoPackagesMessage'),
                  textAlign: textAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font12greenColor500W600.copyWith(
                    color: const Color(0xff7BE3A8),
                  ),
                ),
              ),
              if (isArabic) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: const Color(0xff7BE3A8),
                  size: 14.sp,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Column(
      children: [
        Row(
          textDirection: TextDirection.ltr,
          children: isArabic
              ? [
                  arrow,
                  SizedBox(width: 14.w),
                  userInfo,
                  SizedBox(width: 14.w),
                  avatar,
                ]
              : [
                  avatar,
                  SizedBox(width: 14.w),
                  userInfo,
                  SizedBox(width: 14.w),
                  arrow,
                ],
        ),
        SizedBox(height: 16.h),
        Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: _MetricTile(
                title: context.tr('account.couponsMetricTitle'),
                value: context.tr('account.couponsMetricValue'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _MetricTile(
                title: context.tr('account.pointsMetricTitle'),
                value: context.tr('account.pointsMetricValue'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _MetricTile(
                title: context.tr('account.walletMetricTitle'),
                value: context.tr('account.walletMetricValue'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuestHeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;
    const crossAxisAlignment = CrossAxisAlignment.start;
    final icon = Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline_rounded,
        color: AppColors.whiteColor,
        size: 32.sp,
      ),
    );
    final info = Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            context.tr('account.guestTitle'),
            textAlign: textAlign,
            style: TextStyles.font20greyColor900W600.copyWith(
              color: AppColors.whiteColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr('account.guestSubtitle'),
            textAlign: textAlign,
            style: TextStyles.font12greyColor500W400.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.65),
              height: 1.65,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Row(
          textDirection: TextDirection.ltr,
          children: isArabic
              ? [info, SizedBox(width: 14.w), icon]
              : [icon, SizedBox(width: 14.w), info],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _GuestActionButton(
                text: context.tr('account.createAccount'),
                backgroundColor: AppColors.whiteColor.withValues(alpha: 0.10),
                textColor: AppColors.whiteColor,
                onTap: () => context.pushNamed(Routes.registerScreen),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _GuestActionButton(
                text: context.tr('account.login'),
                backgroundColor: AppColors.whiteColor,
                textColor: AppColors.greyColor900,
                onTap: () => context.pushNamed(Routes.loginScreen),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;

  const _MetricTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font12greyColor500W400.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.70),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font20greyColor900W600.copyWith(
              color: AppColors.whiteColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _GuestActionButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          style: TextStyles.font16greyColor900Weight600.copyWith(
            color: textColor,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
