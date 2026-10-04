import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/packages_following/data/models/packages_following_models.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_cubit.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_state.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/widgets/package_card.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/widgets/packages_following_header.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/widgets/packages_following_tabs.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/widgets/reserved_package_card.dart';

class PackagesFollowingContent extends StatelessWidget {
  const PackagesFollowingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackagesFollowingCubit, PackagesFollowingState>(
      builder: (context, state) {
        final cubit = PackagesFollowingCubit.get(context);
        final isPackages = cubit.selectedTab == PackagesFollowingTab.packages;
        final cards = isPackages ? cubit.packages : cubit.following;

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: PackagesFollowingHeader()),
            SliverToBoxAdapter(child: PackagesFollowingTabs()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 104.h),
              sliver: SliverList.separated(
                itemCount: cards.length + (isPackages ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (isPackages && index == 0) {
                    return ReservedPackageCard(package: cubit.reservedPackage);
                  }
                  final cardIndex = isPackages ? index - 1 : index;
                  return PackageCard(package: cards[cardIndex]);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(height: 1.h, color: AppColors.pageColor),
            ),
          ],
        );
      },
    );
  }
}
