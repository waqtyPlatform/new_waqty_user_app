part of '../explore_design_widgets.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hintText = context.tr('home.searchPlaceholder');
    final filterButton = _ExploreCircleIcon(
      icon: Icons.tune_rounded,
      background: AppColors.sunkenColor,
      iconColor: AppColors.greyColor900,
      size: 38,
      iconSize: 17,
    );
    final searchButton = _ExploreCircleIcon(
      icon: Icons.search_rounded,
      background: AppColors.greenColor505,
      iconColor: AppColors.greenColor600,
      size: 38,
      iconSize: 19,
    );
    final hint = Expanded(
      child: Text(
        hintText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyles.font16greyColor500Weight400.copyWith(height: 1.3),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
      color: AppColors.pageColor.withValues(alpha: 0.9),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: _exploreSearchShadow(),
        ),
        child: Row(
          children: [
            searchButton,
            hint,
            SizedBox(width: 12.w),
            filterButton,
          ],
        ),
      ),
    );
  }
}
