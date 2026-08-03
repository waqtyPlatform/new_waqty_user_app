import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';

/// شاشة التأكيد — **مجمّعة بالزيارة**.
///
/// الزيارة = رحلة للمحل. عادةً يوم واحد، بس مش دايمًا: صبغة الصبح وحمام
/// كريم بالليل في نفس اليوم دول رحلتين، والعميل بيروح ويرجع.
///
/// وهي أول وآخر مرة العميل يشوف الكلمة: وهو بيحجز كان بيضيف خدمات
/// ويحدّد مواعيد وخلاص، وهنا بس بيشوف الشكل النهائي اللي هيروح بيه.
///
/// ## ليه فيه زرار على الفواصل
///
/// السيرفر بياخد تجميع الزيارات زي ما بيتبعت وماعندوش قاعدة يراجعه بيها،
/// و`checkInVisit` بيسجّل وصول **واحد للزيارة كلها**. يعني دمج غلط
/// بيخلي الفرع يعمل check-in الصبح والعميل يفضل «واصل» لحد بالليل.
///
/// الفارق بيقرر لوحده في الحالة الشائعة، بس القرار ظاهر وقابل للتعديل —
/// لأن العميل هو الوحيد اللي عارف هو هيقعد مستني ولا هيروح ويرجع.
class CreateBookingSummaryWidget extends StatelessWidget {
  final CreateBookingCubit cubit;

  const CreateBookingSummaryWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(label: 'المكان', value: cubit.providerName),
        if (cubit.selectedBranch != null)
          _row(label: 'الفرع', value: cubit.selectedBranch!.name),

        verticalSpace(AppSpacing.s16),

        ..._timeline(),

        verticalSpace(AppSpacing.s8),
        _NotesField(cubit: cubit),

        verticalSpace(AppSpacing.s16),
        const AppHairlineWidget(),
        verticalSpace(AppSpacing.s12),

        Row(
          children: [
            Text('الإجمالي', style: AppTextStyles.bodyMdMuted),
            horizontalSpace(AppSpacing.s8),
            // عدد الخدمات جنب اللابل — عشان الرقم الكبير يبقى مفهوم إنه
            // مجموع، مش سعر خدمة.
            if (cubit.items.length > 1)
              Text(
                '${AppFormat.digits(cubit.items.length)} خدمات · '
                '${AppFormat.duration(cubit.totalDuration)}',
                style: AppTextStyles.caption,
              ),
            const Spacer(),
            // أكبر خط في الشاشة — ده الرقم اللي العميل بيوافق عليه.
            Text(AppFormat.money(cubit.totalPrice), style: AppTextStyles.titleLg),
          ],
        ),
        verticalSpace(AppSpacing.s4),
        Text('الدفع في الفرع', style: AppTextStyles.caption),

        // أهم سطر في الشاشة كلها.
        //
        // السيرفر فعلاً بيمنع إلغاء حجز النهاردة. العميل اللي يكتشف إنه
        // ارتبط بحاجة مش قادر يلغيها **بعد** ما يأكد — دي أوحش خسارة ثقة
        // ممكنة في المنتج ده، وثمنها سطر واحد في المكان الصح.
        if (cubit.isSameDayBooking) ...[
          verticalSpace(AppSpacing.s16),
          _Notice(
            message: cubit.items.length > 1
                ? 'فيه خدمة النهاردة — الحجز مش هينفع يتلغي بعد التأكيد'
                : 'حجز النهاردة مش هينفع يتلغي بعد التأكيد',
          ),
        ],
        verticalSpace(AppSpacing.s16),
      ],
    );
  }

  /// الزيارات وفواصلها بالترتيب الزمني.
  ///
  /// الفاصل بيتحط **قبل** عنوان الزيارة اللي بعده — عشان يقرا «فيه فراغ
  /// هنا، فبتبدأ زيارة جديدة» بدل ما يقرا كأنه تابع للزيارة اللي فاتت.
  List<Widget> _timeline() {
    final visits = cubit.visits;
    final widgets = <Widget>[];

    for (var v = 0; v < visits.length; v++) {
      final visit = visits[v];

      final openingBoundary = cubit.boundaryBefore(visit.first);
      if (openingBoundary != null) {
        widgets.add(
          _BoundaryRow(boundary: openingBoundary, onToggle: cubit.toggleBoundary),
        );
      }

      widgets.add(
        _VisitHeader(
          title: _visitTitle(v, visits.length),
          date: visit.first.selectedSlot!.startAt,
        ),
      );

      for (var i = 0; i < visit.length; i++) {
        if (i > 0) {
          final boundary = cubit.boundaryBefore(visit[i]);
          if (boundary != null) {
            widgets.add(
              _BoundaryRow(boundary: boundary, onToggle: cubit.toggleBoundary),
            );
          }
        }
        widgets.add(_ItemLine(item: visit[i], onChange: cubit.goToItem));
      }

      widgets.add(verticalSpace(AppSpacing.s16));
    }

    return widgets;
  }

  /// زيارة واحدة؟ اليوم لوحده يكفي — كلمة «الزيارة» ساعتها ضوضاء.
  String _visitTitle(int index, int total) {
    if (total == 1) return '';
    const ordinals = <String>[
      'الزيارة الأولى',
      'الزيارة التانية',
      'الزيارة التالتة',
      'الزيارة الرابعة',
      'الزيارة الخامسة',
    ];
    if (index < ordinals.length) return ordinals[index];
    return 'الزيارة ${AppFormat.digits(index + 1)}';
  }

  Widget _row({required String label, required String value}) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            child: Text(label, style: AppTextStyles.bodyMdMuted),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMdStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitHeader extends StatelessWidget {
  final String title;
  final DateTime date;

  const _VisitHeader({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.headerToContent.h),
      child: Row(
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: AppTextStyles.sectionLabel),
            horizontalSpace(AppSpacing.s8),
          ],
          Expanded(
            child: Text(
              AppFormat.fullDate(date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMdStrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// الفاصل بين خدمتين في نفس اليوم — بيعرض الفراغ وبيدّي قرار.
///
/// السؤال هو نص الزرار نفسه: الضغط بيطبّقه. أقصر من لابل + زرار، وأوضح
/// من أيقونة محدش هيفهمها.
class _BoundaryRow extends StatelessWidget {
  final VisitBoundary boundary;
  final ValueChanged<String> onToggle;

  const _BoundaryRow({required this.boundary, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          Icon(
            boundary.isBreak
                ? Icons.directions_walk_rounded
                : Icons.more_time_rounded,
            size: 16.r,
            color: AppSemanticColors.textTertiary,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(
            child: Text(
              'بينهم ${AppFormat.duration(boundary.gap.inMinutes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ),
          SizedBox(
            height: AppSpacing.touchTarget.h,
            child: TextButton(
              onPressed: () => onToggle(boundary.itemKey),
              child: Text(
                boundary.isBreak ? 'نفس الرحلة؟' : 'رحلتين منفصلتين؟',
                style: AppTextStyles.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  final BookingDraftItem item;
  final ValueChanged<String> onChange;

  const _ItemLine({required this.item, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final slot = item.selectedSlot!;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd,
                ),
                verticalSpace(AppSpacing.titleToSubtitle),
                Text(
                  '${AppFormat.timeRange(slot.startAt, slot.endAt)}'
                  ' · مع ${item.resolvedEmployeeName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          horizontalSpace(AppSpacing.s8),
          Text(AppFormat.money(item.price), style: AppTextStyles.bodyMdStrong),
          SizedBox(
            height: AppSpacing.touchTarget.h,
            child: TextButton(
              onPressed: () => onChange(item.key),
              child: Text('تغيير', style: AppTextStyles.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;

  const _Notice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.s12.r),
      decoration: BoxDecoration(
        color: AppSemanticColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.s.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: AppSemanticColors.warning,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(child: Text(message, style: AppTextStyles.captionInk)),
        ],
      ),
    );
  }
}

/// الملاحظات — مطوية لحد ما العميل يطلبها.
///
/// الحقل كان موجود في الـ cubit من الأول (`notesController`) ومكانش
/// معروض في أي شاشة، مع إن الـ API بيقبل `notes`. مفتوح طول الوقت
/// بياخد مساحة من غالبية مالهاش ملاحظات، فبيتفتح بالضغط.
class _NotesField extends StatelessWidget {
  final CreateBookingCubit cubit;

  const _NotesField({required this.cubit});

  @override
  Widget build(BuildContext context) {
    if (!cubit.isNotesExpanded) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: cubit.toggleNotes,
          icon: Icon(Icons.add_rounded, size: 20.r),
          label: Text('ضيف ملاحظة للمحل', style: AppTextStyles.label),
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s8.h),
      child: TextField(
        controller: cubit.notesController,
        maxLines: 3,
        minLines: 2,
        maxLength: 1000,
        style: AppTextStyles.bodyMd,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: AppSemanticColors.surfaceSunken,
          hintText: 'أي حاجة تحب المحل يعرفها؟',
          hintStyle: AppTextStyles.bodyMdMuted,
          contentPadding: EdgeInsets.all(AppSpacing.s12.r),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.m.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
