part of '../home_design_widgets.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final showDistance = context.select<HomeCubit, bool>(
      (cubit) => cubit.location?.hasCoordinates == true,
    );
    return ListView(
      padding: EdgeInsets.only(bottom: 116.h),
      children: [
        HomeHeader(),
        HomeSearchBar(),
        HomeCategoriesSection(
          onCategoryTap: (category) {
            Navigator.of(context).pushNamed(
              category.hasSubcategories
                  ? Routes.subcategoriesScreen
                  : Routes.providersScreen,
              arguments: {
                'category_uuid': category.uuid,
                'title': category.name,
              },
            );
          },
        ),
        HomeAppointmentCard(),
        HomeRatingCard(),
        HomeWaitlistCard(),
        HomeAvailableNowSection(showDistance: showDistance),
        const HomeNearbyOffersSection(),
        const HomeBookAgainSection(),
        HomeTopRatedSection(showDistance: showDistance),
        HomeCategorySection(
          titleKey: 'home.menBarberTitle',
          subtitleKey: 'home.menBarberSubtitle',
          icon: Icons.content_cut_rounded,
        ),
        HomeProviderScroller(showDistance: showDistance),
        HomeCategorySection(
          titleKey: 'home.womenHairTitle',
          subtitleKey: 'home.womenHairSubtitle',
          icon: Icons.brush_outlined,
        ),
        HomeProviderScroller(showDistance: showDistance),
        HomeCategorySection(
          titleKey: 'home.skinClinicsTitle',
          subtitleKey: 'home.skinClinicsSubtitle',
          icon: Icons.spa_outlined,
        ),
        HomeProviderScroller(showDistance: showDistance),
        HomeCategorySection(
          titleKey: 'home.dentalClinicsTitle',
          subtitleKey: 'home.dentalClinicsSubtitle',
          icon: Icons.medical_services_outlined,
        ),
        HomeProviderScroller(showDistance: showDistance),
        HomeSuggestPlaceCard(),
      ],
    );
  }
}
