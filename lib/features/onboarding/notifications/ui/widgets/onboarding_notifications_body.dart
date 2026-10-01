import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/onboarding/notifications/ui/widgets/onboarding_notifications_card.dart';
import 'package:waqty_user_application/features/onboarding/notifications/ui/widgets/onboarding_notifications_copy_section.dart';
import 'package:waqty_user_application/features/onboarding/shared/widgets/onboarding_shared_widgets.dart';

class OnboardingNotificationsBody extends StatelessWidget {
  const OnboardingNotificationsBody({super.key});

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
              OnboardingStepsBar(activeIndex: 2),
              OnboardingNotificationsCard(),
              OnboardingNotificationsCopySection(),
              OnboardingBottomActions(
                nextRoute: Routes.onboardingBalanceScreen,
                bottom: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
