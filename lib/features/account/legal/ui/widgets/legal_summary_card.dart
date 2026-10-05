import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_state.dart';

class LegalSummaryCard extends StatelessWidget {
  final LegalTab tab;

  const LegalSummaryCard({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final prefix = tab == LegalTab.privacy ? 'legal.privacy' : 'legal.terms';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.greyColor900,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.25),
            blurRadius: 45.r,
            offset: Offset(0, 16.h),
            spreadRadius: -16.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('$prefix.summaryTitle'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greenColor500W600.copyWith(
                color: AppColors.greenColor100,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('$prefix.summaryBody'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font16whiteColorWeight600.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
