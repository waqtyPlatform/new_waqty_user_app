import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_cubit.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_state.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class PackagesFollowingTabs extends StatelessWidget {
  const PackagesFollowingTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackagesFollowingCubit, PackagesFollowingState>(
      builder: (context, state) {
        final cubit = PackagesFollowingCubit.get(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xffF1F0EB),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gap = 2.w;
                final tabWidth = (constraints.maxWidth - gap) / 2;
                final selectedLeft = _selectedLeft(
                  cubit.selectedTab,
                  tabWidth,
                  gap,
                );
                final leftTab = PackagesFollowingTab.following;
                final rightTab = PackagesFollowingTab.packages;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      left: selectedLeft,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyColor900,
                          borderRadius: BorderRadius.circular(999.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greyColor900.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 14.r,
                              offset: Offset(0, 6.h),
                              spreadRadius: -8.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: _TabButton(
                        titleKey: _tabTitleKey(leftTab),
                        isSelected: cubit.selectedTab == leftTab,
                        onTap: () => cubit.changeTab(leftTab),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: tabWidth,
                      child: _TabButton(
                        titleKey: _tabTitleKey(rightTab),
                        isSelected: cubit.selectedTab == rightTab,
                        onTap: () => cubit.changeTab(rightTab),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

double _selectedLeft(PackagesFollowingTab tab, double tabWidth, double gap) {
  final isPackages = tab == PackagesFollowingTab.packages;
  final selectedIsRight = isPackages;
  return selectedIsRight ? tabWidth + gap : 0;
}

String _tabTitleKey(PackagesFollowingTab tab) {
  return tab == PackagesFollowingTab.packages
      ? 'packagesFollowing.packagesTab'
      : 'packagesFollowing.followingTab';
}

class _TabButton extends StatelessWidget {
  final String titleKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.titleKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          style: TextStyles.font12greyColor500W600.copyWith(
            color: isSelected ? AppColors.whiteColor : AppColors.greyColor500,
          ),
          child: Text(context.tr(titleKey)),
        ),
      ),
    );
  }
}
