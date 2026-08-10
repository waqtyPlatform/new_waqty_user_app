import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_skeleton_widget.dart';
import 'app_surface_widget.dart';
import 'directional_chevron_widget.dart';

/// صف قايمة — **بيستبدل تلات نسخ**.
///
/// `profile_user_my_account_widget.dart` (`ProfileMenuItemData{title,
/// iconPath, onTap}`) · `security_settings_screen.dart:121
/// _SecurityTileWidget` (نفس الصف بـ`IconData` بدل SVG) ·
/// `my_earning_action_tile_widget.dart` (نسخة بسطرين).
///
/// بياخد **`iconAsset` (مسار) أو `icon` (`IconData`)** — الكيت مايملكش
/// طقم أيقونات التطبيق.
///
/// ## ⚠ ده مثال الـ `heightOf` في الكيت
///
/// العقد: **`heightOf` = ارتفاع الكارت كله بالحشوة.** الـ skeleton بيقرا
/// **نفس الـ static**، فاللستة مابتنطّش أول ما الداتا توصل.
/// `row_height_test.dart` بيقيس الاتنين ويقارنهم.
class AppMenuRowWidget extends StatelessWidget {
  const AppMenuRowWidget({
    required this.title,
    this.subtitle,
    this.iconAsset,
    this.icon,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.tone,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? subtitle;

  /// مسار SVG — الكيت بيلوّنه بـ `ColorFilter`.
  final String? iconAsset;

  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  /// لون الأيقونة والعنوان — للصفوف المدمّرة (تسجيل خروج، حذف حساب).
  final Color? tone;

  static const double _fixedPart = 24;

  /// `bodyMdStrong` (14 × 1.50 = 21) + `caption` (12 × 1.40 = 16.8) +
  /// `titleToSubtitle` — **+١ هامش تقريب**. المساحة بتتحجز **دايمًا**
  /// حتى من غير عنوان فرعي، عشان الصفوف ماترقصش.
  static const double _textPart = 43;

  static double heightOf(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  @override
  Widget build(BuildContext context) {
    final ink = tone ?? AppSemanticColors.textPrimary;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
      child: AppSurfaceWidget(
        onTap: onTap,
        padding: AppSpacing.card,
        height: heightOf(context).h,
        child: Row(
          children: [
            if (iconAsset != null || icon != null) ...[
              _Leading(
                iconAsset: iconAsset,
                icon: icon,
                tint: tone ?? AppSemanticColors.accentText,
              ),
              SizedBox(width: AppSpacing.s12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMdStrong.copyWith(color: ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.titleToSubtitle.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.s8.w),
              trailing!,
            ] else if (showChevron && onTap != null) ...[
              SizedBox(width: AppSpacing.s4.w),
              const DirectionalChevronWidget(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.iconAsset,
    required this.icon,
    required this.tint,
  });

  final String? iconAsset;
  final IconData? icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppSemanticColors.accentTint,
        borderRadius: AppRadius.rXs,
      ),
      child: iconAsset != null
          ? SvgPicture.asset(
              iconAsset!,
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            )
          : Icon(icon, size: 20.r, color: tint),
    );
  }
}

/// الـ skeleton — **بيقرا نفس الـ static**.
///
/// من غير كده اللستة بتنطّ لما الداتا توصل، وده الباج اللي
/// `row_height_test.dart` اتكتب عشانه.
class AppMenuRowSkeletonWidget extends StatelessWidget {
  const AppMenuRowSkeletonWidget({this.hasIcon = true, super.key});

  final bool hasIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
      child: AppSurfaceWidget(
        padding: AppSpacing.card,
        height: AppMenuRowWidget.heightOf(context).h,
        child: Row(
          children: [
            if (hasIcon) ...[
              const AppSkeletonBoxWidget(
                width: 36,
                height: 36,
                radius: AppRadius.xs,
              ),
              SizedBox(width: AppSpacing.s12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSkeletonBoxWidget(width: 140),
                  SizedBox(height: AppSpacing.titleToSubtitle.h),
                  const AppSkeletonBoxWidget(width: 90, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
