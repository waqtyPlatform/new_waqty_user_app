import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_pill_widget.dart';

/// شريط تنبيه جوه الصفحة.
///
/// ⚠ **مش snackbar ومش dialog.** الفرق قرار مش ذوق:
///
/// | | |
/// |---|---|
/// | **البانر** | حالة **مستمرة** بتخص الشاشة دي: «الفرع مقفول النهاردة». بيفضل لحد ما الحالة تتغيّر. |
/// | **الـ snackbar** | نتيجة **فعل حصل**: «اتحفظ». بيروح لوحده. |
/// | **الـ dialog** | بيوقف الشغل لحد ما ترد. |
///
/// النغمة بتيجي من [AppPillTone] عشان اللون يبقى نفسه اللي في الشارة —
/// مافيش «أحمر بانر» و«أحمر شارة» مختلفين.
class AppBannerWidget extends StatelessWidget {
  const AppBannerWidget({
    required this.message,
    this.tone = AppPillTone.info,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String message;
  final String? title;

  final AppPillTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: _ground,
        borderRadius: AppRadius.rS,
        border: Border.all(color: _ink.withValues(alpha: .20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, size: 20.r, color: _ink),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.bodyMdStrong.copyWith(color: _ink),
                  ),
                  SizedBox(height: AppSpacing.titleToSubtitle.h),
                ],
                Text(
                  message,
                  style: AppTextStyles.bodyMd.copyWith(color: _ink),
                ),
                if (actionLabel != null && onAction != null) ...[
                  SizedBox(height: AppSpacing.s8.h),
                  InkWell(
                    onTap: onAction,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: AppSpacing.touchTarget.r,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          actionLabel!,
                          style: AppTextStyles.labelStrong.copyWith(
                            color: _ink,
                            decoration: TextDecoration.underline,
                            decorationColor: _ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: AppSpacing.touchTarget.r,
                height: AppSpacing.touchTarget.r,
                child: Icon(Icons.close_rounded, size: 18.r, color: _ink),
              ),
            ),
        ],
      ),
    );
  }

  IconData get _defaultIcon => switch (tone) {
    AppPillTone.positive => Icons.check_circle_outline_rounded,
    AppPillTone.warning => Icons.warning_amber_rounded,
    AppPillTone.danger => Icons.error_outline_rounded,
    _ => Icons.info_outline_rounded,
  };

  Color get _ground => switch (tone) {
    AppPillTone.accent => AppSemanticColors.surfaceAccentSoft,
    AppPillTone.positive => AppSemanticColors.positiveSoft,
    AppPillTone.warning => AppSemanticColors.warningSoft,
    AppPillTone.danger => AppSemanticColors.dangerSoft,
    _ => AppSemanticColors.infoSoft,
  };

  Color get _ink => switch (tone) {
    AppPillTone.accent => AppSemanticColors.accentText,
    AppPillTone.positive => AppSemanticColors.positive,
    AppPillTone.warning => AppSemanticColors.warning,
    // ⚠ `dangerOnSoft` — الأحمر العادي على الوردي بيدي 4.30:1.
    AppPillTone.danger => AppSemanticColors.dangerOnSoft,
    _ => AppSemanticColors.info,
  };
}
