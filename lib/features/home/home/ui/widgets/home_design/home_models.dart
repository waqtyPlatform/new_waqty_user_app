part of '../home_design_widgets.dart';

class _CategoryItem {
  final String labelKey;
  final IconData icon;
  final bool selected;

  _CategoryItem(this.labelKey, this.icon, this.selected);
}

class _AvailableProvider {
  final String titleKey;
  final String metaKey;
  final String slotKey;
  final String rating;
  final bool fast;

  const _AvailableProvider({
    required this.titleKey,
    required this.metaKey,
    required this.slotKey,
    required this.rating,
    required this.fast,
  });
}

List<BoxShadow> _cardShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.03),
      blurRadius: 2.r,
      offset: Offset(0, 1.h),
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.16),
      blurRadius: 24.r,
      offset: Offset(0, 10.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _deepShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.20),
      blurRadius: 28.r,
      offset: Offset(0, 12.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _inkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.25),
      blurRadius: 45.r,
      offset: Offset(0, 16.h),
      spreadRadius: -16.r,
    ),
  ];
}

List<BoxShadow> _tileShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.10),
      blurRadius: 16.r,
      offset: Offset(0, 6.h),
      spreadRadius: -10.r,
    ),
  ];
}

List<BoxShadow> _tileDarkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.18),
      blurRadius: 23.r,
      offset: Offset(0, 8.h),
      spreadRadius: -10.r,
    ),
  ];
}

String _homeText(BuildContext context, String key, String fallback) {
  final translated = context.tr(key);
  return translated == key ? fallback : translated;
}
