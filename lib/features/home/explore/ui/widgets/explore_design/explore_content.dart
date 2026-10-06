part of '../explore_design_widgets.dart';

class ExploreContent extends StatelessWidget {
  const ExploreContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 156.h),
      children: [
        const ExploreHeader(),
        const ExploreSearchBar(),
        const ExploreCategoriesSection(),
      ],
    );
  }
}
