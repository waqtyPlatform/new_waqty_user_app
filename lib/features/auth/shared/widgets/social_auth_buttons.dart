import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class SocialAuthButtons extends StatelessWidget {
  final String googleSemanticLabelKey;
  final String appleSemanticLabelKey;

  const SocialAuthButtons({
    required this.googleSemanticLabelKey,
    required this.appleSemanticLabelKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                context.tr('login.continueWithText'),
                style: TextStyles.font12greyColor500W400,
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        verticalSpace(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialAuthButton(
              semanticLabel: context.tr(googleSemanticLabelKey),
              icon: ImageAsset.googleICon,
              onTap: () {},
            ),
            horizontalSpace(14),
            _SocialAuthButton(
              semanticLabel: context.tr(appleSemanticLabelKey),
              icon: ImageAsset.appleIcon,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String semanticLabel;
  final String icon;
  final VoidCallback onTap;

  const _SocialAuthButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 56.w,
            height: 56.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyColor900.withValues(alpha: 0.06),
                  blurRadius: 14.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: SvgPicture.asset(icon, width: 22.w, height: 22.w),
          ),
        ),
      ),
    );
  }
}
