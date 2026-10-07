part of '../explore_design_widgets.dart';

class ExploreContent extends StatelessWidget {
  final bool locationDisabled;
  final VoidCallback? onLocationRequested;
  final Future<void> Function(Position position)? onCurrentLocationSelected;

  const ExploreContent({
    super.key,
    this.locationDisabled = false,
    this.onLocationRequested,
    this.onCurrentLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExploreHeader(),
        const ExploreSearchBar(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: 156.h),
            children: [
              if (locationDisabled)
                HomeLocationDisabledCard(
                  requestLocation: true,
                  onLocationRequested: onLocationRequested,
                  onCurrentLocationSelected: onCurrentLocationSelected,
                )
              else
                const ExploreCategoriesSection(),
            ],
          ),
        ),
      ],
    );
  }
}
