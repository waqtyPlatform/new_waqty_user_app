part of '../home_design_widgets.dart';

class HomeAppointmentCard extends StatelessWidget {
  const HomeAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<HomeCubit, HomeState>(
    listenWhen: (_, current) =>
        current is HomeOnWaySuccessState || current is HomeOnWayErrorState,
    listener: (context, state) {
      final success = state is HomeOnWaySuccessState;
      final serverMessage = state is HomeOnWayErrorState
          ? state.message.trim()
          : '';
      AppConstant.toast(
        success
            ? context.tr('home.onWaySuccess')
            : serverMessage.isEmpty
            ? context.tr('home.onWayError')
            : serverMessage,
        success,
        context,
      );
    },
    buildWhen: (_, current) =>
        current is HomeUpcomingBookingLoadingState ||
        current is HomeUpcomingBookingLoadedState ||
        current is HomeUpcomingBookingErrorState ||
        current is HomeOnWayLoadingState ||
        current is HomeOnWaySuccessState ||
        current is HomeOnWayErrorState,
    builder: (context, state) {
      final cubit = context.read<HomeCubit>();
      if (cubit.upcomingBookingLoading) {
        return const _UpcomingBookingShimmer();
      }
      final booking = cubit.upcomingBooking;
      if (booking == null) return const SizedBox.shrink();
      return _UpcomingBookingCard(
        booking: booking,
        announcing: cubit.announcingOnWay,
      );
    },
  );
}

class _UpcomingBookingCard extends StatelessWidget {
  final UpcomingBookingModel booking;
  final bool announcing;
  const _UpcomingBookingCard({required this.booking, required this.announcing});

  @override
  Widget build(BuildContext context) {
    final time = _bookingTime(context, booking.startTime);
    final hasMap = booking.latitude != null && booking.longitude != null;
    final showOnWay = booking.canAnnounceOnWay;
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
              leftText: booking.paymentStatus == 'paid'
                  ? context.tr('home.paymentPaid')
                  : context.tr(
                      'home.payAtPlaceAmount',
                      args: [_money(booking.price), booking.currency],
                    ),
              rightColor: AppColors.greenColor50,
              leftColor: AppColors.warningColor50,
              dark: true,
              compactLeft: true,
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _BookingTimeTile(
                  label: booking.isToday
                      ? context.tr('home.today')
                      : _shortDate(booking.bookingDate),
                  time: time.$1,
                  period: time.$2,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font16greyColor900Weight600.copyWith(
                          color: AppColors.whiteColor,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${booking.providerName} · ${booking.branchName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.font12greyColor500W400.copyWith(
                          color: AppColors.whiteColor.withValues(alpha: .62),
                        ),
                      ),
                      if (booking.employeeName != null)
                        Text(
                          context.tr(
                            'home.withEmployee',
                            args: [booking.employeeName!],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.font12greyColor500W400.copyWith(
                            color: AppColors.whiteColor.withValues(alpha: .62),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => AppConstant.toast(
                      context.tr('home.appointmentDetailsUnavailable'),
                      false,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                    child: _PillButton(
                      label: context.tr('home.appointmentDetails'),
                      color: AppColors.whiteColor,
                      textColor: AppColors.greyColor900,
                    ),
                  ),
                ),
                if (hasMap) ...[
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => _openBookingMap(booking),
                    customBorder: const CircleBorder(),
                    child: const _CircleButton(
                      icon: Icons.location_on_outlined,
                      dark: true,
                    ),
                  ),
                ],
                if (showOnWay) ...[
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 44.h,
                    child: FilledButton.icon(
                      onPressed: announcing
                          ? null
                          : context.read<HomeCubit>().announceOnWay,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        backgroundColor: AppColors.greenColor500,
                        foregroundColor: AppColors.whiteColor,
                        disabledBackgroundColor: AppColors.greenColor500
                            .withValues(alpha: .55),
                      ),
                      icon: announcing
                          ? SizedBox.square(
                              dimension: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.whiteColor,
                              ),
                            )
                          : Icon(Icons.directions_car_outlined, size: 16.sp),
                      label: Text(
                        context.tr(
                          booking.onWayAnnouncedAt == null
                              ? 'home.onMyWay'
                              : 'home.onMyWayAgain',
                        ),
                        style: TextStyles.font12whiteColorWeight600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTimeTile extends StatelessWidget {
  final String label, time, period;
  const _BookingTimeTile({
    required this.label,
    required this.time,
    required this.period,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 82.w,
    height: 82.w,
    decoration: BoxDecoration(
      color: AppColors.whiteColor.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18.r),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyles.font12whiteColorWeight600.copyWith(
            color: AppColors.whiteColor.withValues(alpha: .7),
          ),
        ),
        Text(
          time,
          style: TextStyles.font32greyColor900Weight600.copyWith(
            color: AppColors.whiteColor,
            height: 1.1,
          ),
        ),
        Text(
          period,
          style: TextStyles.font12whiteColorWeight600.copyWith(
            color: AppColors.whiteColor.withValues(alpha: .7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _UpcomingBookingShimmer extends StatelessWidget {
  const _UpcomingBookingShimmer();
  @override
  Widget build(BuildContext context) => _SectionPadding(
    top: 16,
    child: Shimmer.fromColors(
      baseColor: AppColors.greyColor100,
      highlightColor: AppColors.greyColor50,
      child: Container(
        height: 198.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    ),
  );
}

(String, String) _bookingTime(BuildContext context, String value) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.isEmpty ? '' : parts.first) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final formatted = MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59)),
    alwaysUse24HourFormat: false,
  );
  final split = formatted.trim().split(' ');
  return (split.first, split.length > 1 ? split.sublist(1).join(' ') : '');
}

String _shortDate(String value) {
  final parts = value.split('-');
  return parts.length == 3 ? '${parts[2]}/${parts[1]}' : value;
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

Future<void> _openBookingMap(UpcomingBookingModel booking) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '${booking.latitude},${booking.longitude}',
  });
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class HomeRatingCard extends StatelessWidget {
  const HomeRatingCard({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeCubit, HomeState>(
    buildWhen: (_, current) =>
        current is HomePendingRatingsLoadingState ||
        current is HomePendingRatingsLoadedState ||
        current is HomePendingRatingsErrorState ||
        current is HomePendingRatingSelectionState,
    builder: (context, state) {
      final cubit = context.read<HomeCubit>();
      if (cubit.pendingRatingsLoading) {
        return _SectionPadding(
          top: 8,
          child: Shimmer.fromColors(
            baseColor: AppColors.greyColor100,
            highlightColor: AppColors.greyColor50,
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          ),
        );
      }
      if (cubit.pendingRatings.isEmpty) return const SizedBox.shrink();
      final rating = cubit.pendingRatings.first;
      final selectedValue =
          cubit.selectedRatingBookingUuid == rating.bookingUuid
          ? cubit.selectedRatingValue
          : 0;
      return _SectionPadding(
        top: 8,
        child: _WhiteCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('home.rateLastVisit'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.font16greyColor900Weight600,
                        ),
                        Text(
                          _ratingSubtitle(rating),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.font12greyColor500W400,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return InkWell(
                        onTap: () => cubit.selectPendingRating(
                          rating.bookingUuid,
                          value,
                        ),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Icon(
                            value <= selectedValue
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.warningColor100,
                            size: 22.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              if (selectedValue > 0) ...[
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 36.h,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.greyColor900,
                        foregroundColor: AppColors.whiteColor,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => AppConstant.toast(
                        context.tr('home.ratingApiPending'),
                        false,
                        context,
                      ),
                      child: Text(context.tr('home.sendRating')),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _ratingSubtitle(PendingRatingModel rating) {
  return [
    rating.serviceName,
    rating.providerName,
  ].where((value) => value.trim().isNotEmpty).join(' · ');
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
                  PositionedDirectional(
                    start: 64.w,
                    end: 0,
                    top: 0,
                    bottom: 0,
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
                  PositionedDirectional(
                    start: 0,
                    end: 112.w,
                    top: 0,
                    bottom: 0,
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
