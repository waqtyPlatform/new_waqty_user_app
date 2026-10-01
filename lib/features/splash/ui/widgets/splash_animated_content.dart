import 'package:flutter/material.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_background_layers.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_logo_mark.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_progress_bar.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_title_block.dart';

class SplashAnimatedContent extends StatelessWidget {
  final AnimationController introController;
  final AnimationController progressController;
  final AnimationController exitController;
  final Animation<double> glowScaleAnimation;
  final Animation<double> symbolScaleAnimation;
  final Animation<Offset> symbolSlideAnimation;
  final Animation<double> symbolExitScaleAnimation;
  final Animation<double> contentOpacityAnimation;

  const SplashAnimatedContent({
    required this.introController,
    required this.progressController,
    required this.exitController,
    required this.glowScaleAnimation,
    required this.symbolScaleAnimation,
    required this.symbolSlideAnimation,
    required this.symbolExitScaleAnimation,
    required this.contentOpacityAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        introController,
        progressController,
        exitController,
      ]),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SplashBackgroundLayers(
              opacityAnimation: contentOpacityAnimation,
              glowScaleAnimation: glowScaleAnimation,
            ),
            SplashLogoMark(
              exitController: exitController,
              symbolScaleAnimation: symbolScaleAnimation,
              symbolSlideAnimation: symbolSlideAnimation,
              symbolExitScaleAnimation: symbolExitScaleAnimation,
            ),
            SplashTitleBlock(opacityAnimation: contentOpacityAnimation),
            SplashProgressBar(
              progressController: progressController,
              opacityAnimation: contentOpacityAnimation,
            ),
          ],
        );
      },
    );
  }
}
