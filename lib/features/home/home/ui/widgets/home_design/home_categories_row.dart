part of '../home_design_widgets.dart';

class HomeCategoriesSection extends StatelessWidget {
  final bool expanded;
  final ValueChanged<HomeCategoryModel>? onCategoryTap;

  const HomeCategoriesSection({super.key, this.expanded = false, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          current is HomeInitialState ||
          current is HomeCategoriesLoadingState ||
          current is HomeCategoriesLoadedState ||
          current is HomeCategoriesErrorState,
      builder: (context, state) {
        if (state is HomeInitialState || state is HomeCategoriesLoadingState) {
          return _HomeSkeletonShimmer(
            child: expanded
                ? const _LoadingCategoryGrid()
                : const _LoadingCategoryScroller(),
          );
        }
        if (state is HomeCategoriesLoadedState) {
          return HomeCategoriesRow(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            onCategorySelected: context.read<HomeCubit>().selectCategory,
            onCategoryTap: onCategoryTap,
            expanded: expanded,
          );
        }
        return HomeCategoriesRow(expanded: expanded);
      },
    );
  }
}

class HomeCategoriesRow extends StatelessWidget {
  final List<HomeCategoryModel>? categories;
  final String? selectedCategoryId;
  final ValueChanged<String?>? onCategorySelected;
  final ValueChanged<HomeCategoryModel>? onCategoryTap;
  final bool expanded;
  final bool showAll;

  const HomeCategoriesRow({
    super.key,
    this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
    this.onCategoryTap,
    this.expanded = false,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      if (showAll)
        (
          label: context.tr('home.categoryAll'),
          imageUrl: null,
          icon: Icons.map_outlined,
          id: null,
          category: null,
        ),
      ...?categories?.map(
        (category) => (
          label: category.name,
          imageUrl: category.iconUrl,
          icon: null,
          id: category.uuid,
          category: category,
        ),
      ),
    ];

    final tiles = items
        .map(
          (item) => _CategoryTile(
            label: item.label,
            imageUrl: item.imageUrl,
            icon: item.icon,
            selected: showAll && item.id == null,
            expanded: expanded,
            onTap: () => onCategorySelected?.call(item.id),
            onCategoryTap: item.category == null
                ? null
                : () => onCategoryTap?.call(item.category!),
          ),
        )
        .toList();

    if (expanded) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.05,
        ),
        itemCount: tiles.length,
        itemBuilder: (_, index) => tiles[index],
      );
    }

    return _HorizontalList(height: 118.h, children: tiles);
  }
}

class HomeCategoriesShimmer extends StatelessWidget {
  final bool expanded;

  const HomeCategoriesShimmer({super.key, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return _HomeSkeletonShimmer(
      child: expanded
          ? const _LoadingCategoryGrid()
          : const _LoadingCategoryScroller(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final bool selected;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onCategoryTap;

  const _CategoryTile({
    required this.label,
    this.imageUrl,
    this.icon,
    required this.selected,
    this.expanded = false,
    this.onTap,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCategoryTap ?? onTap,
      child: Container(
        width: expanded ? double.infinity : 84.w,
        height: expanded ? 116.h : 96.h,
        padding: EdgeInsets.fromLTRB(8.w, expanded ? 18.h : 22.h, 8.w, 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.greyColor900 : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: selected ? _tileDarkShadow() : _tileShadow(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 32.w, height: 32.w, child: _leadingWidget()),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyles.font12greyColor900Weight400.copyWith(
                color: selected ? AppColors.whiteColor : AppColors.greyColor900,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingWidget() {
    if (imageUrl != null) {
      return CachedNetworkImageWidget(
        imgUrl: imageUrl!,
        radius: BorderRadius.circular(10.r),
        fit: BoxFit.cover,
      );
    }
    if (icon != null) {
      return Icon(
        icon,
        size: 24.sp,
        color: selected ? AppColors.whiteColor : AppColors.greyColor900,
      );
    }
    return const SizedBox.shrink();
  }
}
