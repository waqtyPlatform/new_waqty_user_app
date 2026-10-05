import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingBookingCard extends StatelessWidget {
  const OnboardingBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      top: 128.h,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(
            color: AppColors.greyColor900.withValues(alpha: 0.08),
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.18),
              blurRadius: 24.r,
              offset: Offset(0, 24.h),
            ),
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.08),
              blurRadius: 2.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TimelineColumn(),
            SizedBox(width: 14.w),
            const Expanded(child: _BookingStepsContent()),
          ],
        ),
      ),
    );
  }
}

class _BookingStepsContent extends StatelessWidget {
  const _BookingStepsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          leftText: context.tr('onboardingBooking.availableToday'),
          rightText: context.tr('onboardingBooking.chooseTime'),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            const Expanded(child: _TimeTile(label: '5:15')),
            SizedBox(width: 6.w),
            const Expanded(child: _TimeTile(label: '4:30', isSelected: true)),
            SizedBox(width: 6.w),
            const Expanded(child: _TimeTile(label: '3:45')),
            SizedBox(width: 6.w),
            const Expanded(child: _TimeTile(label: '3:00', isDisabled: true)),
          ],
        ),
        SizedBox(height: 48.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingBooking.reviewConfirm'),
            textAlign: TextAlign.start,
            style: TextStyles.font12greyColor900Weight400,
          ),
        ),
        SizedBox(height: 10.h),
        const _ConfirmTile(),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: Text(
            context.tr('onboardingBooking.freeCancel'),
            textAlign: TextAlign.start,
            style: TextStyles.font12greyColor4002Weight400,
          ),
        ),
        SizedBox(height: 30.h),
        _SectionHeader(
          leftText: context.tr('onboardingBooking.sentToPlace'),
          rightText: 'WQ-4821',
          isMonoLeft: true,
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: AppColors.greenColor500,
                border: Border.all(
                  color: AppColors.greenColor500.withValues(alpha: 0.18),
                  width: 3.w,
                ),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                context.tr('onboardingBooking.reservedMessage'),
                textAlign: TextAlign.start,
                style: TextStyles.font14greenColor500Weight400.copyWith(
                  color: AppColors.greenColor600,
                  fontSize: 16.sp,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String leftText;
  final String rightText;
  final bool isMonoLeft;

  const _SectionHeader({
    required this.leftText,
    required this.rightText,
    this.isMonoLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText,
          style: isMonoLeft
              ? TextStyles.font12greyColor500W600.copyWith(height: 1.3)
              : TextStyles.font12greyColor4002Weight400,
        ),
        Flexible(
          child: Text(
            rightText,
            textAlign: TextAlign.right,
            style: TextStyles.font12greyColor900Weight400,
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;

  const _TimeTile({
    required this.label,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.greenColor500
            : isDisabled
            ? AppColors.sunkenColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: TextStyles.font12greyColor900Weight400.copyWith(
          color: isSelected
              ? AppColors.whiteColor
              : isDisabled
              ? AppColors.greyColor3003
              : AppColors.greyColor900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConfirmTile extends StatelessWidget {
  const _ConfirmTile();

  @override
  Widget build(BuildContext context) {
    final confirmButton = Container(
      height: 30.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.center,
      child: Text(
        context.tr('onboardingBooking.confirm'),
        style: TextStyles.font12greyColor900Weight400.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.greyColor800, AppColors.greyColor900],
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _ConfirmDetails()),
          SizedBox(width: 10.w),
          confirmButton,
        ],
      ),
    );
  }
}

class _ConfirmDetails extends StatelessWidget {
  const _ConfirmDetails();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingBooking.yourChoice'),
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor3003Weight400,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingBooking.choiceMeta'),
              textAlign: TextAlign.start,
              style: TextStyles.font12whiteColorWeight600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineColumn extends StatelessWidget {
  const _TimelineColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TimelineCircle(label: '1'),
        _TimelineLine(height: 100.h),
        const _TimelineCircle(label: '2'),
        _TimelineLine(height: 100.h),
        Container(
          width: 28.w,
          height: 28.w,
          decoration: const BoxDecoration(
            color: AppColors.greenColor500,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: AppColors.whiteColor, size: 16.w),
        ),
      ],
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final String label;

  const _TimelineCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyles.font12whiteColorWeight600),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  final double height;

  const _TimelineLine({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Container(
        width: 2.w,
        height: height,
        color: AppColors.greyColor900.withValues(alpha: 0.08),
      ),
    );
  }
}
