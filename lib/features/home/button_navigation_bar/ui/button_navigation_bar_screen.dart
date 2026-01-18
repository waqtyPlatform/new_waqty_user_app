import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          backgroundColor: AppColors.whiteColor,
          body: ButtonNavigationBarCubit.get(context).buttonBarBody(),
          extendBody: true,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -10),
                  blurRadius: 40,
                  spreadRadius: 0,
                  color: AppColors.blackColor.withValues(alpha: .06),
                ),
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: ButtonNavigationBarCubit.get(
                  context,
                ).currentIndex,
                selectedItemColor: AppColors.greenColor500,
                unselectedItemColor: AppColors.greyColor3003,
                backgroundColor: AppColors.whiteColor,
                selectedLabelStyle: TextStyles.font12greenColor500W600,
                unselectedLabelStyle: TextStyles.font12greyColor3003Weight400,
                elevation: 0,
                onTap: (int index) {
                  ButtonNavigationBarCubit.get(context).changeIndex(index);
                },
                items: ButtonNavigationBarCubit.get(
                  context,
                ).buttonNavigationBarItems(),
              ),
            ),
          ),
        );
      },
    );
  }
}
