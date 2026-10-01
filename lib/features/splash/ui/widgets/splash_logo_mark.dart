import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class SplashLogoMark extends StatelessWidget {
  final AnimationController exitController;
  final Animation<double> symbolScaleAnimation;
  final Animation<Offset> symbolSlideAnimation;
  final Animation<double> symbolExitScaleAnimation;

  const SplashLogoMark({
    required this.exitController,
    required this.symbolScaleAnimation,
    required this.symbolSlideAnimation,
    required this.symbolExitScaleAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);
    final horizontalTarget = isArabic ? 181.5 : -127.5;
    final slideProgress = symbolSlideAnimation.value.dy / -298;

    return Positioned(
      left: 147.5.w,
      top: 325.h,
      child: Transform.translate(
        offset: Offset(
          (horizontalTarget * slideProgress).w,
          symbolSlideAnimation.value.dy.h,
        ),
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 0.55).animate(exitController),
          child: Transform.scale(
            scale: symbolScaleAnimation.value * symbolExitScaleAnimation.value,
            child: SvgPicture.asset(
              ImageAsset.waqtySymbolGreen,
              width: 80.w,
              height: 80.w,
            ),
          ),
        ),
      ),
    );
  }
}
