import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_state.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/ui/account_screen.dart';
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
        return SizedBox();
      // return BlocProvider(
      //   create: (_) => ExploreNearPeopleCubit(getIt()),
      //   child: ExploreNearPeopleScreen(),
      // );

      case 2:
        return BlocProvider(
          create: (_) => HomeCubit(getIt()),
          child: HomeScreen(),
        );

      case 3:
        return BlocProvider(
          create: (_) => AccountCubit()..loadAccountState(),
          child: AccountScreen(),
        );

      default:
        return BlocProvider(
          create: (_) => HomeCubit(getIt()),
          child: HomeScreen(),
        );
    }
  }

  List<BottomNavigationBarItem> buttonNavigationBarItems() => [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 22.r),
      activeIcon: Icon(Icons.home_rounded, size: 22.r),
      label: 'buttonNavBar.homeText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined, size: 22.r),
      activeIcon: Icon(Icons.map_rounded, size: 22.r),
      label: 'buttonNavBar.exploreText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined, size: 22.r),
      activeIcon: Icon(Icons.calendar_month_rounded, size: 22.r),
      label: 'buttonNavBar.bookingText'.tr(),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded, size: 22.r),
      activeIcon: Icon(Icons.person_rounded, size: 22.r),
      label: 'buttonNavBar.accountText'.tr(),
    ),
  ];

  static ButtonNavigationBarCubit get(context) => BlocProvider.of(context);
}
