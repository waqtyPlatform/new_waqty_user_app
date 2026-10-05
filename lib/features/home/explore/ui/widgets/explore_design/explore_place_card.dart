part of '../explore_design_widgets.dart';

class ExplorePlaceCard extends StatelessWidget {
  final ExplorePlaceData data;

  const ExplorePlaceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = context.tr(data.titleKey);
    final subtitle = context.tr(data.subtitleKey);

    return Container(
      height: 200.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _exploreCardShadow(),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(data.image, fit: BoxFit.cover)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.40, 1],
                  colors: [
                    Colors.transparent,
                    AppColors.greyColor900.withValues(alpha: 0.08),
                    AppColors.greyColor900.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
          ),
          if (data.slotKey != null)
            PositionedDirectional(
              top: 8.h,
              start: 9.w,
              child: _ExploreMediaPill(
                label: context.tr(data.slotKey!),
                color: AppColors.greenColor600,
              ),
            ),
          if (data.badgeKey != null)
            PositionedDirectional(
              top: 44.h,
              end: 10.w,
              child: _ExploreMediaPill(
                label: context.tr(data.badgeKey!),
                color: AppColors.greyColor600,
              ),
            ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyles.font16whiteColorWeight600.copyWith(
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyles.font12greyColor500W400.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.74),
                  ),
                ),
                SizedBox(height: 6.h),
                _ExploreMetaRow(data: data),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreMetaRow extends StatelessWidget {
  final ExplorePlaceData data;

  const _ExploreMetaRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final metaText = context.tr(data.metaKey);
    final rating = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.rating,
          style: TextStyles.font12whiteColorWeight600.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.star_rounded, size: 13.sp, color: AppColors.warningColor100),
      ],
    );
    final meta = Flexible(
      child: Text(
        metaText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyles.font12whiteColorWeight600.copyWith(
          color: AppColors.whiteColor.withValues(alpha: 0.9),
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        meta,
        SizedBox(width: 5.w),
        rating,
      ],
    );
  }
}

class _ExploreMediaPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ExploreMediaPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      constraints: BoxConstraints(maxWidth: 118.w),
      padding: EdgeInsets.symmetric(horizontal: 9.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.10),
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor500W600.copyWith(color: color),
      ),
    );
  }
}
