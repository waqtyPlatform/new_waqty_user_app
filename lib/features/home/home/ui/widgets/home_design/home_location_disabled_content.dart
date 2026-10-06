part of '../home_design_widgets.dart';

class HomeLocationDisabledContent extends StatelessWidget {
  final bool requestLocation;
  final VoidCallback? onLocationRequested;
  final Future<void> Function(Position position)? onCurrentLocationSelected;

  const HomeLocationDisabledContent({
    super.key,
    this.requestLocation = true,
    this.onLocationRequested,
    this.onCurrentLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 116.h),
      children: [
        HomeHeader(),
        HomeSearchBar(),
        const HomeCategoriesRow(),
        _LocationDisabledCard(
          requestLocation: requestLocation,
          onLocationRequested: onLocationRequested,
          onCurrentLocationSelected: onCurrentLocationSelected,
        ),
      ],
    );
  }
}

class _LocationDisabledCard extends StatelessWidget {
  final bool requestLocation;
  final VoidCallback? onLocationRequested;
  final Future<void> Function(Position position)? onCurrentLocationSelected;

  const _LocationDisabledCard({
    required this.requestLocation,
    this.onLocationRequested,
    this.onCurrentLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final titleKey = requestLocation
        ? 'home.locationDisabledTitle'
        : 'home.cityUnavailableTitle';
    final subtitleKey = requestLocation
        ? 'home.locationDisabledSubtitle'
        : 'home.cityUnavailableSubtitle';
    final buttonKey = requestLocation
        ? 'home.enableLocationButton'
        : 'home.suggestButton';

    return _SectionPadding(
      top: 16,
      child: _WhiteCard(
        height: 327.h,
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0EB),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 32.sp,
                color: AppColors.greyColor500,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              context.tr(titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyles.font20greyColor900W600.copyWith(
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.tr(subtitleKey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.75),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: requestLocation
                    ? () async {
                        final position =
                            await YourLocation.requestLocationAccess();
                        if (position != null) {
                          await onCurrentLocationSelected?.call(position);
                        } else {
                          onLocationRequested?.call();
                        }
                      }
                    : null,
                child: _PillButton(
                  label: context.tr(buttonKey),
                  color: AppColors.greyColor900,
                  textColor: AppColors.whiteColor,
                  height: 48,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: Center(
                child: Text(
                  context.tr('home.changeCity'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyles.font12greyColor500W600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
