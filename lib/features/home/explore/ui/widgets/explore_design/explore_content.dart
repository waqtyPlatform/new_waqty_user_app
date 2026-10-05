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
        const ExploreCategoryChips(),
        const ExploreFilterChips(),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              context.tr('explore.resultsSummary'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        const ExploreResultsGrid(),
      ],
    );
  }
}
