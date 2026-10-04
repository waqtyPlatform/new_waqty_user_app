import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

class ServiceProviderDetailsTopBarActionsWidget extends StatelessWidget {
  const ServiceProviderDetailsTopBarActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            const WaqtyBackButton(),
            Spacer(),
            Text('Details', style: TextStyles.font18whiteColorWeight600),
            Spacer(),
            GestureDetector(
              onTap: () {
                // context.pop();
              },
              child: Icon(
                Icons.more_vert,
                color: AppColors.whiteColor,
                size: 24.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
