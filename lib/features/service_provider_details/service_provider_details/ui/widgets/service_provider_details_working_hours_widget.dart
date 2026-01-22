import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsWorkingHoursWidget extends StatelessWidget {
  const ServiceProviderDetailsWorkingHoursWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Hours',
          style: TextStyles.font16greyColor900Weight600,
        ),
        verticalSpace(8),
        Row(
          children: [
            Text(
              'Monday',
              style: TextStyles.font14greyColor500W400,
            ),
            Spacer(),
            Text(
              '08.00 AM - 21.00 PM',
              style: TextStyles.font14greyColor900Weight500,
            ),
          ],
        ),
        verticalSpace(8),
        Row(
          children: [
            Text(
              'Monday',
              style: TextStyles.font14greyColor500W400,
            ),
            Spacer(),
            Text(
              '08.00 AM - 21.00 PM',
              style: TextStyles.font14greyColor900Weight500,
            ),
          ],
        ),

      ],
    );
  }
}
