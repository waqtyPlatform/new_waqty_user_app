import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';

class SplashBackgroundLayers extends StatelessWidget {
  final Animation<double> opacityAnimation;
  final Animation<double> glowScaleAnimation;

  const SplashBackgroundLayers({
    required this.opacityAnimation,
    required this.glowScaleAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -22.5.w,
          top: 145.h,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Transform.scale(
              scale: glowScaleAnimation.value,
              child: SvgPicture.asset(
                ImageAsset.greenAmbientGlow,
                width: 420.w,
                height: 420.w,
              ),
            ),
          ),
        ),
        Positioned(
          left: -180.w,
          top: 560.h,
          child: Opacity(
            opacity: 0.12 * opacityAnimation.value,
            child: SvgPicture.asset(
              ImageAsset.waqtySymbolGreen,
              width: 440.w,
              height: 440.w,
            ),
          ),
        ),
      ],
    );
  }
}
