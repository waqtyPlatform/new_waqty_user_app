import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HelpContactSection extends StatelessWidget {
  const HelpContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.tr('help.contactTitle'),
            textAlign: TextAlign.start,
            style: TextStyles.font20greyColor900W600.copyWith(height: 1.3),
          ),
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 10.w) / 2;
            final messageCard = _ContactCard(
              width: cardWidth,
              titleKey: 'help.messageTitle',
              subtitleKey: 'help.messageSubtitle',
              icon: Icons.inbox_outlined,
              color: AppColors.blueColor200,
              backgroundColor: AppColors.blueColor0,
            );
            final callCard = _ContactCard(
              width: cardWidth,
              titleKey: 'help.callTitle',
              subtitleKey: 'help.callSubtitle',
              icon: Icons.phone_outlined,
              color: AppColors.greenColor600,
              backgroundColor: AppColors.greenColor505,
            );
            return SizedBox(
              height: 148.h,
              child: Stack(
                children: [
                  Positioned(left: 0, right: null, top: 0, child: messageCard),
                  Positioned(right: 0, left: null, top: 0, child: callCard),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final double width;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _ContactCard({
    required this.width,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 148.h,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18.r),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(titleKey),
              textAlign: TextAlign.start,
              style: TextStyles.font16greyColor900Weight600.copyWith(
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr(subtitleKey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
            ),
          ),
        ],
      ),
    );
  }
}
