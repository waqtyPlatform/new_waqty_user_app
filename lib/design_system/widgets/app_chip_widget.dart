import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// شيب فلتر — منقول من `AccountSupportChipWidget`.
///
/// ⚠ **ارتفاعه [AppSpacing.touchTarget] على الأقل.** شيبس الفلاتر في
/// user-app كانت ٣٧، والقاعدة ٤٤.
///
/// الحالة المختارة بتاخد **حد** — واحدة من تلات الحالات الوحيدة اللي
/// مسموح فيها بحد.
class AppChipWidget extends StatelessWidget {
  const AppChipWidget({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String label;

  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ink = isSelected
        ? AppSemanticColors.accentText
        : AppSemanticColors.textSecondary;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      constraints: BoxConstraints(minHeight: AppSpacing.touchTarget.r),
      decoration: BoxDecoration(
        color: isSelected
            ? AppSemanticColors.surfaceAccentSoft
            : AppSemanticColors.surfaceSunken,
        borderRadius: AppRadius.rPill,
        border: isSelected
            ? Border.all(color: AppSemanticColors.accentText, width: 1.5)
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.rPill,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rPill,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s16.w,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16.r, color: ink),
                  SizedBox(width: AppSpacing.s4.w),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMdStrong.copyWith(color: ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
