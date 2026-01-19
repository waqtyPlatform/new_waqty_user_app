import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

class UpcomingAppointmentWidget extends StatelessWidget {
  const UpcomingAppointmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.greyColor50),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Dec 22, 2024',
                style: TextStyles.font12greyColor900Weight400,
              ),
              Spacer(),
              Text(
                'home.RemindMeText'.tr(),
                style: TextStyles.font12greyColor3003Weight400,
              ),
              horizontalSpace(12),
              Switch(
                value: true,
                activeTrackColor: AppColors.greenColor500,
                thumbColor: MaterialStateProperty.all(AppColors.whiteColor),
                inactiveThumbColor: AppColors.greyColor200,
                trackOutlineColor: MaterialStateProperty.all(
                  // AppColors.greyColor200,
                  AppColors.greenColor500,
                ),
                onChanged: (value) {
                  // OpenNewTicketCubit.get(context).changeAllow();
                },
              ),
            ],
          ),
          verticalSpace(12),
          Divider(color: AppColors.greyColor50),
          verticalSpace(16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(ImageAsset.t1),
              horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Waqty Barbershop',
                      maxLines: 1,
                      style: TextStyles.font16greyColor900Weight600,
                    ),
                    Text(
                      '123 Main Street, Anytown, USA',
                      style: TextStyles.font12greyColor500W400,
                    ),
                    verticalSpace(8),
                    Text(
                      'home.ServicesText'.tr(),
                      style: TextStyles.font12greyColor500W600,
                    ),
                    Text(
                      'Undercut Haircut, Regular Shaving, Natural Hair Wash',
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  isLoading: false,
                  buttonHeight: 44.h,
                  buttonText: 'Cancel Booking',
                  borderRadius: 8.r,
                  borderWidth: 1.7,
                  backGroundColor: AppColors.whiteColor,
                  borderColor: AppColors.greenColor500,
                  textStyle: TextStyles.font14greenColor500Weight600,
                  onPressed: () {},
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: ButtonWidget(
                  isLoading: false,
                  buttonHeight: 44.h,
                  buttonText: 'E-Receipt',
                  borderRadius: 8.r,
                  backGroundColor: AppColors.greenColor500,
                  borderColor: AppColors.greenColor500,
                  textStyle: TextStyles.font14whiteColorWeight500,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
