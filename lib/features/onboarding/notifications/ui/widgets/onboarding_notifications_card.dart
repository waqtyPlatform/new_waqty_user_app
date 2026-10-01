import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingNotificationsCard extends StatelessWidget {
  const OnboardingNotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28.w,
      right: 28.w,
      top: 130.h,
      child: Column(
        children: [
          const _UrgentAlertCard(),
          SizedBox(height: 8.h),
          _NotificationInfoTile(
            time: context.tr('onboardingNotifications.remindTime'),
            title: context.tr('onboardingNotifications.remindTitle'),
            meta: context.tr('onboardingNotifications.remindMeta'),
            icon: Icons.access_time,
          ),
          SizedBox(height: 8.h),
          _NotificationInfoTile(
            time: context.tr('onboardingNotifications.excuseTime'),
            title: context.tr('onboardingNotifications.excuseTitle'),
            meta: context.tr('onboardingNotifications.excuseMeta'),
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }
}

class _UrgentAlertCard extends StatelessWidget {
  const _UrgentAlertCard();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Container(
      height: 168.h,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.greyColor800, AppColors.greyColor900],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.45),
            blurRadius: 22.r,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _AlertContent()),
              SizedBox(width: 10.w),
              _AlertTimer(isArabic: isArabic),
            ],
          ),
          const Spacer(),
          Row(
            children: isArabic
                ? [
                    Expanded(
                      child: _DarkPill(
                        label: context.tr('onboardingNotifications.bookNow'),
                        backgroundColor: AppColors.greenColor500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _DarkPill(
                        label: context.tr(
                          'onboardingNotifications.skipTraffic',
                        ),
                        backgroundColor: AppColors.greyColor700,
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: _DarkPill(
                        label: context.tr(
                          'onboardingNotifications.skipTraffic',
                        ),
                        backgroundColor: AppColors.greyColor700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _DarkPill(
                        label: context.tr('onboardingNotifications.bookNow'),
                        backgroundColor: AppColors.greenColor500,
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _AlertContent extends StatelessWidget {
  const _AlertContent();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AlertSourceRow(isArabic: isArabic),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingNotifications.alertTitle'),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font24greyColor900Weight600.copyWith(
              color: AppColors.whiteColor,
              fontSize: 21.sp,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingNotifications.alertMeta'),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font12greyColor3003Weight400,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AlertSourceRow extends StatelessWidget {
  final bool isArabic;

  const _AlertSourceRow({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final sourceText = Text(
      context.tr('onboardingNotifications.appMessage'),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      style: TextStyles.font12greyColor3003Weight400.copyWith(fontSize: 11.sp),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final sourceIcon = Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: AppColors.greenColor500.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        ImageAsset.waqtySymbolGreen,
        width: 14.w,
        height: 14.w,
      ),
    );

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isArabic
            ? [sourceIcon, SizedBox(width: 8.w), sourceText]
            : [sourceIcon, SizedBox(width: 8.w), sourceText],
      ),
    );
  }
}

class _AlertTimer extends StatelessWidget {
  final bool isArabic;

  const _AlertTimer({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final timerText = Text(
      '4:32',
      style: TextStyles.font20greyColor900W600.copyWith(
        color: AppColors.whiteColor,
        fontSize: 20.sp,
      ),
    );
    final timerDot = Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: AppColors.warningColor50,
        border: Border.all(
          color: AppColors.warningColor50.withValues(alpha: 0.28),
          width: 3.w,
        ),
        shape: BoxShape.circle,
      ),
    );

    return Row(
      children: isArabic
          ? [timerDot, SizedBox(width: 6.w), timerText]
          : [timerText, SizedBox(width: 6.w), timerDot],
    );
  }
}

class _DarkPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const _DarkPill({required this.label, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font14whiteColorWeight400.copyWith(height: 1.3),
      ),
    );
  }
}

class _NotificationInfoTile extends StatelessWidget {
  final String time;
  final String title;
  final String meta;
  final IconData icon;

  const _NotificationInfoTile({
    required this.time,
    required this.title,
    required this.meta,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);
    final timeWidget = SizedBox(
      width: 54.w,
      child: Text(
        time,
        textAlign: isArabic ? TextAlign.left : TextAlign.right,
        style: TextStyles.font12greyColor3003Weight400.copyWith(
          fontSize: isArabic ? 12.sp : 11.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final copyWidget = Expanded(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor900Weight400.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              meta,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
        ],
      ),
    );
    final iconWidget = Container(
      width: 26.w,
      height: 26.w,
      decoration: BoxDecoration(
        color: AppColors.greyColor900.withValues(alpha: 0.04),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.greyColor900, size: 16.w),
    );

    return Container(
      constraints: BoxConstraints(minHeight: 50.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.greyColor900.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.12),
            blurRadius: 14.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          iconWidget,
          SizedBox(width: 8.w),
          copyWidget,
          SizedBox(width: 8.w),
          timeWidget,
        ],
      ),
    );
  }
}
