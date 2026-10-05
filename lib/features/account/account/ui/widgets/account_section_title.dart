import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class AccountSectionTitle extends StatelessWidget {
  final String title;

  const AccountSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 10.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyles.font20greyColor900W600.copyWith(
            color: AppColors.greyColor900,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
