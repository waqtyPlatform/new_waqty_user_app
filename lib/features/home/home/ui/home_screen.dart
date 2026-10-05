import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_design_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 116.h),
          children: [
            HomeHeader(isArabic: isArabic),
            HomeSearchBar(isArabic: isArabic),
            HomeCategoriesRow(isArabic: isArabic),
            HomeAppointmentCard(isArabic: isArabic),
            HomeRatingCard(isArabic: isArabic),
            HomeWaitlistCard(isArabic: isArabic),
            HomeSectionHeader(
              isArabic: isArabic,
              titleKey: 'home.availableTodayTitle',
              subtitleKey: 'home.availableTodaySubtitle',
            ),
            HomeProviderScroller(isArabic: isArabic, wide: true),
            HomeSectionHeader(
              isArabic: isArabic,
              titleKey: 'home.nearOffersTitle',
              subtitleKey: 'home.nearOffersSubtitle',
            ),
            HomeOfferScroller(isArabic: isArabic),
            HomeSectionHeader(
              isArabic: isArabic,
              titleKey: 'home.repeatBookingTitle',
              subtitleKey: 'home.repeatBookingSubtitle',
            ),
            HomeRepeatScroller(isArabic: isArabic),
            HomeSectionHeader(
              isArabic: isArabic,
              titleKey: 'home.topRatedTitle',
              subtitleKey: 'home.topRatedSubtitle',
            ),
            HomeProviderScroller(isArabic: isArabic),
            HomeCategorySection(
              isArabic: isArabic,
              titleKey: 'home.menBarberTitle',
              subtitleKey: 'home.menBarberSubtitle',
              icon: Icons.content_cut_rounded,
            ),
            HomeProviderScroller(isArabic: isArabic),
            HomeCategorySection(
              isArabic: isArabic,
              titleKey: 'home.womenHairTitle',
              subtitleKey: 'home.womenHairSubtitle',
              icon: Icons.brush_outlined,
            ),
            HomeProviderScroller(isArabic: isArabic),
            HomeCategorySection(
              isArabic: isArabic,
              titleKey: 'home.skinClinicsTitle',
              subtitleKey: 'home.skinClinicsSubtitle',
              icon: Icons.spa_outlined,
            ),
            HomeProviderScroller(isArabic: isArabic),
            HomeCategorySection(
              isArabic: isArabic,
              titleKey: 'home.dentalClinicsTitle',
              subtitleKey: 'home.dentalClinicsSubtitle',
              icon: Icons.medical_services_outlined,
            ),
            HomeProviderScroller(isArabic: isArabic),
            HomeSuggestPlaceCard(isArabic: isArabic),
          ],
        ),
      ),
    );
  }
}
