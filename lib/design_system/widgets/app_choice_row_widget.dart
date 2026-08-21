import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon_widget.dart';

/// شكل علامة الاختيار.
enum AppChoiceStyle {
  /// اختيارات متعددة — مربع بعلامة صح.
  checkbox,

  /// اختيار واحد — دايرة بنقطة.
  radio,
}

/// صف اختيار — **الصف كله هدف اللمس، مش المربع**.
///
/// ⚠ ده الفرق الوحيد المهم عن `CheckboxListTile` بتاعة ماتيريال: هناك
/// اللابل والمربع بيتحطوا جوه `ListTile` بحشوة ثابتة مالهاش دعوة بسلّم
/// المسافات بتاعنا، والارتفاع الافتراضي بيتجاهل `visualDensity` في نص
/// الحالات.
///
/// الحالة المختارة بتاخد **سطح وحد** — واحدة من تلات حالات الحد المسموحة.
class AppChoiceRowWidget extends StatelessWidget {
  const AppChoiceRowWidget({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.style = AppChoiceStyle.checkbox,
    this.enabled = true,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? subtitle;

  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final AppChoiceStyle style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ink = enabled
        ? AppSemanticColors.textPrimary
        : AppSemanticColors.textTertiary;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s8.h),
      child: Material(
        color: selected
            ? AppSemanticColors.surfaceAccentSoft
            : AppSemanticColors.surfaceRaised,
        borderRadius: AppRadius.rS,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppRadius.rS,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            constraints: BoxConstraints(minHeight: AppSpacing.touchTarget.r),
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              borderRadius: AppRadius.rS,
              border: Border.all(
                color: selected
                    ? AppSemanticColors.accentText
                    : AppSemanticColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _Mark(style: style, selected: selected, enabled: enabled),
                SizedBox(width: AppSpacing.s12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMdStrong.copyWith(color: ink),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.titleToSubtitle.h),
                        Text(subtitle!, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppSpacing.s8.w),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({
    required this.style,
    required this.selected,
    required this.enabled,
  });

  final AppChoiceStyle style;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final on = selected && enabled;
    final line = enabled
        ? (selected
              ? AppSemanticColors.accentText
              : AppSemanticColors.borderStrong)
        : AppSemanticColors.border;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      width: 22.r,
      height: 22.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? AppSemanticColors.accentText : Colors.transparent,
        borderRadius: style == AppChoiceStyle.checkbox
            ? BorderRadius.circular(AppRadius.xs.r / 2)
            : AppRadius.rPill,
        border: Border.all(color: line, width: 1.5),
      ),
      child: on
          ? (style == AppChoiceStyle.checkbox
                ? AppIconWidget(
                    AppIcons.check,
                    size: 14,
                    color: AppSemanticColors.textOnAccentDeep,
                  )
                : Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: AppSemanticColors.textOnAccentDeep,
                      shape: BoxShape.circle,
                    ),
                  ))
          : null,
    );
  }
}
