part of '../home_design_widgets.dart';

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

class HomeProviderScroller extends StatelessWidget {
  final bool wide;
  final bool showDistance;

  const HomeProviderScroller({
    super.key,
    this.wide = false,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    if (wide) {
      final providers = [
        _AvailableProvider(
          titleKey: 'home.providerCaptain',
          metaKey: 'home.providerCaptainMeta',
          slotKey: 'home.availableSlotCaptain',
          rating: '4.9',
          fast: true,
        ),
        _AvailableProvider(
          titleKey: 'home.providerHoda',
          metaKey: 'home.providerHodaMeta',
          slotKey: 'home.availableSlotHoda',
          rating: '4.8',
          fast: false,
        ),
        _AvailableProvider(
          titleKey: 'home.providerFriends',
          metaKey: 'home.providerFriendsMeta',
          slotKey: 'home.availableSlotFriends',
          rating: '4.7',
          fast: false,
        ),
      ];
      return _HorizontalList(
        height: 263.h,
        children: providers
            .map(
              (provider) => _AvailableProviderCard(
                provider: provider,
                showDistance: showDistance,
              ),
            )
            .toList(),
      );
    }

    final providers = [
      (
        'home.providerCaptain',
        'home.providerCaptainMeta',
        'home.providerBadgeTopRated',
        'home.availableSlotCaptain',
        '4.9',
      ),
      (
        'home.providerFriends',
        'home.providerFriendsMeta',
        'home.providerBadgeNearest',
        'home.availableSlotFriends',
        '4.6',
      ),
      (
        'home.providerRose',
        'home.providerRoseMeta',
        'home.providerBadgeTopRated',
        'home.availableSlotHoda',
        '4.7',
      ),
      (
        'home.providerDerma',
        'home.providerDermaMeta',
        'home.providerBadgeNearest',
        'home.availableSlotCaptain',
        '4.8',
      ),
    ];
    return _HorizontalList(
      height: wide ? 245.h : 266.h,
      children: providers
          .asMap()
          .entries
          .map(
            (entry) => _ProviderCard(
              titleKey: entry.value.$1,
              metaKey: entry.value.$2,
              badgeKey: entry.value.$3,
              slotKey: entry.value.$4,
              rating: entry.value.$5,
              rank: entry.key + 1,
              width: wide ? 190.w : 190.w,
              height: wide ? 233.h : 244.h,
              showDistance: showDistance,
            ),
          )
          .toList(),
    );
  }
}

class _AvailableProviderCard extends StatelessWidget {
  final _AvailableProvider provider;
  final bool showDistance;

  const _AvailableProviderCard({
    required this.provider,
    required this.showDistance,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 190.w,
      height: 249.h,
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          SizedBox(
            height: 116.h,
            child: Stack(
              children: [
                const _PhotoBox(width: double.infinity, height: 140),
                PositionedDirectional(
                  top: 8.h,
                  start: 12.w,
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: AppColors.warningColor100,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          provider.rating,
                          style: TextStyles.font14greyColor900Weight500,
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.fast)
                  PositionedDirectional(
                    bottom: 12.h,
                    end: 12.w,
                    child: Container(
                      height: 34.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor0,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('home.fastBooking'),
                            style: TextStyles.font14greyColor900Weight600
                                .copyWith(color: AppColors.errorColor200),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.trending_up_rounded,
                            size: 16.sp,
                            color: AppColors.errorColor200,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(provider.titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font24greyColor900Weight600.copyWith(
                fontSize: 20.sp,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              _providerMeta(context, provider.metaKey, showDistance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font14greyColor500W400,
            ),
          ),
          const Spacer(),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                color: AppColors.greenColor505,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.greenColor500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    context.tr(provider.slotKey),
                    style: TextStyles.font16greyColor900Weight600.copyWith(
                      color: AppColors.greenColor600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String titleKey;
  final String metaKey;
  final String badgeKey;
  final String slotKey;
  final String rating;
  final int rank;
  final double width;
  final double height;
  final bool showDistance;

  const _ProviderCard({
    required this.titleKey,
    required this.metaKey,
    required this.badgeKey,
    required this.slotKey,
    required this.rating,
    required this.rank,
    required this.width,
    required this.height,
    required this.showDistance,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: width,
      height: height,
      padding: EdgeInsets.all(7.w),
      child: Column(
        children: [
          SizedBox(
            height: 122.h,
            child: Stack(
              children: [
                const _PhotoBox(width: double.infinity, height: 140),
                PositionedDirectional(
                  top: 12.h,
                  start: 12.w,
                  child: Container(
                    height: 34.h,
                    constraints: BoxConstraints(maxWidth: 118.w),
                    padding: EdgeInsets.symmetric(horizontal: 13.w),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyColor900.withValues(alpha: 0.18),
                          blurRadius: 12.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        context.tr(badgeKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font14greyColor900Weight600.copyWith(
                          color: AppColors.greenColor600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font16greyColor900Weight600.copyWith(
                height: 1.15,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              _providerMeta(context, metaKey, showDistance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 34.h,
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr(slotKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font16greyColor900Weight600.copyWith(
                          color: AppColors.greenColor600,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.greenColor500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18.sp,
                        color: AppColors.warningColor100,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        rating,
                        style: TextStyles.font16greyColor900Weight600,
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

String _providerMeta(BuildContext context, String key, bool showDistance) {
  final text = context.tr(key);
  if (showDistance) return text;
  final separatorIndex = text.indexOf('·');
  return separatorIndex == -1 ? text : text.substring(0, separatorIndex).trim();
}
