import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/onboarding/booking/ui/widgets/onboarding_booking_card.dart';
import 'package:waqty_user_application/features/onboarding/booking/ui/widgets/onboarding_booking_copy_section.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingBookingBody extends StatelessWidget {
  const OnboardingBookingBody({super.key});

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
              OnboardingStepsBar(activeIndex: 1),
              OnboardingBookingCard(),
              OnboardingBookingCopySection(),
              OnboardingBottomActions(
                nextRoute: Routes.onboardingNotificationsScreen,
                bottom: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
