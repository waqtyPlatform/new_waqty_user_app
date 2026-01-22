import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_address_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_book_button_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_description_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_packages_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_pages_pagination_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_place_data_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_reviews_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_services_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_specialist_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_top_bar_actions_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_top_bar_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_working_hours_widget.dart';

class ServiceProviderDetailsScreen extends StatelessWidget {
  const ServiceProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  ServiceProviderDetailsTopBarWidget(),
                  ServiceProviderDetailsTopBarActionsWidget(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    margin: EdgeInsets.only(top: 310.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        verticalSpace(32),
                        ServiceProviderDetailsPlaceDataWidget(),
                        verticalSpace(8),
                        Divider(color: AppColors.greyColor50),
                        verticalSpace(28),
                        ServiceProviderDetailsSpecialistWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsPagesPaginationWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsDescriptionWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsWorkingHoursWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsAddressWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsServicesWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsPackagesWidget(),
                        verticalSpace(28),
                        ServiceProviderDetailsReviewsWidget(),

                        verticalSpace(40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ServiceProviderDetailsBookButtonWidget(),
        ],
      ),
    );
  }
}
