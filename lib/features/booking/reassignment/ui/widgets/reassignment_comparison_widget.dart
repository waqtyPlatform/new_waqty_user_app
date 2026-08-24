import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **كان ← بقى** — أهم widget في الشاشة.
///
/// السؤال الوحيد في دماغ العميل هو «إيه اللي اتغيّر بالظبط؟». عرض الاقتراح
/// لوحده بيسيبه يقارن من الذاكرة، والمقارنة دي هي كل القرار.
///
/// ⚠ **رأسي مش أفقي.** عمودين جنب بعض بيتقصّوا عند مقياس خط ١٫٣ (اسم موظف
/// + تاريخ + وقت في نص شاشة). الشكل الرأسي بياخد سطرين زيادة وبيفضل مقروء
/// لحد ١٫٣ من غير قص.
class ReassignmentComparisonWidget extends StatelessWidget {
  const ReassignmentComparisonWidget({
    required this.request,
    super.key,
  });

  final ReassignmentUiModel request;

  @override
  Widget build(BuildContext context) {
    final proposal = request.activeProposal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Line(
          label: 'كان',
          employeeName: request.originalEmployeeName,
          startAt: request.originalStartAt,
          isStruck: true,
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s8.h),
          // ⚠ **سهم لتحت مش اتجاهي** — مابيتقلبش في الـRTL،
          // فمفيش داعي لـ`DirectionalChevronWidget` (وهو أصلاً فيه
          // `forward`/`back` بس). النزول معناه «اللي تحته هو الجديد»
          // في اللغتين.
          child: Icon(
            Icons.arrow_downward_rounded,
            size: AppSpacing.s16.r,
            color: AppSemanticColors.textTertiary,
          ),
        ),
        if (proposal != null)
          _Line(
            label: 'بقى',
            employeeName: proposal.employeeName,
            startAt: proposal.startAt,
          )
        else
          Text(
            'الفرع لسه بيدوّر على ميعاد',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppSemanticColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.employeeName,
    required this.startAt,
    this.isStruck = false,
  });

  final String label;
  final String employeeName;
  final DateTime? startAt;
  final bool isStruck;

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTextStyles.cardTitle.copyWith(
      color: isStruck
          ? AppSemanticColors.textTertiary
          : AppSemanticColors.textPrimary,
      decoration: isStruck ? TextDecoration.lineThrough : null,
      decorationColor: AppSemanticColors.textTertiary,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اللابل عرضه ثابت عشان السطرين يتحاذوا — «كان» و«بقى» كلمتين
        // قصيرتين فالتثبيت مايقصّش حاجة.
        SizedBox(
          width: 44.w,
          child: Text(
            label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ⚠ `Expanded` مش `Spacer` — الاسم والتاريخ بيتضغطوا عند ١٫٣.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                employeeName.isEmpty ? '—' : employeeName,
                style: valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (startAt != null) ...[
                verticalSpace(AppSpacing.s4),
                Text(
                  '${AppFormat.relativeDate(startAt!)} · '
                  '${AppFormat.time(startAt!)}',
                  style: AppTextStyles.caption.copyWith(
                    decoration: isStruck ? TextDecoration.lineThrough : null,
                    decorationColor: AppSemanticColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
