import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/home/data/models/nearby_offer_model.dart';

class NearbyOfferCard extends StatelessWidget {
  final NearbyOfferModel offer;
  final double? width;

  const NearbyOfferCard({super.key, required this.offer, this.width});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).pushNamed(
      Routes.providerDetailsScreen,
      arguments: {
        'provider_uuid': offer.providerUuid,
        'provider_name': offer.providerName,
        'branch_uuid': offer.branchUuid,
        'branch_name': offer.branchName,
        'package_uuid': offer.packageUuid,
      },
    ),
    child: Container(
      width: width ?? 322.w,
      height: 184.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0B0D0F), Color(0xFF15161B), Color(0xFF202126)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: .12),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30.h,
              child: offer.daysRemaining == null
                  ? null
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        height: 30.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.greenColor500.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.tr(
                            'home.nearbyOfferEndsIn',
                            args: ['${offer.daysRemaining}'],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.font12whiteColorWeight600.copyWith(
                            color: AppColors.greenColor50,
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 10.h),
            Text(
              context.tr(
                'home.nearbyOfferDiscount',
                args: ['${offer.discountPercentage}'],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font20greyColor900W600.copyWith(
                color: AppColors.whiteColor,
                fontSize: 27.sp,
                height: 1.1,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '${offer.packageName} - ${context.tr('home.nearbyOfferSessions', args: ['${offer.sessionsIncluded}'])}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font14whiteColorWeight400.copyWith(
                color: AppColors.whiteColor.withValues(alpha: .86),
              ),
            ),
            const Spacer(),
            Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: AppColors.whiteColor.withValues(alpha: .08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 16.sp,
                    color: AppColors.greenColor50,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${offer.providerName} · ${context.tr('home.nearbyOfferPrice', args: [_price(offer.packagePrice), _price(offer.originalTotal)])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font12whiteColorWeight600.copyWith(
                        color: AppColors.whiteColor.withValues(alpha: .72),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class NearbyOfferShimmerCard extends StatelessWidget {
  final double? width;

  const NearbyOfferShimmerCard({super.key, this.width});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.greyColor100,
    highlightColor: AppColors.greyColor0,
    child: Container(
      width: width ?? 322.w,
      height: 184.h,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
    ),
  );
}

String _price(double value) => NumberFormat('#,##0.##').format(value);
