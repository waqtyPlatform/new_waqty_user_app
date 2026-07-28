import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// مواعيد العمل — صف حي بيفتح على ٧ أيام.
///
/// القديم كان بيعرض «Monday» مرتين و «08.00 AM - 21.00 PM» — نص مش بس
/// إنجليزي، ده مستحيل أصلاً (٢١ على ساعة ١٢، ونقط مكان النقطتين).
/// السطر ده لوحده كان دليل إن الصف ده عمره ما اتعرض من داتا حقيقية.
///
/// وفي نقطة قبل اللون: حطينا دايرة صغيرة قبل الكلمة عشان حالة «مفتوح»
/// تبان حتى لو الشاشة أبيض وأسود أو العميل عنده عمى ألوان.
class ServiceProviderDetailsHoursWidget extends StatelessWidget {
  final BranchUiModel branch;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ServiceProviderDetailsHoursWidget({
    super.key,
    required this.branch,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // `positive` مش الفاتح — الفاتح تباينه ٢٫١ على خلفية فاتحة.
    final statusColor = branch.isOpenNow
        ? AppSemanticColors.positive
        : AppSemanticColors.textSecondary;

    return AppSurfaceWidget(
      onTap: onToggle,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52.h,
            child: Row(
              children: [
                Container(
                  height: 6.r,
                  width: 6.r,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                horizontalSpace(AppSpacing.s8),
                Expanded(
                  child: Text(
                    branch.openStatusLabel,
                    style: AppTextStyles.bodyMdStrong,
                  ),
                ),
                // السهم **بيلف** بدل ما الأيقونة تتبدّل. تبديل أيقونتين
                // بيقرا كقطع، واللفّة بتقول إن ده نفس العنصر بيفتح.
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: AppMotion.slow,
                  curve: AppMotion.standard,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.r,
                    color: AppSemanticColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // `AnimatedSize` بيدّي فتح وقفل ناعم من غير `StatefulWidget`
          // ولا `AnimationController` — الحالة نفسها لسه في الـ Cubit.
          AnimatedSize(
            duration: AppMotion.slow,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(),
                      verticalSpace(AppSpacing.s4),
                      ...branch.workingHours.map((day) => _DayRow(day: day)),
                      verticalSpace(AppSpacing.cardPadding),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final BranchWorkingDay day;

  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day.dayName,
              style: day.isToday
                  ? AppTextStyles.bodyMdStrong
                  : AppTextStyles.bodyMdMuted,
            ),
          ),
          // اليوم المقفول بيتعرض «مغلق» مش بيتشال — الفراغ بيعلّم العميل
          // إيقاع المحل.
          Text(
            day.hoursLabel,
            style: day.isClosed
                ? AppTextStyles.captionInk
                : AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
