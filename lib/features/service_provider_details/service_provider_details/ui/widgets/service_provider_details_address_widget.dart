import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsAddressWidget extends StatelessWidget {
  const ServiceProviderDetailsAddressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Our Address', style: TextStyles.font16greyColor900Weight600),
            Spacer(),
            Text('See on Maps', style: TextStyles.font14greenColor500Weight600),
          ],
        ),
        verticalSpace(16),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.greenColor500),
            horizontalSpace(8),
            Expanded(
              child: Text(
                '123 Main Street, Anytown, USA',
                maxLines: 2,
                style: TextStyles.font14greyColor500W400,
              ),
            ),
          ],
        ),
        verticalSpace(16),
        SizedBox(
          height: 200.h,
          width: double.infinity,
          child: Image.asset(ImageAsset.t3, fit: BoxFit.fill),
        ),
      ],
    );
  }
}
