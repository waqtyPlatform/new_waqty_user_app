import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
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
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_date_strip_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_proposals_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_slots_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_staff_row_widget.dart';

/// خدمة واحدة في السلة — كارت بيتفتح ويتقفل.
///
/// ## ليه أكورديون مش كل الخدمات مفرودة
///
/// كل خدمة محتاجة صف أخصائي وشريط تواريخ وشبكة مواعيد. تلات خدمات
/// مفرودين = تلاتة من كل ده ورا بعض، يعني صفحة مالهاش قاع والعميل
/// مش عارف هو فين منها. الداشبورد بيعمل كده فعلاً — بس هو على شاشة
/// عريضة بعمودين وشريط جانبي ثابت، والموبايل مالوش الرفاهية دي.
///
/// كارت واحد مفتوح في المرة بيخلي الـ N خدمات **تتابع** بدل ما تبقى
/// استمارة: تختار ميعاد، الكارت يتقفل، اللي بعده يتفتح لوحده.
class CreateBookingItemCardWidget extends StatelessWidget {
  final BookingDraftItem item;

  /// ترتيبه في السلة — بيتعرض كرقم لما يكون لسه من غير ميعاد.
  final int index;

  final bool isLoadingSlots;
  final bool canGoToPreviousMonth;

  final VoidCallback onExpand;
  final ValueChanged<EmployeeUiModel> onEmployeeSelected;
  final ValueChanged<DateTime> onDateTap;
  final ValueChanged<int> onMonthChange;
  final ValueChanged<SlotUiModel> onSlotTap;

  /// `null` لما تكون دي الخدمة الوحيدة — حجز من غير خدمات مالوش معنى.
  final VoidCallback? onRemove;

  /// مخرج من الخدمة اللي مالهاش أخصائيين في الفرع ده.
  final VoidCallback onPickAnotherService;

  /// دخول قائمة انتظار الفرع لما اليوم مليان أو الميعاد راح.
  final VoidCallback onJoinWaitlist;

  /// قلب نافذة وقت في الاقتراحات.
  final ValueChanged<SlotPeriod> onPeriodToggle;

  /// تبديل بين الاقتراحات والشبكة الكاملة.
  final VoidCallback onBrowseAll;

  const CreateBookingItemCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isLoadingSlots,
    required this.canGoToPreviousMonth,
    required this.onExpand,
    required this.onEmployeeSelected,
    required this.onDateTap,
    required this.onMonthChange,
    required this.onSlotTap,
    required this.onPickAnotherService,
    required this.onJoinWaitlist,
    required this.onPeriodToggle,
    required this.onBrowseAll,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = item.isExpanded;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
      child: AppSurfaceWidget(
        // مفتوح؟ الكارت نفسه مش قابل للضغط — الكنترولات اللي جواه هي
        // اللي بتستقبل. مقفول؟ الكارت كله هدف لمس واحد كبير.
        onTap: expanded ? null : onExpand,
        radius: AppRadius.m,
        // **الحد هنا حالة، مش زينة.** الخدمة اللي لسه من غير ميعاد
        // ناقصة حاجة، والحد الباهت بيقول كده من غير ما نكتبها.
        border: !item.isScheduled && !expanded
            ? Border.all(color: AppSemanticColors.borderStrong)
            : null,
        padding: EdgeInsets.all(AppSpacing.cardPadding.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            // بيتفتح بحركة بدل ما ينطّ — الكارت بيكبر تحت صباع العميل
            // وهو شايف، فبيفهم إن ده نفس الكارت مش شاشة جديدة.
            AnimatedSize(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _body(context)
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  // ── الرأس ────────────────────────────────────────────────────────────

  Widget _header() {
    return Row(
      children: [
        _StateMark(index: index, isScheduled: item.isScheduled),
        horizontalSpace(AppSpacing.s12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMdStrong,
              ),
              verticalSpace(AppSpacing.titleToSubtitle),
              Text(
                _subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: item.isScheduled
                    ? AppTextStyles.captionInk
                    : AppTextStyles.caption,
              ),
            ],
          ),
        ),
        horizontalSpace(AppSpacing.s8),
        _trailing(),
      ],
    );
  }

  /// مقفول ومتحدد: «الخميس ٢٤ يوليو · ٦:٠٠ م · مع أحمد».
  /// مفتوح أو من غير ميعاد: المدة بس — الميعاد لسه بيتختار تحت.
  String get _subtitle {
    if (!item.isScheduled) {
      return '${AppFormat.duration(item.service.durationMinutes)} · محتاجة ميعاد';
    }

    final slot = item.selectedSlot!;
    return '${AppFormat.relativeDate(slot.startAt)} · ${AppFormat.time(slot.startAt)}'
        ' · مع ${item.resolvedEmployeeName}';
  }

  Widget _trailing() {
    if (item.isExpanded) {
      return onRemove == null
          ? const SizedBox.shrink()
          : IconButton(
              onPressed: onRemove,
              tooltip: 'شيل الخدمة',
              iconSize: 20.r,
              constraints: BoxConstraints(
                minWidth: AppSpacing.touchTarget.r,
                minHeight: AppSpacing.touchTarget.r,
              ),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.close_rounded,
                color: AppSemanticColors.textTertiary,
              ),
            );
    }

    if (!item.isScheduled) {
      return Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 24.r,
        color: AppSemanticColors.textSecondary,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(AppFormat.money(item.price), style: AppTextStyles.bodyMdStrong),
        verticalSpace(AppSpacing.titleToSubtitle),
        Text('تغيير', style: AppTextStyles.label),
      ],
    );
  }

  // ── الجسم المفتوح ────────────────────────────────────────────────────

  Widget _body(BuildContext context) {
    // **مفيش حد بيعمل الخدمة دي في الفرع ده.**
    //
    // نتيجة حقيقية من السيرفر — التعيينات (أخصائي × خدمة × فرع) ممكن
    // تبقى فاضية. الكارت كان هيعرض صف أخصائي فاضي وتقويم مالوش أيام
    // ومساحة مواعيد فاضية: تلات فراغات ورا بعض العميل يفسّرها «الأبلكيشن
    // باظ». السطر ده بيقول السبب ويدي مخرج.
    if (item.employees.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(top: AppSpacing.s16.h),
        child: EmptyStateWidget(
          icon: Icons.person_off_outlined,
          title: 'الخدمة دي مش متاحة في الفرع ده',
          message: 'جرّب فرع تاني، أو غيّر الخدمة',
          // **الطريق المسدود لازم يبقى ليه باب.**
          //
          // زرار الشيل بيختفي لما الخدمة دي هي الوحيدة في السلة
          // (`items.length > 1`)، والحجز مش هيكمّل من غير ميعاد — يعني
          // العميل كان بيقعد محبوس في كارت مالوش قدام ولا ورا. الزرار
          // ده بيرجّعه لمختار الخدمات.
          actionLabel: 'اختار خدمة تانية',
          onAction: onPickAnotherService,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(AppSpacing.s16),
        CreateBookingStaffRowWidget(
          employees: item.employees,
          selectedEmployee: item.employee,
          onEmployeeSelected: onEmployeeSelected,
        ),
        verticalSpace(AppSpacing.s24),

        // **الاقتراحات هي الافتراضي، والشبكة ورا ضغطة.**
        //
        // مش «بدل» — الاتنين موجودين. الاقتراحات بتغطي الحالة الغالبة
        // (نافذة مقبولة، أقرب ميعاد فيها)، والشبكة للي عايز الساعة
        // ٦:١٥ بالذات.
        if (!item.isBrowsingAll)
          CreateBookingProposalsWidget(
            proposals: item.proposals,
            selectedSlot: item.selectedSlot,
            periods: item.periods,
            isLoading: isLoadingSlots,
            baselinePrice: item.baselinePrice,
            onPeriodToggle: onPeriodToggle,
            onSlotTap: onSlotTap,
            onBrowseAll: onBrowseAll,
            onJoinWaitlist: onJoinWaitlist,
          )
        else ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onBrowseAll,
              icon: Icon(Icons.arrow_forward_rounded, size: 18.r),
              label: Text('رجوع للاقتراحات', style: AppTextStyles.label),
            ),
          ),
          verticalSpace(AppSpacing.s8),
          CreateBookingDateStripWidget(
            availableDates: item.availableDates,
            selectedDate: item.selectedDate,
            currentMonth: item.currentMonth,
            canGoToPreviousMonth: canGoToPreviousMonth,
            durationMinutes: item.service.durationMinutes,
            onDateTap: onDateTap,
            onMonthChange: onMonthChange,
            onFullDayTap: onJoinWaitlist,
          ),
          // ٢٤ في المكانين — نفس العلاقة بنفس القيمة.
          verticalSpace(AppSpacing.s24),
          CreateBookingSlotsWidget(
            slots: item.slots,
            selectedSlot: item.selectedSlot,
            takenSlot: item.takenSlot,
            isLoading: isLoadingSlots,
            baselinePrice: item.baselinePrice,
            onSlotTap: onSlotTap,
            onJoinWaitlist: onJoinWaitlist,
          ),
        ],
      ],
    );
  }
}

/// علامة الحالة على شمال الكارت.
///
/// رقم لما لسه من غير ميعاد، وعلامة صح لما يتحدد. الرقم بيدّي العميل
/// إحساس بطول التتابع («أنا في ٢ من ٣»)، والصح بيقفل الموضوع.
class _StateMark extends StatelessWidget {
  final int index;
  final bool isScheduled;

  const _StateMark({required this.index, required this.isScheduled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.standard,
      height: 26.r,
      width: 26.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isScheduled
            ? AppSemanticColors.accent
            : AppSemanticColors.surfaceSunken,
        shape: BoxShape.circle,
      ),
      child: isScheduled
          ? Icon(
              Icons.check_rounded,
              size: 16.r,
              color: AppSemanticColors.textOnAccent,
            )
          : Text(
              AppFormat.digits(index + 1),
              style: AppTextStyles.captionStrong,
            ),
    );
  }
}
