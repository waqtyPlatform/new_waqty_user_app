part of '../explore_design_widgets.dart';

class ExploreEmptyContent extends StatelessWidget {
  const ExploreEmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExploreStateContent(
      icon: Icons.search_off_rounded,
      titleKey: 'explore.emptyTitle',
      subtitleKey: 'explore.emptySubtitle',
      primaryActionKey: 'explore.emptyPrimaryAction',
      secondaryActionKey: 'explore.emptySecondaryAction',
    );
  }
}

class ExploreOfflineContent extends StatelessWidget {
  const ExploreOfflineContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExploreStateContent(
      icon: Icons.wifi_off_rounded,
      titleKey: 'explore.offlineTitle',
      subtitleKey: 'explore.offlineSubtitle',
      primaryActionKey: 'explore.offlinePrimaryAction',
      secondaryActionKey: 'explore.offlineSecondaryAction',
      warning: true,
    );
  }
}

class _ExploreStateContent extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final String primaryActionKey;
  final String secondaryActionKey;
  final bool warning;

  const _ExploreStateContent({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.primaryActionKey,
    required this.secondaryActionKey,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 156.h),
      children: [
        const ExploreHeader(),
        const ExploreSearchBar(),
        const ExploreCategoriesSection(),
        const ExploreFilterChips(),
        SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            constraints: BoxConstraints(minHeight: 428.h),
            padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 22.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: AppColors.greyColor50),
              boxShadow: _exploreCardShadow(),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ExploreStateIllustration(icon: icon, warning: warning),
                SizedBox(height: 26.h),
                Text(
                  context.tr(titleKey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyles.font24greyColor900Weight600.copyWith(
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  context.tr(subtitleKey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyles.font14greyColor500W400.copyWith(
                    height: 1.65,
                  ),
                ),
                SizedBox(height: 28.h),
                _ExploreStateActionButton(
                  label: context.tr(primaryActionKey),
                  dark: true,
                ),
                SizedBox(height: 12.h),
                _ExploreStateActionButton(
                  label: context.tr(secondaryActionKey),
                  dark: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreStateIllustration extends StatelessWidget {
  final IconData icon;
  final bool warning;

  const _ExploreStateIllustration({required this.icon, required this.warning});

  @override
  Widget build(BuildContext context) {
    final accent = warning
        ? AppColors.warningColor100
        : AppColors.greenColor600;
    final accentBg = warning
        ? AppColors.warningColor0
        : AppColors.greenColor505;

    return SizedBox(
      width: 142.w,
      height: 142.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 142.w,
            height: 142.w,
            decoration: BoxDecoration(
              color: AppColors.sunkenColor,
              shape: BoxShape.circle,
            ),
          ),
          PositionedDirectional(
            top: 12.h,
            end: 8.w,
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: accentBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 14.h,
            start: 10.w,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppColors.greyColor100.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: _exploreButtonShadow(),
            ),
            child: Icon(icon, color: accent, size: 34.sp),
          ),
        ],
      ),
    );
  }
}

class _ExploreStateActionButton extends StatelessWidget {
  final String label;
  final bool dark;

  const _ExploreStateActionButton({required this.label, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? AppColors.greyColor900 : AppColors.sunkenColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor900Weight400.copyWith(
          color: dark ? AppColors.whiteColor : AppColors.greyColor900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
