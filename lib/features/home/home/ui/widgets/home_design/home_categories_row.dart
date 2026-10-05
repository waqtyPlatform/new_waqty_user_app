part of '../home_design_widgets.dart';

class HomeCategoriesRow extends StatelessWidget {
  const HomeCategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _CategoryItem('home.categoryAll', Icons.map_outlined, true),
      _CategoryItem('home.categoryBarber', Icons.content_cut_rounded, false),
      _CategoryItem('home.categoryHair', Icons.brush_outlined, false),
      _CategoryItem('home.categorySkin', Icons.face_retouching_natural, false),
      _CategoryItem('home.categoryDermatology', Icons.spa_outlined, false),
      _CategoryItem(
        'home.categoryDental',
        Icons.medical_services_outlined,
        false,
      ),
      _CategoryItem('home.categoryMassage', Icons.self_improvement, false),
      _CategoryItem('home.categoryNails', Icons.back_hand_outlined, false),
    ];
    return _HorizontalList(
      height: 118.h,
      children: items
          .map(
            (item) => _CategoryTile(
              label: context.tr(item.labelKey),
              icon: item.icon,
              selected: item.selected,
            ),
          )
          .toList(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.w,
      height: 96.h,
      padding: EdgeInsets.fromLTRB(6.w, 22.h, 6.w, 12.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.greyColor900 : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: selected ? _tileDarkShadow() : _tileShadow(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: selected ? AppColors.whiteColor : AppColors.greyColor900,
          ),
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
    );
  }
}
