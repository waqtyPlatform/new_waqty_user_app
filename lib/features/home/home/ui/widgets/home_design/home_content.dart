part of '../home_design_widgets.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 116.h),
      children: [
        HomeHeader(),
        HomeSearchBar(),
        HomeCategoriesRow(),
        HomeAppointmentCard(),
        HomeRatingCard(),
        HomeWaitlistCard(),
        HomeSectionHeader(
          titleKey: 'home.availableTodayTitle',
          subtitleKey: 'home.availableTodaySubtitle',
        ),
        HomeProviderScroller(wide: true),
        HomeSectionHeader(
          titleKey: 'home.nearOffersTitle',
          subtitleKey: 'home.nearOffersSubtitle',
        ),
        HomeOfferScroller(),
        HomeSectionHeader(
          titleKey: 'home.repeatBookingTitle',
          subtitleKey: 'home.repeatBookingSubtitle',
        ),
        HomeRepeatScroller(),
        HomeSectionHeader(
          titleKey: 'home.topRatedTitle',
          subtitleKey: 'home.topRatedSubtitle',
        ),
        HomeProviderScroller(),
        HomeCategorySection(
          titleKey: 'home.menBarberTitle',
          subtitleKey: 'home.menBarberSubtitle',
          icon: Icons.content_cut_rounded,
        ),
        HomeProviderScroller(),
        HomeCategorySection(
          titleKey: 'home.womenHairTitle',
          subtitleKey: 'home.womenHairSubtitle',
          icon: Icons.brush_outlined,
        ),
        HomeProviderScroller(),
        HomeCategorySection(
          titleKey: 'home.skinClinicsTitle',
          subtitleKey: 'home.skinClinicsSubtitle',
          icon: Icons.spa_outlined,
        ),
        HomeProviderScroller(),
        HomeCategorySection(
          titleKey: 'home.dentalClinicsTitle',
          subtitleKey: 'home.dentalClinicsSubtitle',
          icon: Icons.medical_services_outlined,
        ),
        HomeProviderScroller(),
        HomeSuggestPlaceCard(),
      ],
    );
  }
}
