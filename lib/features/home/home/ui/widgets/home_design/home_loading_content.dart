part of '../home_design_widgets.dart';

class HomeLoadingContent extends StatelessWidget {
  const HomeLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeSkeletonShimmer(
      child: ListView(
        padding: EdgeInsets.only(bottom: 116.h),
        children: [
          _LoadingHeader(),
          _LoadingSearchBar(),
          _LoadingCategoryScroller(),
          _LoadingAppointmentCard(),
          _LoadingSmallCard(),
          _LoadingSectionHeader(),
          _LoadingProviderScroller(),
        ],
      ),
    );
  }
}

class _HomeSkeletonShimmer extends StatelessWidget {
  final Widget child;

  const _HomeSkeletonShimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E2DC),
      highlightColor: const Color(0xFFF4F3EF),
      child: child,
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 8,
      child: SizedBox(
        height: 44.h,
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: const _SkeletonCircle(size: 44),
            ),
            Positioned.fill(
              left: 96.w,
              right: 58.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _SkeletonLine(width: 88.w, height: 10.h),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _SkeletonLine(width: 120.w, height: 16.h),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SkeletonCircle(size: 44),
                  SizedBox(width: 8.w),
                  const _SkeletonCircle(size: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSearchBar extends StatelessWidget {
  const _LoadingSearchBar();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 14,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: _deepShadow(),
        ),
        child: Row(
          children: [
            const _SkeletonCircle(size: 38),
            SizedBox(width: 12.w),
            Expanded(child: _SkeletonLine(height: 16.h)),
            SizedBox(width: 12.w),
            const _SkeletonCircle(size: 38),
          ],
        ),
      ),
    );
  }
}

class _LoadingCategoryScroller extends StatelessWidget {
  const _LoadingCategoryScroller();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.h,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => const _LoadingCategoryTile(),
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: 6,
      ),
    );
  }
}

class _LoadingCategoryTile extends StatelessWidget {
  const _LoadingCategoryTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      padding: EdgeInsets.fromLTRB(6.w, 13.h, 6.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SkeletonCircle(size: 24),
          _SkeletonLine(width: 36.w, height: 8.h),
        ],
      ),
    );
  }
}

class _LoadingAppointmentCard extends StatelessWidget {
  const _LoadingAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 12,
      child: Container(
        height: 210.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEA),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 26.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _SkeletonLine(width: 120.w, height: 12.h),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _SkeletonLine(width: 110.w, height: 24.h),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 82.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _SkeletonBox(width: 82.w, height: 82.h, radius: 18),
                  ),
                  Positioned.fill(
                    left: 96.w,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _SkeletonLine(width: 130.w, height: 14.h),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _SkeletonLine(width: 160.w, height: 10.h),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _SkeletonLine(width: 90.w, height: 10.h),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const _SkeletonCircle(size: 44),
                SizedBox(width: 8.w),
                Expanded(child: _SkeletonBox(height: 44.h, radius: 999)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSmallCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 8,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEA),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonLine(width: 150.w, height: 20.h),
            _SkeletonLine(width: 120.w, height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _LoadingSectionHeader extends StatelessWidget {
  const _LoadingSectionHeader();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 28,
      child: SizedBox(
        height: 38.h,
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _SkeletonLine(width: 54.w, height: 12.h),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SkeletonLine(width: 96.w, height: 16.h),
                  SizedBox(height: 8.h),
                  _SkeletonLine(width: 140.w, height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingProviderScroller extends StatelessWidget {
  const _LoadingProviderScroller();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218.h,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => const _LoadingProviderCard(),
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: 3,
      ),
    );
  }
}

class _LoadingProviderCard extends StatelessWidget {
  const _LoadingProviderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190.w,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEA),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SkeletonBox(width: double.infinity, height: 116.h, radius: 16),
          SizedBox(height: 12.h),
          _SkeletonLine(width: 110.w, height: 12.h),
          SizedBox(height: 8.h),
          _SkeletonLine(width: 80.w, height: 9.h),
          const Spacer(),
          _SkeletonLine(width: 96.w, height: 30.h, radius: 999),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const _SkeletonBox({this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E2DC),
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonLine({this.width, required this.height, this.radius = 999});

  @override
  Widget build(BuildContext context) {
    return _SkeletonBox(width: width, height: height, radius: radius);
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E2DC),
        shape: BoxShape.circle,
      ),
    );
  }
}
