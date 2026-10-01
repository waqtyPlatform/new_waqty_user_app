import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_animated_content.dart';

class SplashScreen extends StatefulWidget {
  final String nextRoute;

  const SplashScreen({required this.nextRoute, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _progressController;
  late final AnimationController _exitController;
  late final Animation<double> _glowScaleAnimation;
  late final Animation<double> _symbolScaleAnimation;
  late final Animation<Offset> _symbolSlideAnimation;
  late final Animation<double> _symbolExitScaleAnimation;
  late final Animation<double> _contentOpacityAnimation;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    _glowScaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: 0.72, end: 1.0));
    _symbolScaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    ).drive(Tween(begin: 0.35, end: 1.0));
    _symbolSlideAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOutSine,
    ).drive(Tween(begin: Offset.zero, end: const Offset(0, -298)));
    _symbolExitScaleAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOutSine,
    ).drive(Tween(begin: 1.0, end: 0.325));
    _contentOpacityAnimation = CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    ).drive(Tween(begin: 1.0, end: 0.0));

    _introController.forward();
    _progressController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      await _exitController.forward();
      _goNext();
    });
  }

  void _goNext() {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(widget.nextRoute, (route) => false);
  }

  @override
  void dispose() {
    _introController.dispose();
    _progressController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyColor900,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.45, -1),
            end: Alignment(0.55, 1),
            colors: [
              AppColors.splashGradientStart,
              AppColors.greyColor900,
              AppColors.splashGradientEnd,
            ],
            stops: [0.06, 0.52, 0.94],
          ),
        ),
        child: SplashAnimatedContent(
          introController: _introController,
          progressController: _progressController,
          exitController: _exitController,
          glowScaleAnimation: _glowScaleAnimation,
          symbolScaleAnimation: _symbolScaleAnimation,
          symbolSlideAnimation: _symbolSlideAnimation,
          symbolExitScaleAnimation: _symbolExitScaleAnimation,
          contentOpacityAnimation: _contentOpacityAnimation,
        ),
      ),
    );
  }
}
