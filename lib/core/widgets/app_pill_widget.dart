import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// لهجة الشارة.
enum AppPillTone {
  /// معلومة محايدة — عدد خدمات، مسافة.
  neutral,

  /// فرصة أو إتاحة — «أقرب موعد».
  accent,

  positive,
  warning,
  danger,
  info,

  /// **فوق صورة أو لوح ملوّن.** سطح مرفوع كامل التعتيم بظل — الشارة
  /// النصف-شفافة فوق لوح ملوّن بتاخد لونه وبتبقى مش مقروءة.
  onImage,
}

/// شارة صغيرة.
///
/// من الـ design DNA:
/// > `Small rounded pill badges … for promotional tags … status badges use
/// > contrasting colors`
///
/// ## ليه توكن مش `Container` في كل مكان
///
/// الشارات كانت متكتوبة بالإيد في ٤ مواضع بحشوات مختلفة (٨/٤ · ١٠/٣ ·
/// ١٢/٦)، ونفس الحالة كانت شكلها مختلف في شاشتين. الـ widget ده بيوحّدهم،
/// و`BookingStatusChipWidget` بقى غلاف رفيع فوقه بيترجم الحالة للهجة بس.
class AppPillWidget extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppPillTone tone;

  /// أكبر عرض — الشارة اللي فوق صورة كارت ضيق لازم تتقص مش تفيض.
  final double? maxWidth;

  const AppPillWidget({
    super.key,
    required this.label,
    this.icon,
    this.tone = AppPillTone.neutral,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;

    final pill = Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: tone == AppPillTone.onImage ? AppShadows.raised : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.r, color: foreground),
            SizedBox(width: AppSpacing.s4.w),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.overline.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );

    if (maxWidth == null) return pill;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!.w),
      child: pill,
    );
  }

  (Color, Color) get _colors => switch (tone) {
    AppPillTone.neutral => (
      AppSemanticColors.surfaceSunken,
      AppSemanticColors.textOnSunken,
    ),
    AppPillTone.accent => (
      AppSemanticColors.accentSoft,
      AppSemanticColors.accent,
    ),
    AppPillTone.positive => (
      AppSemanticColors.positiveSoft,
      AppSemanticColors.positive,
    ),
    AppPillTone.warning => (
      AppSemanticColors.warningSoft,
      AppSemanticColors.warning,
    ),
    AppPillTone.danger => (
      AppSemanticColors.dangerSoft,
      AppSemanticColors.danger,
    ),
    AppPillTone.info => (
      AppSemanticColors.infoSoft,
      AppSemanticColors.info,
    ),
    AppPillTone.onImage => (
      AppSemanticColors.surfaceRaised,
      AppSemanticColors.accent,
    ),
  };
}
