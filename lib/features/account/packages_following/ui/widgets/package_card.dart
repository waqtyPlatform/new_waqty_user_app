import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class PackageCard extends StatelessWidget {
  final PackageCardModel package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PackageHeader(package: package),
          SizedBox(height: 14.h),
          _PackageCounter(package: package),
          SizedBox(height: 10.h),
          _PackageProgress(segments: package.segments),
          if (package.legend.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _PackageLegend(segments: package.legend),
          ],
          SizedBox(height: 14.h),
          _PackageFooter(metaKey: package.metaKey),
          if (package.noteKey != null) ...[
            SizedBox(height: 12.h),
            _PackageNote(noteKey: package.noteKey!),
          ],
        ],
      ),
    );
  }
}

class _PackageHeader extends StatelessWidget {
  final PackageCardModel package;

  const _PackageHeader({required this.package});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    final details = SizedBox(
      width: 196.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

    return SizedBox(
      height: 46.h,
      child: Stack(
        children: isArabic
            ? [
                Align(
                  alignment: Alignment.topLeft,
                  child: _StatusPill(package: package),
                ),
                Positioned(top: 0, right: 0, width: 196.w, child: details),
              ]
            : [
                Positioned(top: 0, left: 0, width: 196.w, child: details),
                Align(
                  alignment: Alignment.topRight,
                  child: _StatusPill(package: package),
                ),
              ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final PackageCardModel package;

  const _StatusPill({required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(package.status);
    final isArabic = accountIsArabic(context);
    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isArabic
            ? [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: colors.dot,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  context.tr(package.statusKey),
                  style: TextStyles.font12greyColor500W600.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ]
            : [
                Text(
                  context.tr(package.statusKey),
                  style: TextStyles.font12greyColor500W600.copyWith(
                    color: colors.foreground,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: colors.dot,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
      ),
    );
  }
}

class _PackageCounter extends StatelessWidget {
  final PackageCardModel package;

  const _PackageCounter({required this.package});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Row(
      mainAxisAlignment: isArabic
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: TextDirection.ltr,
      children: isArabic
          ? [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    context.tr(package.availableLabelKey),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font12greyColor500W400,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                package.availableValue,
                style: TextStyles.font32greyColor900Weight600.copyWith(
                  color: _counterColor(package.status),
                  height: 1.1,
                ),
              ),
            ]
          : [
              Text(
                package.availableValue,
                style: TextStyles.font32greyColor900Weight600.copyWith(
                  color: _counterColor(package.status),
                  height: 1.1,
                ),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    context.tr(package.availableLabelKey),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font12greyColor500W400,
                  ),
                ),
              ),
            ],
    );
  }
}

class _PackageProgress extends StatelessWidget {
  final List<PackageSegmentModel> segments;

  const _PackageProgress({required this.segments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: Row(
        textDirection: TextDirection.ltr,
        children: segments
            .map(
              (segment) => Expanded(
                flex: segment.flex.round().clamp(1, 999),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PackageLegend extends StatelessWidget {
  final List<PackageSegmentModel> segments;

  const _PackageLegend({required this.segments});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    final displayedSegments = isArabic ? segments.reversed : segments;
    return Wrap(
      alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
      runSpacing: 6.h,
      spacing: 14.w,
      textDirection: TextDirection.ltr,
      children: displayedSegments
          .map(
            (segment) => Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  context.tr(segment.labelKey),
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _PackageFooter extends StatelessWidget {
  final String metaKey;

  const _PackageFooter({required this.metaKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Container(
      padding: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: isArabic
            ? [
                _DetailsLink(isArabic: isArabic),
                SizedBox(width: 10.w),
                Expanded(
                  child: _MetaText(metaKey: metaKey, isArabic: isArabic),
                ),
              ]
            : [
                Expanded(
                  child: _MetaText(metaKey: metaKey, isArabic: isArabic),
                ),
                SizedBox(width: 10.w),
                _DetailsLink(isArabic: isArabic),
              ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String metaKey;
  final bool isArabic;

  const _MetaText({required this.metaKey, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr(metaKey),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.font12greyColor500W400,
    );
  }
}

class _DetailsLink extends StatelessWidget {
  final bool isArabic;

  const _DetailsLink({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          context.tr('packagesFollowing.details'),
          style: TextStyles.font12greenColor500W600.copyWith(
            color: AppColors.greenColor600,
          ),
        ),
        SizedBox(width: 2.w),
        Icon(
          isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: AppColors.greenColor600,
          size: 16.sp,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

class _PackageNote extends StatelessWidget {
  final String noteKey;

  const _PackageNote({required this.noteKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningColor0,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        context.tr(noteKey),
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyles.font12greyColor500W400.copyWith(
          color: AppColors.warningColor200,
          height: 1.65,
        ),
      ),
    );
  }
}

List<BoxShadow> _cardShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -14,
    ),
  ];
}

Color _counterColor(PackageFollowStatus status) {
  if (status == PackageFollowStatus.expired) return const Color(0xffC4415C);
  return AppColors.greenColor500;
}

_StatusColors _statusColors(PackageFollowStatus status) {
  switch (status) {
    case PackageFollowStatus.valid:
      return const _StatusColors(
        background: AppColors.greenColor505,
        foreground: AppColors.greenColor600,
        dot: AppColors.greenColor500,
      );
    case PackageFollowStatus.expired:
      return const _StatusColors(
        background: AppColors.errorColor0,
        foreground: AppColors.errorColor200,
        dot: AppColors.errorColor100,
      );
    case PackageFollowStatus.paused:
      return const _StatusColors(
        background: AppColors.warningColor0,
        foreground: AppColors.warningColor200,
        dot: AppColors.warningColor100,
      );
    case PackageFollowStatus.reserved:
      return const _StatusColors(
        background: AppColors.warningColor0,
        foreground: AppColors.warningColor200,
        dot: AppColors.warningColor100,
      );
  }
}

class _StatusColors {
  final Color background;
  final Color foreground;
  final Color dot;

  const _StatusColors({
    required this.background,
    required this.foreground,
    required this.dot,
  });
}
