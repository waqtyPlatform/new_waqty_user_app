import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class OnboardingBackgroundSymbol extends StatelessWidget {
  const OnboardingBackgroundSymbol({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: -150.w,
      top: 110.h,
      child: Opacity(
        opacity: 0.04,
        child: SvgPicture.asset(
          ImageAsset.waqtySymbolGreen,
          width: 440.w,
          height: 440.w,
        ),
      ),
    );
  }
}

class OnboardingHeaderBar extends StatelessWidget {
  const OnboardingHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    final skipArrowAngle = math.pi / 2;
    final skipIcon = Transform.rotate(
      angle: skipArrowAngle,
      child: SvgPicture.asset(
        ImageAsset.chevronDown,
        width: 14.w,
        height: 14.w,
      ),
    );
    final skipText = Text(
      context.tr('onboardingAppointments.skip'),
      style: TextStyles.font16greyColor900Weight400.copyWith(height: 1.3),
    );
    final skip = GestureDetector(
      onTap: () =>
          completeOnboardingAndNavigate(context, Routes.registerScreen),
      child: Container(
        height: 34.h,
        padding: EdgeInsetsDirectional.only(start: 12.w, end: 14.w),
        decoration: BoxDecoration(
          color: AppColors.greyColor900.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
          ),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          children: [
            skipText,
            SizedBox(width: 6.w),
            skipIcon,
          ],
        ),
      ),
    );
    final actions = Row(
      children: [
        skip,
        SizedBox(width: 8.w),
        const OnboardingLanguageToggle(),
      ],
    );
    final brand = Row(
      children: [
        SvgPicture.asset(
          ImageAsset.waqtySymbolGreen,
          width: 26.w,
          height: 26.w,
        ),
        SizedBox(width: 8.w),
        Text(
          context.tr('appName'),
          style: TextStyles.font12greyColor900Weight400,
        ),
      ],
    );

    return Positioned(
      left: 20.w,
      right: 20.w,
      top: 54.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [brand, actions],
      ),
    );
  }
}

class OnboardingLanguageToggle extends StatelessWidget {
  const OnboardingLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.setLocale(const Locale('en', 'US'));
      },
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.greenColor500.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'EN',
          style: TextStyles.font12greenColor500W600.copyWith(fontSize: 13.sp),
        ),
      ),
    );
  }
}

class OnboardingStepsBar extends StatelessWidget {
  final int activeIndex;

  const OnboardingStepsBar({required this.activeIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      top: 102.h,
      child: Row(
        children: List.generate(
          5,
          (index) => Expanded(
            child: Container(
              height: 3.h,
              margin: EdgeInsetsDirectional.only(end: index == 4 ? 0 : 4.w),
              decoration: BoxDecoration(
                color: index == activeIndex
                    ? AppColors.greyColor900
                    : AppColors.greyColor900.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingBottomActions extends StatelessWidget {
  final String nextRoute;
  final double bottom;

  const OnboardingBottomActions({
    required this.nextRoute,
    required this.bottom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final nextArrowAngle = math.pi / 2;
    final nextIcon = Container(
      width: 44.w,
      height: 44.w,
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Transform.rotate(
        angle: nextArrowAngle,
        child: Center(
          child: SvgPicture.asset(
            ImageAsset.chevronDown,
            width: 16.w,
            height: 16.w,
          ),
        ),
      ),
    );
    final nextText = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Text(
        context.tr('onboardingAppointments.next'),
        style: TextStyles.font16whiteColorWeight400.copyWith(height: 1.3),
      ),
    );
    final guestLink = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => completeOnboardingAndNavigate(
        context,
        Routes.buttonNavigationBarScreen,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          context.tr('onboardingAppointments.browseAsGuest'),
          style: TextStyles.font14greenColor500Weight600.copyWith(
            fontSize: 16.sp,
          ),
        ),
      ),
    );
    final loginLink = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => completeOnboardingAndNavigate(context, Routes.loginScreen),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          context.tr('onboardingAppointments.login'),
          style: TextStyles.font14greenColor500Weight600.copyWith(
            fontSize: 16.sp,
          ),
        ),
      ),
    );
    final separator = Text(
      '·',
      style: TextStyles.font16greyColor500Weight400.copyWith(
        color: const Color(0xffBFBFBF),
      ),
    );
    final haveAccount = Text(
      context.tr('onboardingAppointments.haveAccount'),
      style: TextStyles.font16greyColor500Weight400,
    );

    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: bottom.h,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(nextRoute),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [nextIcon, nextText],
              ),
            ),
          ),
          SizedBox(height: 26.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              guestLink,
              SizedBox(width: 8.w),
              separator,
              SizedBox(width: 8.w),
              loginLink,
              SizedBox(width: 8.w),
              haveAccount,
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> completeOnboardingAndNavigate(
  BuildContext context,
  String routeName,
) async {
  await CacheHelper.setData(ConstantKeys.saveIsShowIsBoardingToShared, false);
  if (routeName == Routes.buttonNavigationBarScreen) {
    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
  }
  if (!context.mounted) return;
  context.pushNamedAndRemoveUntil(routeName, predicate: (_) => false);
}
