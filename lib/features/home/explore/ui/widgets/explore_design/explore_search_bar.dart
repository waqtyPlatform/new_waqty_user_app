part of '../explore_design_widgets.dart';

class ExploreSearchBar extends StatefulWidget {
  const ExploreSearchBar({super.key});

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(BuildContext context, String value) {
    context.read<ExploreCategoriesCubit>().search(value);
  }

  @override
  Widget build(BuildContext context) {
    final hintText = context.tr('home.searchPlaceholder');
    final filterButton = _ExploreCircleIcon(
      icon: Icons.tune_rounded,
      background: AppColors.sunkenColor,
      iconColor: AppColors.greyColor900,
      size: 38,
      iconSize: 17,
    );
    final searchButton = _ExploreCircleIcon(
      icon: Icons.search_rounded,
      background: AppColors.greenColor505,
      iconColor: AppColors.greenColor600,
      size: 38,
      iconSize: 19,
    );
    final searchField = Expanded(
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) => context.read<ExploreCategoriesCubit>().search(value),
        onSubmitted: (value) => _submitSearch(context, value),
        textAlign: TextAlign.right,
        textDirection: Directionality.of(context),
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyles.font16greyColor500Weight400.copyWith(height: 1.3),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
      color: AppColors.pageColor.withValues(alpha: 0.9),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: _exploreSearchShadow(),
        ),
        child: Row(
          children: [
            searchButton,
            searchField,
            SizedBox(width: 12.w),
            filterButton,
          ],
        ),
      ),
    );
  }
}
