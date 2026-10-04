import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

bool accountIsArabic(BuildContext context) =>
    context.locale.languageCode == 'ar';

class AccountFlowHeader extends StatelessWidget {
  final String titleKey;

  const AccountFlowHeader({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    final title = Expanded(
      child: Text(
        context.tr(titleKey),
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font20greyColor900W600.copyWith(height: 1.3),
      ),
    );
    const backButton = WaqtyBackButton();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
      child: SizedBox(
        height: 44.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isArabic
              ? [backButton, SizedBox(width: 12.w), title]
              : [backButton, SizedBox(width: 12.w), title],
        ),
      ),
    );
  }
}

class AccountFlowFooter extends StatelessWidget {
  final String primaryKey;
  final String secondaryKey;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const AccountFlowFooter({
    super.key,
    required this.primaryKey,
    required this.secondaryKey,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 26.h),
      decoration: BoxDecoration(
        color: AppColors.pageColor.withValues(alpha: 0.94),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPrimaryTap,
            child: Container(
              height: 52.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.greyColor900,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                context.tr(primaryKey),
                style: TextStyles.font16whiteColorWeight600.copyWith(
                  height: 1.3,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSecondaryTap ?? context.pop,
            child: SizedBox(
              height: 40.h,
              child: Center(
                child: Text(
                  context.tr(secondaryKey),
                  style: TextStyles.font12greyColor500W600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountFlowLabel extends StatelessWidget {
  final String textKey;

  const AccountFlowLabel({super.key, required this.textKey});

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        context.tr(textKey),
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyles.font12greyColor500W600,
      ),
    );
  }
}

class AccountReadOnlyField extends StatelessWidget {
  final String value;
  final bool highlighted;
  final Widget? leading;
  final Widget? trailing;
  final TextAlign? textAlign;

  const AccountReadOnlyField({
    super.key,
    required this.value,
    this.highlighted = false,
    this.leading,
    this.trailing,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = accountIsArabic(context);
    return Container(
      constraints: BoxConstraints(minHeight: 56.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: highlighted
              ? AppColors.greenColor500
              : AppColors.greyColor1001,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: 10.w)],
          Expanded(
            child: Text(
              value,
              textAlign:
                  textAlign ?? (isArabic ? TextAlign.right : TextAlign.left),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.font16greyColor900Weight400.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 10.w), trailing!],
        ],
      ),
    );
  }
}

class AccountVerifiedBadge extends StatelessWidget {
  const AccountVerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.greenColor505,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        context.tr('account.verified'),
        style: TextStyles.font12greenColor500W600.copyWith(
          color: AppColors.greenColor600,
        ),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final Widget child;

  const AccountCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.05),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.16),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
            spreadRadius: -14.r,
          ),
        ],
      ),
      child: child,
    );
  }
}
