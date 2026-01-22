import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

class ServiceProviderDetailsBookButtonWidget extends StatelessWidget {
  const ServiceProviderDetailsBookButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 24.w,
        left: 24.w,
        top: 16.h,
        bottom: 40.h,
      ),
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
      child: ButtonWidget(
        isLoading: false,
        buttonHeight: 52.h,
        buttonText: 'Book Now',
        borderRadius: 12.r,
        backGroundColor: AppColors.greenColor500,
        borderColor: AppColors.greenColor500,
        textStyle: TextStyles.font14whiteColorWeight500,
        onPressed: () {},
      ),
    );
  }
}
