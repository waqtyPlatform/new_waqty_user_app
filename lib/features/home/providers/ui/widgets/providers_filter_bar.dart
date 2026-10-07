import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/providers/logic/providers_cubit.dart';

class ProvidersFilterBar extends StatelessWidget {
  const ProvidersFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProvidersCubit>();
    return SizedBox(
      height: 42.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: context.tr('home.filter'),
            icon: Icons.tune_rounded,
            selected: true,
            onTap: () => context.read<ProvidersCubit>().loadProviders(force: true),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: context.tr('explore.nearest'),
            selected: cubit.nearestSelected,
            onTap: () => context.read<ProvidersCubit>().applyFilter(
              filterKey: 'nearest',
            ),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: context.tr('explore.topRated'),
            selected: cubit.ratingSelected,
            onTap: () => context.read<ProvidersCubit>().applyFilter(
              filterKey: 'rating',
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.greyColor900 : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: AppColors.greyColor100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17.sp, color: AppColors.whiteColor),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyles.font12greyColor900Weight400.copyWith(
                color: selected ? AppColors.whiteColor : AppColors.greyColor900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
