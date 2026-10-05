part of '../explore_design_widgets.dart';

class ExploreLoadingContent extends StatelessWidget {
  const ExploreLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E2DC),
      highlightColor: const Color(0xFFF4F3EF),
      child: ListView(
        padding: EdgeInsets.only(bottom: 156.h),
        children: [
          const _ExploreLoadingHeader(),
          const _ExploreLoadingSearchBar(),
          const _ExploreLoadingCategoryChips(),
          const _ExploreLoadingFilterChips(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _ExploreSkeletonLine(width: 190.w, height: 10.h),
            ),
          ),
          SizedBox(height: 12.h),
          const _ExploreLoadingGrid(),
        ],
      ),
    );
  }
}

class _ExploreLoadingHeader extends StatelessWidget {
  const _ExploreLoadingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExploreSkeletonLine(width: 112.w, height: 24.h),
                  SizedBox(height: 8.h),
                  _ExploreSkeletonLine(width: 142.w, height: 10.h),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            const _ExploreSkeletonCircle(size: 56),
          ],
        ),
      ),
    );
  }
}

class _ExploreLoadingSearchBar extends StatelessWidget {
  const _ExploreLoadingSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: _exploreSearchShadow(),
        ),
        child: Row(
          children: [
            const _ExploreSkeletonCircle(size: 38),
            SizedBox(width: 12.w),
            Expanded(child: _ExploreSkeletonLine(height: 14.h)),
            SizedBox(width: 12.w),
            const _ExploreSkeletonCircle(size: 38),
          ],
        ),
      ),
    );
  }
}

class _ExploreLoadingCategoryChips extends StatelessWidget {
  const _ExploreLoadingCategoryChips();

  @override
  Widget build(BuildContext context) {
    return _ExploreLoadingChipScroller(
      top: 10,
      heights: [40, 36, 36, 36, 36],
      widths: [66, 78, 84, 82, 72],
    );
  }
}

class _ExploreLoadingFilterChips extends StatelessWidget {
  const _ExploreLoadingFilterChips();

  @override
  Widget build(BuildContext context) {
    return _ExploreLoadingChipScroller(
      top: 8,
      heights: [40, 36, 36, 36],
      widths: [104, 96, 104, 94],
    );
  }
}

class _ExploreLoadingChipScroller extends StatelessWidget {
  final double top;
  final List<double> heights;
  final List<double> widths;

  const _ExploreLoadingChipScroller({
    required this.top,
    required this.heights,
    required this.widths,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h + top.h,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _ExploreSkeletonBox(
            width: widths[index].w,
            height: heights[index].h,
            radius: 999,
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: widths.length,
      ),
    );
  }
}

class _ExploreLoadingGrid extends StatelessWidget {
  const _ExploreLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: 200.h,
        ),
        itemBuilder: (_, __) => const _ExploreLoadingPlaceCard(),
      ),
    );
  }
}

class _ExploreLoadingPlaceCard extends StatelessWidget {
  const _ExploreLoadingPlaceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _exploreCardShadow(),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            start: 0,
            child: _ExploreSkeletonBox(width: 96.w, height: 26.h, radius: 999),
          ),
          PositionedDirectional(
            top: 36.h,
            end: 0,
            child: _ExploreSkeletonBox(width: 86.w, height: 26.h, radius: 999),
          ),
          PositionedDirectional(
            start: 2.w,
            end: 2.w,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExploreSkeletonLine(width: 112.w, height: 15.h),
                SizedBox(height: 8.h),
                _ExploreSkeletonLine(width: 132.w, height: 10.h),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: _ExploreSkeletonLine(height: 10.h)),
                    SizedBox(width: 8.w),
                    _ExploreSkeletonLine(width: 36.w, height: 10.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const _ExploreSkeletonBox({this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _ExploreSkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const _ExploreSkeletonLine({this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return _ExploreSkeletonBox(width: width, height: height, radius: 999);
  }
}

class _ExploreSkeletonCircle extends StatelessWidget {
  final double size;

  const _ExploreSkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
