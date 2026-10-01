import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/onboarding/appointments/ui/widgets/onboarding_appointments_copy_section.dart';
import 'package:waqty_user_application/features/onboarding/appointments/ui/widgets/onboarding_appointments_hero.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingAppointmentsBody extends StatelessWidget {
  const OnboardingAppointmentsBody({super.key});

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
              OnboardingStepsBar(activeIndex: 0),
              OnboardingAppointmentsHero(),
              OnboardingAppointmentsCopySection(),
              OnboardingBottomActions(
                nextRoute: Routes.onboardingBookingScreen,
                bottom: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
