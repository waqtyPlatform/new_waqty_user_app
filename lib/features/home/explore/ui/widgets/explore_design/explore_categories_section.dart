part of '../explore_design_widgets.dart';

class ExploreCategoriesSection extends StatelessWidget {
  const ExploreCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCategoriesCubit, ExploreCategoriesState>(
      builder: (context, state) {
        if (state is ExploreCategoriesInitialState ||
            state is ExploreCategoriesLoadingState) {
          return const HomeCategoriesShimmer(expanded: true);
        }
        if (state is ExploreCategoriesLoadedState) {
          return HomeCategoriesRow(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
          onCategorySelected: context
                .read<ExploreCategoriesCubit>()
                .selectCategory,
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
            expanded: true,
            showAll: false,
          );
        }
        return const HomeCategoriesRow(expanded: true, showAll: false);
      },
    );
  }
}
