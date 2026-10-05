part of '../home_design_widgets.dart';

class HomeOfferScroller extends StatelessWidget {
  const HomeOfferScroller({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      (
        'home.offerBadge1',
        'home.offerTitle1',
        'home.offerBody1',
        'home.offerMeta1',
      ),
      (
        'home.offerBadge2',
        'home.offerTitle2',
        'home.offerBody2',
        'home.offerMeta2',
      ),
      (
        'home.offerBadge3',
        'home.offerTitle3',
        'home.offerBody3',
        'home.offerMeta3',
      ),
    ];
    return _HorizontalList(
      height: 204.h,
      children: offers
          .map(
            (offer) => _OfferCard(
              badgeKey: offer.$1,
              titleKey: offer.$2,
              bodyKey: offer.$3,
              metaKey: offer.$4,
            ),
          )
          .toList(),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String badgeKey;
  final String titleKey;
  final String bodyKey;
  final String metaKey;

  const _OfferCard({
    required this.badgeKey,
    required this.titleKey,
    required this.bodyKey,
    required this.metaKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322.w,
      height: 184.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.greyColor900,
            const Color(0xFF15161B),
            const Color(0xFF202126),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: _inkShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34.h,
            left: -24.w,
            right: null,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    height: 30.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.greenColor500.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Center(
                      child: Text(
                        context.tr(badgeKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyles.font12whiteColorWeight600.copyWith(
                          color: AppColors.greenColor50,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  context.tr(titleKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 28.sp,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.tr(bodyKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyles.font14whiteColorWeight400.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.88),
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: AppColors.whiteColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 12.w,
                        right: null,
                        child: Icon(
                          Icons.local_offer_outlined,
                          size: 16.sp,
                          color: AppColors.greenColor50,
                        ),
                      ),
                      Positioned.fill(
                        left: 38.w,
                        right: 12.w,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.tr(metaKey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: TextStyles.font12whiteColorWeight600
                                .copyWith(
                                  color: AppColors.whiteColor.withValues(
                                    alpha: 0.72,
                                  ),
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
