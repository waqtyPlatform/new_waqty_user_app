import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ServiceProviderDetailsDescriptionWidget extends StatelessWidget {
  const ServiceProviderDetailsDescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyles.font16greyColor900Weight600,
        ),
        verticalSpace(8),
        Text(
          'Classic Cuts Barber Shop is a well-established barber shop located in the heart of Anytown. Situated on Main Street, it has been serving the local community for over a decade. The shop exudes a classic and timeless ambiance, with vintage barber chairs, traditional decor, and a friendly atmosphere.',
          style: TextStyles.font14greyColor500W400,
        ),

      ],
    );
  }
}
