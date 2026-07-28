import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// الحالة الفاضية: أيقونة + **عنوان** + شرح + إجراء واحد.
///
/// القاعدة: الفاضي عمره ما يبقى شاشة بيضا. لو مفيش حاجة نعرضها، لازم يبقى
/// فيه حاجة العميل يعملها.
///
/// العنوان مضاف جديد. قبل كده كان سطر واحد ١٤/٤٠٠ رمادي بيعمل الدورين —
/// **فالفاضي كان بيقرا كأنه رسالة خطأ**. العنوان بيقول «إيه اللي حصل»
/// والشرح بيقول «تعمل إيه».
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;

  /// جملة قصيرة بصيغة الخبر: «مفيش حجوزات» — مش «لا توجد بيانات».
  final String title;

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s32.w,
          vertical: AppSpacing.s24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72.r,
              width: 72.r,
              decoration: const BoxDecoration(
                color: AppSemanticColors.surfaceSunken,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.r,
                color: AppSemanticColors.textOnSunken,
              ),
            ),
            verticalSpace(AppSpacing.s16),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
            verticalSpace(AppSpacing.s4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMdMuted,
            ),
            if (actionLabel != null && onAction != null) ...[
              verticalSpace(AppSpacing.s16),
              // ارتفاع الـ ٤٤ نقطة جاي من `textButtonTheme` في الثيم.
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
