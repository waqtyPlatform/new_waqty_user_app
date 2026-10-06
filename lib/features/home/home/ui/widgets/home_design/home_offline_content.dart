part of '../home_design_widgets.dart';

class HomeOfflineContent extends StatelessWidget {
  const HomeOfflineContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 116.h),
      children: [
        HomeHeader(),
        HomeSearchBar(),
        const HomeCategoriesRow(),
        _OfflineAppointmentCard(),
        _OfflineErrorCard(),
      ],
    );
  }
}

class _OfflineAppointmentCard extends StatelessWidget {
  const _OfflineAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 16,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.greyColor900,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: _inkShadow(),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 24.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _DotLabel(
                      label: context.tr('home.offlineAppointmentStatus'),
                      color: AppColors.greenColor50,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _Badge(
                      label: context.tr('home.savedOnDevice'),
                      background: AppColors.whiteColor.withValues(alpha: 0.10),
                      color: AppColors.whiteColor.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 82.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _TimeTile(),
                  ),
                  PositionedDirectional(
                    start: 96.w,
                    end: 0,
                    top: 0,
                    bottom: 0,
                    child: _TextBlock(
                      titleKey: 'home.nextService',
                      subtitleKey: 'home.nextProvider',
                      thirdKey: 'home.nextSpecialist',
                      light: true,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 44.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _CircleButton(
                      icon: Icons.location_on_outlined,
                      dark: true,
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    end: 52.w,
                    top: 0,
                    bottom: 0,
                    child: _PillButton(
                      label: context.tr('home.appointmentDetails'),
                      color: AppColors.whiteColor,
                      textColor: AppColors.greyColor900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineErrorCard extends StatelessWidget {
  const _OfflineErrorCard();

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 12,
      child: _WhiteCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(
              height: 96.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.warningColor0,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 20.sp,
                        color: AppColors.warningColor200,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 52.w,
                    end: 0,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('home.offlineTitle'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyles.font16greyColor900Weight600
                              .copyWith(height: 1.3),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          context.tr('home.offlineSubtitle'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyles.font12greyColor500W400.copyWith(
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await MyConnectivity.checkNow();
              },
              child: Container(
                width: double.infinity,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.greyColor900,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('home.retry'),
                      style: TextStyles.font12whiteColorWeight600,
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.refresh_rounded,
                      size: 16.sp,
                      color: AppColors.whiteColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
