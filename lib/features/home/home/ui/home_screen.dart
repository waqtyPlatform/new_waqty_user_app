import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/category_items_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/near_by_location_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/popular_people_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/top_home_widget.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/upcoming_appointment_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopHomeWidget(),
            verticalSpace(24),

            verticalSpace(24),
            CategoryItemsWidget(),
            verticalSpace(24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Text(
                    'home.UpcomingAppointmentsText'.tr(),
                    style: TextStyles.font18greyColor900Weight600,
                  ),
                  Spacer(),
                  Text(
                    'home.SeeAllText'.tr(),
                    style: TextStyles.font14greenColor500Weight600,
                  ),
                ],
              ),
            ),
            verticalSpace(16),
            UpcomingAppointmentWidget(),
            verticalSpace(24),
            PopularPeopleWidget(),
            verticalSpace(32),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Text(
                    'home.NearbyLocationText'.tr(),
                    style: TextStyles.font18greyColor900Weight600,
                  ),
                  Spacer(),
                  Text(
                    'home.SeeAllText'.tr(),
                    style: TextStyles.font14greenColor500Weight600,
                  ),
                ],
              ),
            ),
            verticalSpace(16),
            NearByLocationWidget(),

            verticalSpace(200),
          ],
        ),
      ),
    );
  }
}
