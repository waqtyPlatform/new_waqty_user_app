import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// إشعار نهاية مش مكتملة — **بيتقفل، مش أرشيف**.
///
/// ## ليه ده مش صف في القايمة
///
/// «السابقة» كانت بتجمّع المكتمل والملغي واللي ما حضرش. التلاتة نهايات
/// مختلفة عاطفيًا وكل واحدة وراها نية تانية:
///
///  • **مكتمل** → «اعملها تاني» — ودي اللي بتدر إيراد.
///  • **ملغي** → «إيه اللي حصل؟» وبعدين خلاص.
///  • **ما حضرش** → غالبًا إحراج، وأحيانًا خلاف.
///
/// خلطهم بيخفف التبويب اللي المفروض يكرر الحجز. ومحدش عايز أرشيف دايم
/// لإلغاءاته — فالإشعار بيقول اللي حصل، وبيسيب مخرج، وبيمشي لما يتقفل.
class MyBookingsNoticeWidget extends StatelessWidget {
  final BookingUiModel booking;
  final VoidCallback onDismiss;
  final VoidCallback onRebook;

  const MyBookingsNoticeWidget({
    super.key,
    required this.booking,
    required this.onDismiss,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      level: AppElevation.sunken,
      radius: AppRadius.m,
      padding: EdgeInsets.all(AppSpacing.cardPadding.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                booking.status == BookingStatus.noShow
                    ? Icons.event_busy_outlined
                    : Icons.cancel_outlined,
                size: 18.r,
                color: AppSemanticColors.textSecondary,
              ),
              horizontalSpace(AppSpacing.s8),
              Expanded(
                child: Text(
                  '${booking.status.label} · ${booking.serviceName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
              ),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(AppRadius.pill.r),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s4.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.r,
                    color: AppSemanticColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${booking.providerName} · '
            '${AppFormat.relativeDate(booking.startAt)}',
            style: AppTextStyles.caption,
          ),

          // **السبب بيتعرض.**
          //
          // `cancellation_reason` مكشوف في `UserBookingResource` من
          // الأول — الأبلكيشن كان بيطلبه من العميل وبيرميه، وكان
          // بيتجاهله لما ييجي من الفرع كمان.
          if (booking.cancellationReason.isNotEmpty) ...[
            verticalSpace(AppSpacing.titleToSubtitle),
            Text(
              'السبب: ${booking.cancellationReason}',
              style: AppTextStyles.caption,
            ),
          ],

          verticalSpace(AppSpacing.s8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onRebook,
              style: TextButton.styleFrom(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.s8.w,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('احجز تاني', style: AppTextStyles.label),
            ),
          ),
        ],
      ),
    );
  }
}
