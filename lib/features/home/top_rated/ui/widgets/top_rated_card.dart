import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/cached_network_image.dart';
import 'package:waqty_user_application/features/home/home/data/models/top_rated_provider_model.dart';

class TopRatedCard extends StatelessWidget {
  final TopRatedProviderModel provider;
  final bool showDistance;
  final double? width;

  const TopRatedCard({
    super.key,
    required this.provider,
    required this.showDistance,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = provider.rating != null && provider.ratingCount > 0;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        Routes.providerDetailsScreen,
        arguments: {
          'provider_uuid': provider.providerUuid,
          'provider_name': provider.providerName,
          'branch_uuid': provider.branchUuid,
          'branch_name': provider.branchName,
          'category_name': provider.categoryName,
          'logo_path': provider.logoUrl,
          'rating': provider.rating,
          'rating_count': provider.ratingCount,
        },
      ),
      child: Container(
        width: width ?? 190.w,
        height: 245.h,
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.greyColor100),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: .08),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 116.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  provider.logoUrl == null
                      ? const _TopRatedPhotoPlaceholder()
                      : CachedNetworkImageWidget(
                          imgUrl: provider.logoUrl!,
                          radius: BorderRadius.circular(16.r),
                        ),
                  PositionedDirectional(
                    top: 8.h,
                    start: 10.w,
                    child: Container(
                      height: 34.h,
                      constraints: BoxConstraints(maxWidth: 130.w),
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(999.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greyColor900.withValues(
                              alpha: .14,
                            ),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.tr(
                          hasRating
                              ? 'home.topRatedBadge'
                              : 'home.availableNowNew',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greenColor500W600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              provider.providerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font16greyColor900Weight600.copyWith(
                height: 1.15,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              _providerMeta(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font12greyColor500W400,
            ),
            const Spacer(),
            SizedBox(
              height: 34.h,
              child: Row(
                children: [
                  if (hasRating) ...[
                    Icon(
                      Icons.star_rounded,
                      size: 17.sp,
                      color: AppColors.warningColor100,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      provider.rating!.toStringAsFixed(1),
                      style: TextStyles.font14greyColor900Weight500,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        context.tr(
                          'home.topRatedReviews',
                          args: ['${provider.ratingCount}'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        context.tr('home.topRatedNoReviews'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _providerMeta(BuildContext context) {
    final parts = <String>[
      if (provider.categoryName.isNotEmpty) provider.categoryName,
      if (provider.branchName.isNotEmpty) provider.branchName,
      if (showDistance && provider.distanceKm != null)
        context.tr(
          'home.availableNowDistance',
          args: [_distance(provider.distanceKm!)],
        ),
    ];
    return parts.join(' · ');
  }
}

class TopRatedShimmerCard extends StatelessWidget {
  final double? width;

  const TopRatedShimmerCard({super.key, this.width});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.greyColor100,
    highlightColor: AppColors.greyColor0,
    child: Container(
      width: width ?? 190.w,
      height: 245.h,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
    ),
  );
}

class _TopRatedPhotoPlaceholder extends StatelessWidget {
  const _TopRatedPhotoPlaceholder();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [Color(0xFFF0EDF0), Color(0xFF4D454E)],
      ),
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

String _distance(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
