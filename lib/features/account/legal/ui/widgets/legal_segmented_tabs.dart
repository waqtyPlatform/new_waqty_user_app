import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_cubit.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_state.dart';

class LegalSegmentedTabs extends StatelessWidget {
  final LegalTab selectedTab;

  const LegalSegmentedTabs({super.key, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.sunkenColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Stack(
        children: [
          _LegalTabButton(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            labelKey: 'legal.privacyTab',
            isSelected: selectedTab == LegalTab.privacy,
            onTap: () => LegalCubit.get(context).changeTab(LegalTab.privacy),
          ),
          _LegalTabButton(
            alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
            labelKey: 'legal.termsTab',
            isSelected: selectedTab == LegalTab.terms,
            onTap: () => LegalCubit.get(context).changeTab(LegalTab.terms),
          ),
        ],
      ),
    );
  }
}

class _LegalTabButton extends StatelessWidget {
  final Alignment alignment;
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _LegalTabButton({
    required this.alignment,
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 151.w,
          height: 38.h,
          margin: EdgeInsets.all(3.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greyColor900 : Colors.transparent,
            borderRadius: BorderRadius.circular(999.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.greyColor900.withValues(alpha: 0.18),
                      blurRadius: 14.r,
                      offset: Offset(0, 5.h),
                    ),
                  ]
                : null,
          ),
          child: Text(
            context.tr(labelKey),
            style: TextStyles.font12greyColor500W600.copyWith(
              color: isSelected ? AppColors.whiteColor : AppColors.greyColor500,
            ),
          ),
        ),
      ),
    );
  }
}
