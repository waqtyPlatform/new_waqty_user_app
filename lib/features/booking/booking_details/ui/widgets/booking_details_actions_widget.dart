import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';

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
        if (booking.status.canRate && booking.myRating == 0)
          ButtonWidget(
            isLoading: false,
            buttonText: 'قيّم الخدمة',
            backGroundColor: AppSemanticColors.accent,
            borderColor: AppSemanticColors.accent,
            textStyle: AppTextStyles.button,
            buttonHeight: 52.h,
            onPressed: onRate,
          ),

        if (!booking.status.isUpcoming) ...[
          verticalSpace(AppSpacing.listRowGap),
          ButtonWidget(
            isLoading: false,
            buttonText: 'احجز تاني',
            backGroundColor: AppSemanticColors.surfaceRaised,
            borderColor: AppSemanticColors.accent,
            borderWidth: 1,
            textStyle: AppTextStyles.cardTitle,
            buttonHeight: 52.h,
            onPressed: onRebook,
          ),
        ],

        if (booking.status.isUpcoming) ...[
          verticalSpace(AppSpacing.listRowGap),
          if (booking.canCancel)
            ButtonWidget(
              isLoading: false,
              buttonText: 'إلغاء الحجز',
              backGroundColor: AppSemanticColors.surfaceRaised,
              borderColor: AppSemanticColors.dangerBorder,
              borderWidth: 1,
              textStyle: AppTextStyles.cardTitle.copyWith(
                color: AppSemanticColors.danger,
              ),
              buttonHeight: 52.h,
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
