part of '../explore_design_widgets.dart';

class _ExploreCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;
  final double iconSize;
  final bool shadow;

  const _ExploreCircleIcon({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.size = 44,
    this.iconSize = 20,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: shadow ? _exploreButtonShadow() : null,
      ),
      child: Icon(icon, size: iconSize.sp, color: iconColor),
    );
  }
}

List<BoxShadow> _exploreSearchShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.04),
      blurRadius: 2.r,
      offset: Offset(0, 1.h),
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.20),
      blurRadius: 28.r,
      offset: Offset(0, 12.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _exploreButtonShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.18),
      blurRadius: 16.r,
      offset: Offset(0, 6.h),
      spreadRadius: -8.r,
    ),
  ];
}

List<BoxShadow> _exploreCardShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.17),
      blurRadius: 35.r,
      offset: Offset(0, 12.h),
      spreadRadius: -14.r,
    ),
  ];
}
