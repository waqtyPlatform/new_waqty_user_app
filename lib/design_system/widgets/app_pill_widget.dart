import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// نغمة الشارة — **معنى، مش لون**.
enum AppPillTone { neutral, accent, positive, warning, danger, info, onImage }

/// الشارة — **البدائي الوحيد. مفيش حد يرسم pill بإيده.**
///
/// ## ده بيستبدل إيه
///
/// أربع نسخ **متطابقة** في employee-app:
/// `attendance_screen.dart:442 _StatusPillWidget` ·
/// `booking_details_body_widget.dart:539 _VisitStatusPill` ·
/// `payslips_list_widget.dart:107 _PayslipStatusPillWidget` ·
/// `payslip_details_hero_card_widget.dart:57 _PayslipDetailsStatusPillWidget`
/// — زائد `_DayOffBadgeWidget` و`_BreakPillWidget`.
///
/// ## ⚠ اللي الكيت مابيعملهوش
///
/// **الربط بين الحالة والنغمة مش هنا.** «ملغي → danger» ده domain بتاع
/// التطبيق مش الكيت. اللي بيتبنّى الكيت بيكتب سطور زي دي عنده:
///
/// ```dart
/// AppPillTone toneOf(BookingStatus s) => switch (s) {
///   BookingStatus.confirmed => AppPillTone.positive,
///   BookingStatus.cancelled => AppPillTone.danger,
///   _ => AppPillTone.neutral,
/// };
/// ```
class AppPillWidget extends StatelessWidget {
  const AppPillWidget({
    required this.label,
    this.tone = AppPillTone.neutral,
    this.icon,
    this.maxWidth,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String label;

  final AppPillTone tone;
  final IconData? icon;

  /// لما تتحط، النص بيتقص بـ ellipsis بدل ما يفيض.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(color: _ground, borderRadius: AppRadius.rPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.r, color: _ink),
            SizedBox(width: AppSpacing.s4.w),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.captionStrong.copyWith(color: _ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return maxWidth == null
        ? pill
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!.w),
            child: pill,
          );
  }

  Color get _ground => switch (tone) {
    AppPillTone.neutral => AppSemanticColors.surfaceSunken,
    AppPillTone.accent => AppSemanticColors.surfaceAccentSoft,
    AppPillTone.positive => AppSemanticColors.positiveSoft,
    AppPillTone.warning => AppSemanticColors.warningSoft,
    AppPillTone.danger => AppSemanticColors.dangerSoft,
    AppPillTone.info => AppSemanticColors.infoSoft,
    AppPillTone.onImage => AppSemanticColors.scrim,
  };

  Color get _ink => switch (tone) {
    AppPillTone.neutral => AppSemanticColors.textOnSunken,
    AppPillTone.accent => AppSemanticColors.accentText,
    AppPillTone.positive => AppSemanticColors.positive,
    AppPillTone.warning => AppSemanticColors.warning,
    // ⚠ `dangerOnSoft` مش `danger` — الأحمر على خلفيته الوردية بيدي
    // **4.30:1** (راسب). ده المكان اللي الإصلاح بيقع فيه فعلاً.
    AppPillTone.danger => AppSemanticColors.dangerOnSoft,
    AppPillTone.info => AppSemanticColors.info,
    AppPillTone.onImage => AppSemanticColors.textOnInk,
  };
}
