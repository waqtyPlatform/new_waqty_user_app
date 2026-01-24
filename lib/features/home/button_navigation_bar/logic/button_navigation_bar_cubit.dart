import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/logic/explore_near_people_cubit.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/ui/explore_near_people_screen.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/home/ui/home_screen.dart';

class ButtonNavigationBarCubit extends Cubit<ButtonNavigationBarState> {
  ButtonNavigationBarCubit() : super(InitialState());
  int currentIndex = 0;

  void changeIndex(int i) {
    currentIndex = i;
    emit(OnBottomNavBarChangedState());
  }

  Widget buttonBarBody() {
    switch (currentIndex) {
      case 0:
        return BlocProvider(
          create: (_) => HomeCubit(getIt()),
          child: HomeScreen(),
        );

      case 1:
        return BlocProvider(
          create: (_) => ExploreNearPeopleCubit(getIt()),
          child: ExploreNearPeopleScreen(),
        );

      case 2:
        return SizedBox();
      // return BlocProvider(
      //   create: (_) => SenderProfileCubit(getIt(),getIt())..getProfileData(),
      //   child: SenderProfileScreen(),
      // );
      case 3:
        return SizedBox();
      // return BlocProvider(
      //   create: (_) => SenderProfileCubit(getIt(),getIt())..getProfileData(),
      //   child: SenderProfileScreen(),
      // );
      case 4:
        return SizedBox();
      // return BlocProvider(
      //   create: (_) => SenderProfileCubit(getIt(),getIt())..getProfileData(),
      //   child: SenderProfileScreen(),
      // );

      default:
        return BlocProvider(
          create: (_) => HomeCubit(getIt()),
          child: HomeScreen(),
        );
    }
  }

  List<BottomNavigationBarItem> buttonNavigationBarItems() => [
    BottomNavigationBarItem(
      icon: SvgPicture.asset(ImageAsset.homeIcon, height: 20.r, width: 20.r),
      activeIcon: SvgPicture.asset(
        ImageAsset.selectedHomeIcon,
        height: 20.r,
        width: 20.r,
        fit: BoxFit.fill,
      ),
      label: 'buttonNavBar.homeText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(ImageAsset.exploreIcon, height: 20.r, width: 20.r),
      activeIcon: SvgPicture.asset(
        ImageAsset.selectedExploreIcon,
        height: 20.r,
        width: 20.r,
      ),
      label: 'buttonNavBar.exploreText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: Container(
        height: 48.r,
        width: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greyColor900,
        ),
        child: Icon(Icons.add, color: AppColors.whiteColor),
      ),
      activeIcon: Container(
        height: 48.r,
        width: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greyColor900,
        ),
        child: Icon(Icons.add, color: AppColors.whiteColor),
      ),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(ImageAsset.bookingIcon, height: 20.r, width: 20.r),
      activeIcon: SvgPicture.asset(
        ImageAsset.selectedBookingIcon,
        height: 20.r,
        width: 20.r,
      ),
      label: 'buttonNavBar.bookingText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: SvgPicture.asset(ImageAsset.accountIcon, height: 20.r, width: 20.r),
      activeIcon: SvgPicture.asset(
        ImageAsset.selectedAccountIcon,
        height: 20.r,
        width: 20.r,
      ),
      label: 'buttonNavBar.accountText'.tr(),
    ),
  ];

  static ButtonNavigationBarCubit get(context) => BlocProvider.of(context);
}
