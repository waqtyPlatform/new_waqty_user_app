import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class ConfirmPhoneTitle extends StatelessWidget {
  const ConfirmPhoneTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('confirmPhone.title'),
          textAlign: TextAlign.start,
          style: TextStyles.font24greyColor900Weight600.copyWith(
            fontSize: 24.sp,
            height: 1.28,
          ),
        ),
        SizedBox(height: 6.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: context.tr('confirmPhone.sentPrefix'),
                style: TextStyles.font14greyColor4002Weight400.copyWith(
                  fontSize: 16.sp,
                  height: 1.65,
                ),
              ),
              TextSpan(
                text: context.tr('confirmPhone.phoneValue'),
                style: TextStyles.font16greyColor900Weight600.copyWith(
                  height: 1.65,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
