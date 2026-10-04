import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ReservedPackageCard extends StatelessWidget {
  final ReservedPackageModel package;

  const ReservedPackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.warningColor100, width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.05),
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
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _ReservedHeader(package: package),
          SizedBox(height: 14.h),
          _ReservedMeta(package: package),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: package.progress,
              minHeight: 6.h,
              backgroundColor: const Color(0xffF1F0EB),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.warningColor100,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(package.noteKey),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _ReservedButton(
                  titleKey: 'packagesFollowing.branchLocation',
                  isPrimary: true,
                  icon: Icons.location_on_outlined,
                ),
              ),
              SizedBox(width: 8.w),
              _ReservedButton(
                titleKey: 'packagesFollowing.cancelReservation',
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReservedHeader extends StatelessWidget {
  final ReservedPackageModel package;

  const _ReservedHeader({required this.package});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    final details = SizedBox(
      width: 176.w,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(package.titleKey),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font16greyColor900Weight600.copyWith(
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(package.providerKey),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
        ],
      ),
    );

    final pill = Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.warningColor0,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr(package.statusKey),
            style: TextStyles.font12greyColor500W600.copyWith(
              color: AppColors.warningColor200,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: AppColors.warningColor100,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: 46.h,
      child: Stack(
        children: isArabic
            ? [
                Align(alignment: Alignment.topLeft, child: pill),
                Positioned(top: 0, right: 0, width: 176.w, child: details),
              ]
            : [
                Positioned(top: 0, left: 0, width: 176.w, child: details),
                Align(alignment: Alignment.topRight, child: pill),
              ],
      ),
    );
  }
}

class _ReservedMeta extends StatelessWidget {
  final ReservedPackageModel package;

  const _ReservedMeta({required this.package});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return SizedBox(
      height: 40.h,
      child: Stack(
        children: isArabic
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RemainingText(package: package),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _PriceText(package: package, isArabic: isArabic),
                ),
              ]
            : [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _PriceText(package: package, isArabic: isArabic),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _RemainingText(package: package),
                ),
              ],
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  final ReservedPackageModel package;
  final bool isArabic;

  const _PriceText({required this.package, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          package.price,
          style: TextStyles.font24greyColor900Weight600.copyWith(height: 1.1),
        ),
        SizedBox(width: 6.w),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            context.tr(package.priceLabelKey),
            style: TextStyles.font12greyColor500W400,
          ),
        ),
      ],
    );
  }
}

class _RemainingText extends StatelessWidget {
  final ReservedPackageModel package;

  const _RemainingText({required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: accountIsArabic(context)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('packagesFollowing.remaining'),
          style: TextStyles.font12greyColor500W400,
        ),
        Text(
          context.tr(package.remainingKey),
          style: TextStyles.font12greyColor500W600,
        ),
      ],
    );
  }
}

class _ReservedButton extends StatelessWidget {
  final String titleKey;
  final bool isPrimary;
  final IconData? icon;

  const _ReservedButton({
    required this.titleKey,
    required this.isPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.greyColor900 : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(999.r),
        border: isPrimary
            ? null
            : Border.all(color: AppColors.greyColor900.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr(titleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font14greyColor900Weight600.copyWith(
              color: isPrimary ? AppColors.whiteColor : AppColors.errorColor200,
              fontSize: 12.sp,
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: 8.w),
            Icon(icon, size: 14.sp, color: AppColors.whiteColor),
          ],
        ],
      ),
    );
  }
}
