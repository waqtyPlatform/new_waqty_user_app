import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';

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
                  Expanded(
                    child: Text(
                      'حجز النهاردة مش هينفع يتلغي من الأبلكيشن — كلّم الفرع لو محتاج تعدّل',
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
