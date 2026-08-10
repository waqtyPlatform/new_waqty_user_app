import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_pill_widget.dart';
import 'app_surface_widget.dart';

/// بلاطة رقم — **بتستبدل أربع نسخ**.
///
/// `working_hours_summary_card_widget.dart` (عام) ·
/// `daily_earning_stats_row_widget.dart` `_DailyStatCardWidget` (خاص) ·
/// `my_earning_summary_row_widget.dart` `_MoneySummaryCardWidget` (نسخة
/// بدايرة أيقونة) · ونص `stats_dashboard_row_widget.dart` (١٨٠ سطر منسوخ
/// مرتين).
///
/// دايرة الأيقونة مش variant — هي `icon != null` وبس.
class AppStatTileWidget extends StatelessWidget {
  const AppStatTileWidget({
    required this.label,
    required this.value,
    this.icon,
    this.iconTone = AppPillTone.accent,
    this.valueColor,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String label;
  final String value;

  final IconData? icon;
  final AppPillTone iconTone;
  final Color? valueColor;

  /// شارة اتجاه، سهم، أو أي حاجة صغيرة.
  final Widget? trailing;

  final VoidCallback? onTap;

  static const double _fixedPart = 32;

  /// `titleLg` (20 × 1.30 = 26) + `caption` (12 × 1.40 = 16.8) + المسافة
  /// بينهم — **+١ هامش تقريب**.
  static const double _textPart = 47;

  static double heightOf(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      onTap: onTap,
      padding: AppSpacing.card,
      child: Row(
        children: [
          if (icon != null) ...[
            _IconCircle(icon: icon!, tone: iconTone),
            SizedBox(width: AppSpacing.s12.w),
          ],
          // ⚠ `Expanded`: من غيره لابل طويل بيفيض الكارت عند مقياس ١٫٣.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleLg.copyWith(color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.titleToSubtitle.h),
                Text(
                  label,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.s8.w),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.tone});

  final IconData icon;
  final AppPillTone tone;

  @override
  Widget build(BuildContext context) {
    final ground = switch (tone) {
      AppPillTone.accent => AppSemanticColors.accentTint,
      AppPillTone.positive => AppSemanticColors.positiveSoft,
      AppPillTone.warning => AppSemanticColors.warningSoft,
      AppPillTone.danger => AppSemanticColors.dangerSoft,
      AppPillTone.info => AppSemanticColors.infoSoft,
      _ => AppSemanticColors.surfaceSunken,
    };
    final ink = switch (tone) {
      AppPillTone.accent => AppSemanticColors.accentText,
      AppPillTone.positive => AppSemanticColors.positive,
      AppPillTone.warning => AppSemanticColors.warning,
      AppPillTone.danger => AppSemanticColors.dangerOnSoft,
      AppPillTone.info => AppSemanticColors.info,
      _ => AppSemanticColors.textSecondary,
    };

    return Container(
      width: 40.r,
      height: 40.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: ground, borderRadius: AppRadius.rXs),
      child: Icon(icon, size: 20.r, color: ink),
    );
  }
}

/// شارة اتجاه — النص التاني من `stats_dashboard_row_widget.dart`.
///
/// employee-app بيرسمها بأيقونتين SVG (`upp_row_icon` / `down_row_icon`).
/// الكيت بيستخدم أيقونة ماتيريال عشان مايشحنش أصول لحاجة عندها أيقونة
/// جاهزة.
class AppTrendBadgeWidget extends StatelessWidget {
  const AppTrendBadgeWidget({
    required this.label,
    required this.isUp,
    this.upIsGood = true,
    super.key,
  });

  final String label;
  final bool isUp;

  /// ⚠ **الطلوع مش دايمًا كويس.** الأرباح طالعة = إيجابي؛ الإلغاءات
  /// طالعة = سلبي. الافتراضي `true` لأنه الحالة الغالبة.
  final bool upIsGood;

  @override
  Widget build(BuildContext context) {
    final good = isUp == upIsGood;
    return AppPillWidget(
      label: label,
      tone: good ? AppPillTone.positive : AppPillTone.danger,
      icon: isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
    );
  }
}
