import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingAppointmentsHero extends StatelessWidget {
  const OnboardingAppointmentsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      top: 118.h,
      height: 286.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.greenColor500.withValues(alpha: 0.12),
                    AppColors.greenColor500.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          _GhostAppointmentCard(
            leadingInset: 54,
            trailingInset: -4,
            top: 0,
            angle: -0.087,
            text: 'الجمعة 18 · 1:00 م',
          ),
          _GhostAppointmentCard(
            leadingInset: 28,
            trailingInset: -4,
            top: 48,
            angle: 0.026,
            text: 'الخميس 17 · 6:30 م',
          ),
          Positioned(
            left: 4.w,
            right: 4.w,
            top: 64.h,
            child: const _MainAppointmentCard(),
          ),
        ],
      ),
    );
  }
}

class _GhostAppointmentCard extends StatelessWidget {
  final double leadingInset;
  final double trailingInset;
  final double top;
  final double angle;
  final String text;

  const _GhostAppointmentCard({
    required this.leadingInset,
    required this.trailingInset,
    required this.top,
    required this.angle,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: leadingInset.w,
      end: trailingInset.w,
      top: top.h,
      height: 92.h,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            border: Border.all(
              color: AppColors.greyColor900.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyColor900.withValues(alpha: 0.12),
                blurRadius: 18.r,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          alignment: AlignmentDirectional.topStart,
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: TextStyles.font12greyColor4002Weight400,
          ),
        ),
      ),
    );
  }
}

class _MainAppointmentCard extends StatelessWidget {
  const _MainAppointmentCard();

  @override
  Widget build(BuildContext context) {
    final nextAppointment = Text(
      context.tr('onboardingAppointments.nextAppointment'),
      style: TextStyles.font12greyColor3003Weight400,
    );
    final confirmedPill = const _ConfirmedPill();
    final directionsButton = const _DirectionsButton();
    final priceMeta = Text(
      context.tr('onboardingAppointments.priceMeta'),
      style: TextStyles.font12greyColor3003Weight400.copyWith(
        color: const Color(0xffDBDBDB),
      ),
    );

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.greyColor800, AppColors.greyColor900],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.62),
            blurRadius: 28.r,
            offset: Offset(0, 28.h),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [nextAppointment, confirmedPill],
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.tr('onboardingAppointments.appointmentTime'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font32greyColor900Weight600.copyWith(
                    color: AppColors.whiteColor,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.tr('onboardingAppointments.appointmentMeta'),
                  textAlign: TextAlign.start,
                  style: TextStyles.font12greyColor3003Weight400,
                ),
              ),
              SizedBox(height: 14.h),
              Divider(
                color: AppColors.whiteColor.withValues(alpha: 0.1),
                height: 1.h,
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [priceMeta, directionsButton],
              ),
            ],
          ),
          const _ReminderPill(),
        ],
      ),
    );
  }
}

class _ConfirmedPill extends StatelessWidget {
  const _ConfirmedPill();

  @override
  Widget build(BuildContext context) {
    const confirmedColor = Color(0xff7BE3A8);

    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: confirmedColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: [
          Text(
            context.tr('onboardingAppointments.confirmed'),
            style: TextStyles.font16greyColor900Weight400.copyWith(
              color: confirmedColor,
              height: 1.3,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: confirmedColor,
              border: Border.all(
                color: confirmedColor.withValues(alpha: 0.25),
                width: 3.w,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsButton extends StatelessWidget {
  const _DirectionsButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.center,
      child: Text(
        context.tr('onboardingAppointments.directions'),
        style: TextStyles.font12greyColor900Weight400.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: -4.w,
      bottom: -32.h,
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.greenColor600,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenColor600.withValues(alpha: 0.7),
              blurRadius: 12.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              context.tr('onboardingAppointments.reminder'),
              style: TextStyles.font16whiteColorWeight400.copyWith(height: 1.3),
            ),
            SizedBox(width: 6.w),
            SvgPicture.asset(
              ImageAsset.scheduleIcon,
              width: 14.w,
              height: 14.w,
            ),
          ],
        ),
      ),
    );
  }
}
