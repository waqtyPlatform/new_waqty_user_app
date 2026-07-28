import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/empty_state_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// المواعيد — مقسّمة صباحًا / بعد الظهر / مساءً، ٣ في الصف.
///
/// اليوم الكامل بيطلع ٣٠+ ميعاد. حايط مواعيد من غير تقسيم بيبقى مهمة
/// مسح بالعين مش اختيار.
///
/// **المجموعة الفاضية بتتقفل في سطر باهت، متتخفيش** — إن مفيش مواعيد
/// بعد الظهر دي معلومة برضه.
class CreateBookingSlotsWidget extends StatelessWidget {
  final List<SlotUiModel> slots;
  final SlotUiModel? selectedSlot;
  final SlotUiModel? takenSlot;
  final bool isLoading;
  final double baselinePrice;
  final ValueChanged<SlotUiModel> onSlotTap;

  const CreateBookingSlotsWidget({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.baselinePrice,
    required this.onSlotTap,
    this.takenSlot,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // shimmer في نفس الشبكة ٣ في الصف — عشان مفيش حاجة تتزحلق لما
      // المواعيد الحقيقية توصل.
      return SkeletonGroupWidget(
        child: Wrap(
          spacing: AppSpacing.chipGap.w,
          runSpacing: AppSpacing.chipGap.h,
          children: List<Widget>.generate(
            9,
            // الارتفاع بيتقرا من الشيب نفسه — فمفيش إزاحة لما المواعيد
            // الحقيقية توصل.
            (_) => SkeletonBoxWidget(
              width: 96,
              height: _SlotChip.height,
              radius: AppRadius.pill,
              animate: false,
            ),
          ),
        ),
      );
    }

    if (slots.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.event_busy_outlined,
        title: 'اليوم ده مليان',
        message: 'جرّب يوم تاني من الشريط اللي فوق',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: SlotPeriod.values.map((period) {
        final periodSlots = slots.where((s) => s.period == period).toList();
        return _PeriodGroup(
          period: period,
          slots: periodSlots,
          selectedSlot: selectedSlot,
          takenSlot: takenSlot,
          baselinePrice: baselinePrice,
          onSlotTap: onSlotTap,
        );
      }).toList(),
    );
  }
}

class _PeriodGroup extends StatelessWidget {
  final SlotPeriod period;
  final List<SlotUiModel> slots;
  final SlotUiModel? selectedSlot;
  final SlotUiModel? takenSlot;
  final double baselinePrice;
  final ValueChanged<SlotUiModel> onSlotTap;

  const _PeriodGroup({
    required this.period,
    required this.slots,
    required this.selectedSlot,
    required this.takenSlot,
    required this.baselinePrice,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
        child: Text(
          '${period.label} · مفيش مواعيد',
          style: AppTextStyles.caption,
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${period.label} · ${AppFormat.digits(slots.length)} مواعيد',
                style: AppTextStyles.bodyMdStrong,
              ),
              // آخر ميعادين؟ نقول كده — الندرة معلومة مفيدة للعميل.
              // نفس حشوة `BookingStatusChipWidget` بالظبط — الشارتين
              // كانوا بحشوتين مختلفتين وشكلهم مش واحد.
              if (slots.length <= 2) ...[
                horizontalSpace(AppSpacing.s8),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.s8.w,
                    vertical: AppSpacing.s4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppSemanticColors.warningSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill.r),
                  ),
                  child: Text(
                    'آخر موعد',
                    style: AppTextStyles.overline.copyWith(
                      color: AppSemanticColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
          verticalSpace(AppSpacing.headerToContent),
          Wrap(
            spacing: AppSpacing.chipGap.w,
            runSpacing: AppSpacing.chipGap.h,
            children: slots.map((slot) {
              final isTaken =
                  takenSlot != null && takenSlot!.startAt == slot.startAt;
              return _SlotChip(
                slot: slot,
                isSelected: selectedSlot?.startAt == slot.startAt,
                isTaken: isTaken,
                baselinePrice: baselinePrice,
                onTap: isTaken ? null : () => onSlotTap(slot),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final SlotUiModel slot;
  final bool isSelected;
  final bool isTaken;
  final double baselinePrice;
  final VoidCallback? onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.isTaken,
    required this.baselinePrice,
    this.onTap,
  });

  /// **ارتفاع ثابت.** قبل كده الشيب كان ٤٤ عادي و٥٣٫٦ لما يبقى فيه فرق
  /// سعر (لأن السعر كان في عمود تحت الوقت) — فصفوف الـ `Wrap` كانت
  /// **مهلهلة**: صف فيه شيب طويل يزوّد ارتفاع الصف كله.
  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final hasDifferentPrice = slot.price != baselinePrice;

    final textColor = isSelected
        ? AppSemanticColors.textOnAccent
        : isTaken
        ? AppSemanticColors.textOnSunken
        : AppSemanticColors.textPrimary;

    return AppSurfaceWidget(
      onTap: onTap,
      height: height.h,
      radius: AppRadius.pill,
      level: isTaken ? AppElevation.sunken : AppElevation.raised,
      color: isSelected ? AppSemanticColors.accent : null,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 72.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللون لوحده ما يكفيش على شيب فيه كلام — علامة صح كمان.
            // بتكبر من صفر بمنحنى `emphasis` فبتحس إنها «طلعت» مش ظهرت.
            AnimatedScale(
              scale: isSelected ? 1 : 0,
              duration: AppMotion.fast,
              curve: AppMotion.emphasis,
              child: Icon(
                Icons.check_rounded,
                size: 16.r,
                color: AppSemanticColors.textOnAccent,
              ),
            ),
            if (isSelected) horizontalSpace(AppSpacing.s4),
            AnimatedDefaultTextStyle(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              style: AppTextStyles.bodyMdStrong.copyWith(
                color: textColor,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
              // فرق السعر على **نفس السطر**: «٦:٠٠ م · +٢٠».
              // وبيظهر لما يكون مختلف بس، مش على كل شيب.
              child: Text(
                hasDifferentPrice && !isTaken
                    ? '${AppFormat.time(slot.startAt)} · +${AppFormat.digits((slot.price - baselinePrice).toInt())}'
                    : AppFormat.time(slot.startAt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
