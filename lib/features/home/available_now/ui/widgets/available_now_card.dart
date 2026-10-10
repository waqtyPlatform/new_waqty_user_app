import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/cached_network_image.dart';
import 'package:waqty_user_application/features/home/home/data/models/available_now_model.dart';

class AvailableNowCard extends StatelessWidget {
  final AvailableNowModel provider;
  final bool showDistance;
  final double? width;

  const AvailableNowCard({
    super.key,
    required this.provider,
    required this.showDistance,
    this.width,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).pushNamed(
      Routes.providerDetailsScreen,
      arguments: {
        'provider_uuid': provider.providerUuid,
        'provider_name': provider.providerName,
        'logo_path': provider.logoUrl,
        'category_name': provider.categoryName,
        'branch_name': provider.branchName,
        'rating': provider.rating,
        'rating_count': provider.ratingCount,
      },
    ),
    child: _CardSurface(
      width: width ?? 190.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 116.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                provider.logoUrl == null
                    ? const _PhotoPlaceholder()
                    : CachedNetworkImageWidget(
                        imgUrl: provider.logoUrl!,
                        radius: BorderRadius.circular(16.r),
                      ),
                PositionedDirectional(
                  top: 8.h,
                  start: 12.w,
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: AppColors.warningColor100,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          provider.rating == null
                              ? context.tr('home.availableNowNew')
                              : provider.rating!.toStringAsFixed(1),
                          style: TextStyles.font14greyColor900Weight500,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            provider.providerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font20greyColor900W600.copyWith(height: 1.2),
          ),
          SizedBox(height: 3.h),
          Text(
            _meta(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.font12greyColor500W400,
          ),
          const Spacer(),
          if (provider.closesAt.isNotEmpty)
            Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.greenColor500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      context.tr(
                        'home.availableNowCloses',
                        args: [_formatClosingTime(context, provider.closesAt)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font14greyColor900Weight600.copyWith(
                        color: AppColors.greenColor600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  String _meta(BuildContext context) {
    final distance = provider.distanceKm;
    return [
      provider.categoryName,
      provider.branchName,
      if (showDistance && distance != null)
        context.tr(
          'home.availableNowDistance',
          args: [_compactNumber(distance)],
        ),
    ].where((value) => value.trim().isNotEmpty).join(' · ');
  }
}

class AvailableNowShimmerCard extends StatelessWidget {
  final double? width;

  const AvailableNowShimmerCard({super.key, this.width});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.greyColor100,
    highlightColor: AppColors.greyColor50,
    child: _CardSurface(
      width: width ?? 190.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 116.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 14.h),
          Container(height: 18.h, color: AppColors.whiteColor),
          SizedBox(height: 8.h),
          Container(height: 12.h, color: AppColors.whiteColor),
          const Spacer(),
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CardSurface extends StatelessWidget {
  final double width;
  final Widget child;

  const _CardSurface({required this.width, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 249.h,
    padding: EdgeInsets.all(6.w),
    decoration: BoxDecoration(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(color: AppColors.greyColor50),
      boxShadow: [
        BoxShadow(
          color: AppColors.greyColor900.withValues(alpha: .06),
          blurRadius: 16.r,
          offset: Offset(0, 6.h),
        ),
      ],
    ),
    child: child,
  );
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffF5F5F5), Color(0xffD9D2D6), Color(0xff322935)],
      ),
    ),
  );
}

String _compactNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _formatClosingTime(BuildContext context, String value) {
  final parts = value.split(':');
  if (parts.length < 2) return value;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) return value;
  return DateFormat(
    'h:mm a',
    context.locale.toString(),
  ).format(DateTime(2000, 1, 1, hour, minute));
}
