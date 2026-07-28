import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';

/// شاشة التأكيد.
///
/// كل سطر جنبه «تغيير» بترجع **للكنترول ده بالذات** مش لأول الفلو —
/// العميل عايز يغيّر الساعة، مش يعيد الحجز من الأول.
class CreateBookingSummaryWidget extends StatelessWidget {
  final CreateBookingCubit cubit;

  const CreateBookingSummaryWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final slot = cubit.selectedSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(label: 'المكان', value: cubit.providerName, onChange: null),
        if (cubit.selectedBranch != null)
          _row(
            label: 'الفرع',
            value: cubit.selectedBranch!.name,
            onChange: cubit.branches.length > 1
                ? () => cubit.goToStep(BookingStep.service)
                : null,
          ),
        _row(
          label: 'الخدمة',
          value: cubit.selectedService?.name ?? '',
          onChange: () => cubit.goToStep(BookingStep.service),
        ),
        _row(
          label: 'الأخصائي',
          value: slot != null && cubit.selectedEmployee.isAnyAvailable
              ? slot.employeeName
              : cubit.selectedEmployee.name,
          onChange: () => cubit.goToStep(BookingStep.dateTime),
        ),
        if (slot != null) ...[
          _row(
            label: 'التاريخ',
            value: AppFormat.fullDate(slot.startAt),
            onChange: () => cubit.goToStep(BookingStep.dateTime),
          ),
          _row(
            label: 'الوقت',
            value: AppFormat.timeRange(slot.startAt, slot.endAt),
            onChange: () => cubit.goToStep(BookingStep.dateTime),
          ),
        ],

        verticalSpace(8),
        Divider(color: AppSemanticColors.border, height: 1.h),
        verticalSpace(12),

        Row(
          children: [
            Text('الإجمالي', style: AppTextStyles.bodyMdMuted),
            const Spacer(),
            // أكبر خط في الشاشة — ده الرقم اللي العميل بيوافق عليه.
            Text(
              AppFormat.money(slot?.price ?? cubit.selectedService?.price ?? 0),
              style: AppTextStyles.titleLg,
            ),
          ],
        ),
        verticalSpace(4),
        Text('الدفع في الفرع', style: AppTextStyles.caption),

        // أهم سطر في الشاشة كلها.
        //
        // السيرفر فعلاً بيمنع إلغاء حجز النهاردة. العميل اللي يكتشف إنه
        // ارتبط بحاجة مش قادر يلغيها **بعد** ما يأكد — دي أوحش خسارة ثقة
        // ممكنة في المنتج ده، وثمنها سطر واحد في المكان الصح.
        if (cubit.isSameDayBooking) ...[
          verticalSpace(14),
          Container(
            padding: EdgeInsetsDirectional.all(12.r),
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
                horizontalSpace(8),
                Expanded(
                  child: Text(
                    'حجز النهاردة مش هينفع يتلغي بعد التأكيد',
                    style: AppTextStyles.captionInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _row({
    required String label,
    required String value,
    VoidCallback? onChange,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 6.h),
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
          if (onChange != null)
            SizedBox(
              height: 44.h,
              child: TextButton(
                onPressed: onChange,
                child: Text(
                  'تغيير',
                  style: AppTextStyles.label,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
