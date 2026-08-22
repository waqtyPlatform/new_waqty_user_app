import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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

  /// يعرض فرق السعر على الميعاد («٤:٣٠ م · +٥٠»)؟
  ///
  /// ⚠ **بيتقفل في حجز الاستحقاق.** الباقة والمتابعة **مدفوعين أصلاً**،
  /// فمفيش سعر مرجعي نقارن بيه — و[baselinePrice] بصفر بتخلّي كل ميعاد
  /// ليه سعر يبان كأنه زيادة. العميلة اللي دفعت باقة وشافت «+٥٠» جنب كل
  /// ميعاد هتفتكر إن فيه فلوس تانية عليها.
  final bool showPriceDelta;

  final ValueChanged<SlotUiModel> onSlotTap;

  /// `null` = مفيش قائمة انتظار (مثلاً اليوم مقفول مش مليان).
  final VoidCallback? onJoinWaitlist;

  const CreateBookingSlotsWidget({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.baselinePrice,
    required this.onSlotTap,
    this.showPriceDelta = true,
    this.onJoinWaitlist,
    this.takenSlot,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // shimmer في نفس الشبكة ٣ في الصف — عشان مفيش حاجة تتزحلق لما
      // المواعيد الحقيقية توصل.
      return AppSkeletonGroupWidget(
        child: Wrap(
          spacing: AppSpacing.chipGap.w,
          runSpacing: AppSpacing.chipGap.h,
          children: List<Widget>.generate(
            9,
            // الارتفاع بيتقرا من الشيب نفسه — فمفيش إزاحة لما المواعيد
            // الحقيقية توصل.
            (_) => AppSkeletonBoxWidget(
              width: 96,
              height: _SlotChip.height,
              radius: AppRadius.pill,
            ),
          ),
        ),
      );
    }

    if (slots.isEmpty) {
      // **«مليان» أحسن مدخل لقائمة الانتظار في المنتج كله.**
      //
      // ده طلب قابل قدامه عرض فاضي — مش «مقفول» اللي بيقفل الكلام.
      // `POST /user/waitlist` مبني وشغال في السيرفر، والأبلكيشن كان
      // بيرد على اليوم المليان بطريق مسدود.
      return AppEmptyStateWidget(
        icon: Icons.event_busy_outlined,
        title: 'اليوم ده مليان',
        message:
            'جرّب يوم تاني من الشريط اللي فوق، أو خلينا نبلّغك أول ما يفضى',
        actionLabel: onJoinWaitlist == null ? null : 'ضيفني لقائمة الانتظار',
        onAction: onJoinWaitlist,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...SlotPeriod.values.map((period) {
          final periodSlots = slots.where((s) => s.period == period).toList();
          return _PeriodGroup(
            period: period,
            slots: periodSlots,
            selectedSlot: selectedSlot,
            takenSlot: takenSlot,
            baselinePrice: baselinePrice,
            showPriceDelta: showPriceDelta,
            onSlotTap: onSlotTap,
          );
        }),

        // **الميعاد اللي راح ليه مخرج تاني غير البدائل.**
        //
        // العميل كان عايز الميعاد ده بالذات. البدائل حل، وقائمة الانتظار
        // حل تاني — «لو رجع، بلّغني». من غير ده، خطّاف «الميعاد اتحجز»
        // بيختبر الفشل بس ومابيختبرش التعافي.
        if (takenSlot != null && onJoinWaitlist != null) ...[
          verticalSpace(AppSpacing.s8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onJoinWaitlist,
              icon: Icon(Icons.notifications_active_outlined, size: 18.r),
              label: Text(
                'بلّغني لو الميعاد ده رجع',
                style: AppTextStyles.label,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PeriodGroup extends StatelessWidget {
  final bool showPriceDelta;

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
    this.showPriceDelta = true,
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
          // `Expanded` على العنوان: «بعد الظهر · ١٢ مواعيد» جنب شارة
          // «آخر موعد» كانوا **بيفيضوا ٥٥ بكسل** عند مقياس خط ١٫٣.
          Row(
            children: [
              Expanded(
                child: Text(
                  '${period.label} · ${AppFormat.digits(slots.length)} مواعيد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
              ),
              // آخر ميعادين؟ نقول كده — الندرة معلومة مفيدة للعميل.
              // بقت `AppPillWidget` بدل `Container` مكتوب بالإيد — نفس
              // شكل كل شارات الأبلكيشن، ومن غير حشوة متكرّرة.
              if (slots.length <= 2) ...[
                horizontalSpace(AppSpacing.s8),
                const AppPillWidget(
                  label: 'آخر موعد',
                  tone: AppPillTone.warning,
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
                showPriceDelta: showPriceDelta,
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
  final bool showPriceDelta;
  final VoidCallback? onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.isTaken,
    required this.baselinePrice,
    this.showPriceDelta = true,
    this.onTap,
  });

  /// **ارتفاع ثابت.** قبل كده الشيب كان ٤٤ عادي و٥٣٫٦ لما يبقى فيه فرق
  /// سعر (لأن السعر كان في عمود تحت الوقت) — فصفوف الـ `Wrap` كانت
  /// **مهلهلة**: صف فيه شيب طويل يزوّد ارتفاع الصف كله.
  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final hasDifferentPrice = showPriceDelta && slot.price != baselinePrice;

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
