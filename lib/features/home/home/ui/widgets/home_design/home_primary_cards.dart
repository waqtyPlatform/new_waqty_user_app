part of '../home_design_widgets.dart';

class HomeAppointmentCard extends StatelessWidget {
  const HomeAppointmentCard({super.key});

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
            _StatusRow(
              rightText: context.tr('home.nextAppointmentStatus'),
              leftText: context.tr('home.payAtPlace'),
              rightColor: AppColors.greenColor50,
              leftColor: AppColors.warningColor50,
              dark: true,
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
                  Positioned.fill(
                    left: 0,
                    right: 96.w,
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
                  Positioned.fill(
                    left: 52.w,
                    right: 0,
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

class HomeRatingCard extends StatelessWidget {
  const HomeRatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 8,
      child: _WhiteCard(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (_) => Icon(
                    Icons.star_border_rounded,
                    color: AppColors.warningColor100,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              left: 166.w,
              right: 0,
              child: _TextBlock(
                titleKey: 'home.rateLastVisit',
                subtitleKey: 'home.lastVisitMeta',
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWaitlistCard extends StatelessWidget {
  const HomeWaitlistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 12,
      child: _WhiteCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _StatusRow(
              rightText: context.tr('home.waitlistOffer'),
              leftText: context.tr('home.waitlistTimer'),
              rightColor: AppColors.warningColor200,
              leftColor: AppColors.warningColor200,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 68.h,
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: const _PhotoBox(size: 52),
                  ),
                  Positioned.fill(
                    left: 0,
                    right: 64.w,
                    child: _TextBlock(
                      titleKey: 'home.waitlistTitle',
                      subtitleKey: 'home.waitlistMeta',
                      thirdKey: 'home.waitlistNote',
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
                    child: SizedBox(
                      width: 104.w,
                      child: _PillButton(
                        label: context.tr('home.notSuitable'),
                        color: AppColors.sunkenColor,
                        textColor: AppColors.greyColor900,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: 112.w,
                    right: 0,
                    child: _PillButton(
                      label: context.tr('home.bookSlot'),
                      color: AppColors.greyColor900,
                      textColor: AppColors.whiteColor,
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
