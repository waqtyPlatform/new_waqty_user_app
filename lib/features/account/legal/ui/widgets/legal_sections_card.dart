import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_state.dart';

class LegalSectionsCard extends StatelessWidget {
  final LegalTab tab;

  const LegalSectionsCard({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final prefix = tab == LegalTab.privacy ? 'legal.privacy' : 'legal.terms';
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.greyColor50),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.03),
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.16),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
            spreadRadius: -14.r,
          ),
        ],
      ),
      child: Column(
        children: [
          _LegalSection(
            titleKey: '$prefix.sectionOneTitle',
            bodyKey: '$prefix.sectionOneBody',
          ),
          _LegalSection(
            titleKey: '$prefix.sectionTwoTitle',
            bodyKey: '$prefix.sectionTwoBody',
          ),
          _LegalSection(
            titleKey: '$prefix.sectionThreeTitle',
            bodyKey: '$prefix.sectionThreeBody',
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String titleKey;
  final String bodyKey;

  const _LegalSection({required this.titleKey, required this.bodyKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(titleKey),
              textAlign: TextAlign.start,
              style: TextStyles.font16greyColor900Weight600,
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(bodyKey),
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
            ),
          ),
        ],
      ),
    );
  }
}
