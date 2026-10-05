import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class HelpFaqSection extends StatelessWidget {
  const HelpFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Column(
      children: [
        SizedBox(
          height: 40.h,
          child: Stack(
            children: [
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  context.tr('help.faqTitle'),
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
              ),
              Align(
                alignment: isArabic
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  context.tr('help.fullList'),
                  style: TextStyles.font12greenColor500W600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
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
            children: const [
              _ExpandedFaqItem(),
              _CollapsedFaqItem(textKey: 'help.faqPackageQuestion'),
              _CollapsedFaqItem(textKey: 'help.faqPaymentQuestion'),
              _CollapsedFaqItem(textKey: 'help.faqMissedQuestion'),
              _CollapsedFaqItem(textKey: 'help.faqWaitlistQuestion'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandedFaqItem extends StatelessWidget {
  const _ExpandedFaqItem();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30.h,
            child: Stack(
              children: [
                Align(
                  alignment: isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('help.faqCancelQuestion'),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyles.font16greyColor900Weight600,
                    ),
                  ),
                ),
                Align(
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.greyColor300,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              context.tr('help.faqCancelAnswer'),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedFaqItem extends StatelessWidget {
  final String textKey;

  const _CollapsedFaqItem({required this.textKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return SizedBox(
      height: 48.h,
      child: Stack(
        children: [
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: isArabic ? 26.w : 0,
                right: isArabic ? 0 : 26.w,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  context.tr(textKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyles.font16greyColor900Weight600,
                ),
              ),
            ),
          ),
          Align(
            alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.greyColor500,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
