import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingBalancePackageCard extends StatelessWidget {
  const OnboardingBalancePackageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28.w,
      right: 28.w,
      top: 130.h,
      child: Column(
        children: [
          const _PackageStatusCard(),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _BalanceInfoCard(
                  title: context.tr('onboardingBalance.points'),
                  value: context.tr('onboardingBalance.pointsAmount'),
                  subtitle: context.tr('onboardingBalance.pointsMeta'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BalanceInfoCard(
                  title: context.tr('onboardingBalance.walletBalance'),
                  value: context.tr('onboardingBalance.walletAmount'),
                  subtitle: context.tr('onboardingBalance.walletMeta'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageStatusCard extends StatelessWidget {
  const _PackageStatusCard();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 184.h,
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.greyColor800, AppColors.greyColor900],
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyColor900.withValues(alpha: 0.42),
                blurRadius: 24.r,
                offset: Offset(0, 20.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: ui.TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
                        Text(
                          context.tr('onboardingBalance.validUntil'),
                          style: TextStyles.font12greyColor3003Weight400,
                        ),
                        _PackageBadge(
                          label: context.tr('onboardingBalance.packageBadge'),
                        ),
                      ]
                    : [
                        _PackageBadge(
                          label: context.tr('onboardingBalance.packageBadge'),
                        ),
                        Text(
                          context.tr('onboardingBalance.validUntil'),
                          style: TextStyles.font12greyColor3003Weight400,
                        ),
                      ],
              ),
              SizedBox(height: 22.h),
              Row(
                textDirection: ui.TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: isArabic
                    ? [
                        Expanded(child: _PackageCopy(isArabic: isArabic)),
                        SizedBox(width: 10.w),
                        const _AvailableCount(),
                      ]
                    : [
                        const _AvailableCount(),
                        SizedBox(width: 10.w),
                        Expanded(child: _PackageCopy(isArabic: isArabic)),
                      ],
              ),
              SizedBox(height: 18.h),
              const _UsageSegments(),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.tr('onboardingBalance.usageMeta'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyles.font12greyColor3003Weight400,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 18.w,
          right: 18.w,
          bottom: -15.h,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _AutoLinkedPill(isArabic: isArabic),
          ),
        ),
      ],
    );
  }
}

class _PackageBadge extends StatelessWidget {
  final String label;

  const _PackageBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(label, style: TextStyles.font12whiteColorWeight600),
    );
  }
}

class _PackageCopy extends StatelessWidget {
  final bool isArabic;

  const _PackageCopy({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingBalance.sessionsAvailable'),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyles.font18whiteColorWeight600.copyWith(
              fontSize: 19.sp,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingBalance.packageMeta'),
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

class _AvailableCount extends StatelessWidget {
  const _AvailableCount();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr('onboardingBalance.availableCount'),
      style: TextStyles.font32greyColor900Weight600.copyWith(
        color: AppColors.successColor50,
        fontSize: 48.sp,
        height: 0.9,
      ),
    );
  }
}

class _UsageSegments extends StatelessWidget {
  const _UsageSegments();

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.successColor50,
      AppColors.successColor50,
      AppColors.successColor50,
      AppColors.whiteColor,
      AppColors.greyColor600,
      AppColors.greyColor600,
      AppColors.greyColor600,
    ];

    return Row(
      children: colors
          .map(
            (color) => Expanded(
              child: Container(
                height: 6.h,
                margin: EdgeInsetsDirectional.only(end: 6.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AutoLinkedPill extends StatelessWidget {
  final bool isArabic;

  const _AutoLinkedPill({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 286.w),
      child: Container(
        height: 32.h,
        padding: EdgeInsetsDirectional.only(start: 14.w, end: 10.w),
        decoration: BoxDecoration(
          color: AppColors.greenColor600,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenColor600.withValues(alpha: 0.35),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isArabic
              ? [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successColor50,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      context.tr('onboardingBalance.autoLinked'),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font14whiteColorWeight400.copyWith(
                        fontSize: isArabic ? 14.sp : 13.sp,
                      ),
                    ),
                  ),
                ]
              : [
                  Flexible(
                    child: Text(
                      context.tr('onboardingBalance.autoLinked'),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font14whiteColorWeight400.copyWith(
                        fontSize: isArabic ? 14.sp : 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successColor50,
                    size: 16.w,
                  ),
                ],
        ),
      ),
    );
  }
}

class _BalanceInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _BalanceInfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.greyColor900.withValues(alpha: 0.08),
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.12),
            blurRadius: 16.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
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
              style: TextStyles.font12greyColor3003Weight400,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font20greyColor900W600.copyWith(
                fontSize: 19.sp,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Flexible(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                subtitle,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: TextStyles.font12greyColor500W400.copyWith(
                  fontSize: 11.sp,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
