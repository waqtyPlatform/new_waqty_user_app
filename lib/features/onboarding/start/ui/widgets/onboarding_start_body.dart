import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingStartBody extends StatelessWidget {
  const OnboardingStartBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: const [
              OnboardingBackgroundSymbol(),
              OnboardingHeaderBar(),
              OnboardingStepsBar(activeIndex: 4),
              _StartCopySection(),
              _StartBenefitsCard(),
              _StartBottomActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartCopySection extends StatelessWidget {
  const _StartCopySection();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Positioned(
      left: 28.w,
      right: 28.w,
      top: 150.h,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isArabic
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            textDirection: ui.TextDirection.ltr,
            children: isArabic
                ? [
                    Text(
                      context.tr('onboardingStart.category'),
                      style: TextStyles.font12greyColor500W600,
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 22.w,
                      height: 1.h,
                      color: AppColors.greenColor600.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 8.w),
                    Text('\u200E05 / 05', style: _stepStyle()),
                  ]
                : [
                    Text('\u200E05 / 05', style: _stepStyle()),
                    SizedBox(width: 8.w),
                    Container(
                      width: 22.w,
                      height: 1.h,
                      color: AppColors.greenColor600.withValues(alpha: 0.4),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr('onboardingStart.category'),
                      style: TextStyles.font12greyColor500W600,
                    ),
                  ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingStart.title'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font32greyColor900Weight600.copyWith(
                fontSize: isArabic ? 30.sp : 29.sp,
                height: 1.18,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('onboardingStart.description'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font16greyColor500Weight400.copyWith(
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _stepStyle() {
    return TextStyles.font12greenColor500W600.copyWith(
      color: AppColors.greenColor600,
      fontSize: 11.sp,
      letterSpacing: 1.1,
      height: 1.5,
    );
  }
}

class _StartBenefitsCard extends StatelessWidget {
  const _StartBenefitsCard();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);

    return Positioned(
      left: 32.w,
      right: 32.w,
      top: 302.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(
            color: AppColors.greyColor900.withValues(alpha: 0.08),
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.14),
              blurRadius: 18.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Column(
          children: [
            _BenefitRow(
              title: context.tr('onboardingStart.benefit1Title'),
              subtitle: context.tr('onboardingStart.benefit1Subtitle'),
              icon: Icons.star_rounded,
              isArabic: isArabic,
            ),
            _BenefitDivider(isArabic: isArabic),
            _BenefitRow(
              title: context.tr('onboardingStart.benefit2Title'),
              subtitle: context.tr('onboardingStart.benefit2Subtitle'),
              icon: Icons.payments_outlined,
              isArabic: isArabic,
            ),
            _BenefitDivider(isArabic: isArabic),
            _BenefitRow(
              title: context.tr('onboardingStart.benefit3Title'),
              subtitle: context.tr('onboardingStart.benefit3Subtitle'),
              icon: Icons.location_on_outlined,
              isArabic: isArabic,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isArabic;

  const _BenefitRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: AppColors.greenColor500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: AppColors.greenColor500, size: 18.w),
    );
    final copy = Expanded(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor900Weight400.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              subtitle,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor500W400.copyWith(
                fontSize: 11.sp,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: 54.h,
      child: Row(
        textDirection: ui.TextDirection.ltr,
        children: isArabic
            ? [copy, SizedBox(width: 14.w), iconBox]
            : [iconBox, SizedBox(width: 14.w), copy],
      ),
    );
  }
}

class _BenefitDivider extends StatelessWidget {
  final bool isArabic;

  const _BenefitDivider({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isArabic ? 0 : 48.w,
        end: isArabic ? 48.w : 0,
      ),
      child: Divider(
        height: 12.h,
        thickness: 1.h,
        color: AppColors.greyColor900.withValues(alpha: 0.06),
      ),
    );
  }
}

class _StartBottomActions extends StatelessWidget {
  const _StartBottomActions();

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);
    final arrowAngle = isArabic ? math.pi / 2 : -math.pi / 2;
    final arrowIcon = Container(
      width: 44.w,
      height: 44.w,
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Transform.rotate(
        angle: arrowAngle,
        child: Center(
          child: SvgPicture.asset(
            ImageAsset.chevronDown,
            width: 16.w,
            height: 16.w,
          ),
        ),
      ),
    );
    final createText = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Text(
        context.tr('onboardingStart.createAccount'),
        style: TextStyles.font16whiteColorWeight400.copyWith(height: 1.3),
      ),
    );
    final haveAccount = Text(
      context.tr('onboardingAppointments.haveAccount'),
      style: TextStyles.font16greyColor500Weight400.copyWith(fontSize: 14.sp),
    );
    final login = Text(
      context.tr('onboardingAppointments.login'),
      style: TextStyles.font14greenColor500Weight600.copyWith(fontSize: 14.sp),
    );

    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 28.h,
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                completeOnboardingAndNavigate(context, Routes.registerScreen),
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.greyColor800, AppColors.greyColor900],
                ),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyColor900.withValues(alpha: 0.5),
                    blurRadius: 20.r,
                    offset: Offset(0, 18.h),
                  ),
                ],
              ),
              child: Row(
                textDirection: ui.TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [arrowIcon, createText]
                    : [createText, arrowIcon],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => completeOnboardingAndNavigate(
              context,
              Routes.buttonNavigationBarScreen,
            ),
            child: Container(
              height: 56.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                border: Border.all(
                  color: AppColors.greyColor900.withValues(alpha: 0.12),
                ),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyColor900.withValues(alpha: 0.08),
                    blurRadius: 14.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Text(
                context.tr('onboardingAppointments.browseAsGuest'),
                style: TextStyles.font16greyColor900Weight400,
              ),
            ),
          ),
          SizedBox(height: 17.h),
          GestureDetector(
            onTap: () =>
                completeOnboardingAndNavigate(context, Routes.loginScreen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: ui.TextDirection.ltr,
              children: isArabic
                  ? [login, SizedBox(width: 6.w), haveAccount]
                  : [haveAccount, SizedBox(width: 6.w), login],
            ),
          ),
        ],
      ),
    );
  }
}
