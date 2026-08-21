import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// إجراءات الحجز.
///
/// **زرار الإلغاء بيتخفي، مش بيتعطّل**، لما الإلغاء مش مسموح.
/// زرار بيضمن إنه هيفشل أوحش من إنه مايبقاش موجود أصلاً — وبدل الزرار
/// بنقول للعميل السبب.
///
/// وبنقرا `canCancel` الجاي من السيرفر — مابنحسبش القاعدة في الموبايل،
/// عشان لو السيرفر غيّرها منبقاش بنكدب على العميل.
class BookingDetailsActionsWidget extends StatelessWidget {
  final BookingUiModel booking;
  final VoidCallback onCancel;
  final VoidCallback onRate;
  final VoidCallback onRebook;

  const BookingDetailsActionsWidget({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.onRate,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // **الزرار بيفضل موجود لحد ما كل الخدمات تتقيّم.**
        //
        // كان `booking.myRating == 0` — رقم واحد للحجز كله، يعني في حجز
        // بتلات خدمات أول تقييم كان بيخفي الزرار والاتنين التانيين
        // مايتقيّموش أبدًا. التقييمات مربوطة بـ `booking_item_id` في
        // السيرفر، فالحجز ده تلات تقييمات مستقلة.
        if (booking.hasPendingRatings)
          AppButtonWidget(
            label: booking.rateableItems.length == 1
                ? 'قيّم الخدمة'
                : 'قيّم الخدمات',
            onPressed: onRate,
          ),

        if (!booking.status.isUpcoming) ...[
          verticalSpace(AppSpacing.listRowGap),
          AppButtonWidget(
            label: 'احجز تاني',
            variant: AppButtonVariant.secondary,
            onPressed: onRebook,
          ),
        ],

        if (booking.status.isUpcoming) ...[
          verticalSpace(AppSpacing.listRowGap),
          if (booking.canCancel)
            AppButtonWidget(
              label: 'إلغاء الحجز',
              variant: AppButtonVariant.danger,
              onPressed: onCancel,
            )
          else
            // مفيش زرار — بس العميل لازم يعرف ليه.
            AppSurfaceWidget(
              level: AppElevation.sunken,
              radius: AppRadius.m,
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.cardPadding.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.r,
                    color: AppSemanticColors.textSecondary,
                  ),
                  horizontalSpace(AppSpacing.s8),
                  // **القاعدة الحقيقية إن الميعاد بدأ، مش إنه النهاردة.**
                  //
                  // `Booking::getCanCancelAttribute()` بيرجّع false لما
                  // الميعاد **يعدّي**، مش عشان هو في نفس اليوم. حجز
                  // النهاردة ٦م وإنت بتبصّ ٢ظ `can_cancel: true` — فالنص
                  // القديم كان بيمنع العميل من حاجة مسموحة له، ويبعته
                  // يكلّم الفرع في مشكلة مش موجودة.
                  //
                  // ولو المزوّد كاتب `cancellation_policy` بنفسه، **كلامه
                  // هو اللي يتعرض** — هو صاحب القاعدة، وإحنا بنقولها
                  // بالنيابة عنه بس لما هو ما يكتبهاش.
                  // TODO(api): BE-B1 — `policies` على payload الفرع.
                  Expanded(
                    child: Text(
                      booking.policies.cancellationPolicy.isNotEmpty
                          ? booking.policies.cancellationPolicy
                          : 'الميعاد ده بدأ خلاص — كلّم الفرع لو محتاج تعدّل أو تلغي',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
