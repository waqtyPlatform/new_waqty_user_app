import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_booking_card.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_contact_section.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_faq_section.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_header.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_onboarding_card.dart';
import 'package:waqty_user_application/features/account/help/ui/widgets/help_search_bar.dart';

class HelpContent extends StatelessWidget {
  const HelpContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 104.h),
      children: [
        const HelpHeader(),
        SizedBox(height: 14.h),
        const HelpSearchBar(),
        SizedBox(height: 14.h),
        const HelpBookingCard(),
        SizedBox(height: 12.h),
        const HelpOnboardingCard(),
        SizedBox(height: 22.h),
        const HelpFaqSection(),
        SizedBox(height: 22.h),
        const HelpContactSection(),
      ],
    );
  }
}
