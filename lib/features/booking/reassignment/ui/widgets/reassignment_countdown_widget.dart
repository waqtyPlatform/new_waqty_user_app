import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// عدّاد مهلة الاقتراح — **حلقة + رقم**.
///
/// ⚠ **بيتحسب من `holdExpiresAt` مش من رقم فاضل محفوظ.** الرقم الفاضل
/// لقطة وقت النداء؛ الأبلكيشن بيروح الخلفية وبيرجع فبيبقى بايت.
///
/// الحلقة بتتملّي عكسي على مدى المهلة الكاملة. الـ[fullDuration] بتيجي من
/// برّه لأن السيرفر مابيقولش المهلة كانت قد إيه — بس بيقول امتى بتخلص.
class ReassignmentCountdownWidget extends StatelessWidget {
  const ReassignmentCountdownWidget({
    required this.proposal,
    this.fullDuration = const Duration(minutes: 15),
    super.key,
  });

  final ReassignmentProposalUiModel proposal;

  /// مهلة الحجز المؤقت كاملة — `HOLD_MINUTES = 15` في
  /// `EmployeeBookingReassignmentService`.
  final Duration fullDuration;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = proposal.remainingSeconds(now);
    final isExpired = remaining <= 0;

    // الحلقة فاضية لما المهلة تخلص، ومليانة أول ما تبدأ.
    final value = isExpired
        ? 0.0
        : (remaining / fullDuration.inSeconds).clamp(0.0, 1.0);

    // آخر دقيقتين بالأحمر — مش زخرفة، دي اللحظة اللي العميل لازم يتحرك فيها.
    final isUrgent = !isExpired && remaining <= 120;

    return Row(
      children: [
        AppProgressRingWidget(
          value: value,
          size: 44.r,
          strokeWidth: 4.r,
          tone: isExpired
              ? AppSemanticColors.textTertiary
              : (isUrgent ? AppSemanticColors.danger : AppSemanticColors.accent),
        ),
        horizontalSpace(AppSpacing.s12),
        // ⚠ `Expanded` مش `Spacer` — عند مقياس خط ١٫٣ النص بيحتاج يتضغط
        // والحلقة مقاسها ثابت.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpired ? 'المهلة خلصت' : 'فاضل ${_format(remaining)}',
                style: AppTextStyles.cardTitle.copyWith(
                  color: isExpired
                      ? AppSemanticColors.textTertiary
                      : (isUrgent
                            ? AppSemanticColors.dangerOnSoft
                            : AppSemanticColors.textPrimary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                isExpired
                    ? 'الميعاد رجع متاح لغيرك'
                    : 'الميعاد محجوزلك لحد ما ترد',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// `م:ث` — بأرقام غربية زي باقي الأبلكيشن.
  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${AppFormat.digits(minutes)}:'
        '${AppFormat.digits(rest.toString().padLeft(2, '0'))}';
  }
}
