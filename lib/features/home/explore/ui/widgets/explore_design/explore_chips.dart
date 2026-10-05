part of '../explore_design_widgets.dart';

class ExploreCategoryChips extends StatelessWidget {
  const ExploreCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ExploreChipData('home.categoryAll', Icons.map_outlined, true),
      _ExploreChipData(
        'home.categoryBarber',
        Icons.content_cut_rounded,
        false,
        tint: AppColors.blueColor0,
      ),
      _ExploreChipData(
        'home.categoryHair',
        Icons.brush_outlined,
        false,
        tint: AppColors.warningColor0,
      ),
      _ExploreChipData(
        'home.categoryDermatology',
        Icons.spa_outlined,
        false,
        tint: AppColors.greenColor505,
      ),
      _ExploreChipData(
        'home.categoryDental',
        Icons.medical_services_outlined,
        false,
        tint: AppColors.greyColor0,
      ),
      _ExploreChipData(
        'home.categoryMassage',
        Icons.self_improvement_rounded,
        false,
        tint: AppColors.errorColor0,
      ),
      _ExploreChipData(
        'home.categoryNails',
        Icons.back_hand_outlined,
        false,
        tint: AppColors.blueColor25,
      ),
    ];

    return _ExploreHorizontalChips(
      top: 4,
      children: items
          .map(
            (item) => _ExploreChip(
              label: context.tr(item.labelKey),
              icon: item.icon,
              selected: item.selected,
              tint: item.selected ? AppColors.greyColor900 : item.tint,
            ),
          )
          .toList(),
    );
  }
}

class ExploreFilterChips extends StatelessWidget {
  const ExploreFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ExploreChipData('explore.nearest', Icons.location_on_outlined, true),
      _ExploreChipData('explore.topRated', Icons.star_rounded, false),
      _ExploreChipData('explore.availableToday', Icons.schedule, false),
      _ExploreChipData('explore.lowestPrice', Icons.payments_outlined, false),
    ];

    return _ExploreHorizontalChips(
      top: 10,
      children: items
          .map(
            (item) => _ExploreChip(
              label: context.tr(item.labelKey),
              icon: item.icon,
              selected: item.selected,
              tint: AppColors.whiteColor,
              width: item.selected ? 104.w : null,
            ),
          )
          .toList(),
    );
  }
}

class _ExploreHorizontalChips extends StatelessWidget {
  final double top;
  final List<Widget> children;

  const _ExploreHorizontalChips({required this.top, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h + top.h,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: children.length,
      ),
    );
  }
}

class _ExploreChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color tint;
  final double? width;

  const _ExploreChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tint,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? AppColors.whiteColor : AppColors.greyColor900;
    final chipIcon = Icon(icon, size: 15.sp, color: textColor);
    final chipText = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor900Weight400.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      width: width,
      height: selected ? 40.h : 36.h,
      padding: EdgeInsets.symmetric(horizontal: selected ? 14.w : 12.w),
      decoration: BoxDecoration(
        color: selected ? AppColors.greyColor900 : tint,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: selected ? AppColors.greyColor900 : AppColors.greyColor50,
        ),
      ),
      child: Row(
        mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          chipText,
          SizedBox(width: 6.w),
          chipIcon,
        ],
      ),
    );
  }
}
