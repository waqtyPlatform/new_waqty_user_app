import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';

class ButtonNavigationBarScreen extends StatelessWidget {
  const ButtonNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ButtonNavigationBarCubit, ButtonNavigationBarState>(
      buildWhen: (previous, current) {
        return current is OnBottomNavBarChangedState;
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageColor,
          body: ButtonNavigationBarCubit.get(context).buttonBarBody(),
          extendBody: true,
          bottomNavigationBar: SafeArea(
            minimum: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
            child: _WaqtyBottomNav(
              currentIndex: ButtonNavigationBarCubit.get(context).currentIndex,
              onTap: (index) {
                ButtonNavigationBarCubit.get(context).changeIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}

class _WaqtyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _WaqtyBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final items = [
      _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.tr('buttonNavBar.homeText'),
      ),
      _NavItemData(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: context.tr('buttonNavBar.exploreText'),
      ),
      _NavItemData(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: context.tr('buttonNavBar.bookingText'),
        badge: '2',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person,
        label: context.tr('buttonNavBar.accountText'),
      ),
    ];

    return Container(
      height: 66.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.17),
            blurRadius: 20.r,
            offset: Offset(0, 18.h),
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.03),
            blurRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: List.generate(items.length, (index) {
          return Expanded(
            flex: currentIndex == index ? 2 : 1,
            child: _WaqtyBottomNavItem(
              item: items[index],
              selected: currentIndex == index,
              onTap: () => onTap(index),
            ),
          );
        }),
      ),
    );
  }
}

class _WaqtyBottomNavItem extends StatelessWidget {
  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _WaqtyBottomNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: selected ? 12.w : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.greyColor900 : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22.sp,
                  color: selected
                      ? AppColors.whiteColor
                      : AppColors.greyColor500,
                ),
                if (selected) ...[
                  SizedBox(width: 8.w),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font12whiteColorWeight600,
                  ),
                ],
              ],
            ),
            if (item.badge != null && !selected)
              Positioned(
                top: 7.h,
                right: isArabic ? 16.w : null,
                left: isArabic ? null : 16.w,
                child: Container(
                  height: 16.w,
                  width: 16.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.errorColor100,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item.badge!,
                    style: TextStyles.font12whiteColorWeight600.copyWith(
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
