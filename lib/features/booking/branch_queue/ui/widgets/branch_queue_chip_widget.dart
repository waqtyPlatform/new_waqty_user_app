import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// مؤشر الدور المصغّر — بيقعد **جنب** `BookingStatusChipWidget` في كارت
/// الحجز جوه اللستة.
///
/// ## الحشوة متطابقة عن قصد
///
/// ٨ أفقي و٤ رأسي و`pill` و`overline` — نفس أرقام شارة الحالة بالظبط.
/// شارتين لازقين في بعض بحشوتين مختلفتين بيقروا كأنهم من أبلكيشنين، وده
/// بالظبط نوع التفكّك اللي إعادة التصميم دي بتصلحه.
///
/// ## بترجع صفر لما مفيش طابور
///
/// حجز مش النهاردة مالوش دور، وحجز خلص كمان. في الحالتين الشارة
/// **مابتترسمش خالص** ([SizedBox.shrink]) بدل ما تقول «—» أو تسيب مساحة
/// فاضية: صف فيه شارة وصف فيه فراغ بنفس المقاس بيخلي اللستة تبان مليانة
/// خانات مكسورة.
class BranchQueueChipWidget extends StatelessWidget {
  final QueueUiModel queue;

  const BranchQueueChipWidget({super.key, required this.queue});

  @override
  Widget build(BuildContext context) {
    if (!queue.state.isLive) return const SizedBox.shrink();

    final (background, foreground) = _colors;

    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.standard,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      child: AnimatedDefaultTextStyle(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        style: AppTextStyles.overline.copyWith(color: foreground),
        child: Text(_label, maxLines: 1),
      ),
    );
  }

  String get _label => switch (queue.state) {
    QueueState.yourTurn => 'دورك دلوقتي',
    QueueState.inService => 'جاري تنفيذها',
    _ => '${AppFormat.digits(queue.aheadOfMe)} قدامك',
  };

  /// الأخضر للحالتين اللي محتاجين حركة من العميل بس. لو «جاري الخدمة»
  /// خدت أخضر كمان، مابقاش فيه فرق بين «تحرّك» و«اقعد مطمن».
  (Color, Color) get _colors => queue.state.needsAttention
      ? (AppSemanticColors.accentSoft, AppSemanticColors.accent)
      : (AppSemanticColors.surfaceSunken, AppSemanticColors.textOnSunken);
}
