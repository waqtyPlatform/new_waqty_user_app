import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';

/// شيت التقييم — نجوم + تعليق اختياري.
///
/// **بيقيّم خدمة واحدة بعينها، والاسم في العنوان.** التقييمات مربوطة بـ
/// `booking_item_id` في السيرفر، فحجز بتلات خدمات = تلات تقييمات. من غير
/// الاسم، العميل اللي بيقيّم تانية خدمة مش عارف هو بيقيّم إيه.
class BookingRateSheetWidget extends StatelessWidget {
  final String serviceName;
  final int rating;
  final TextEditingController commentController;
  final bool isLoading;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const BookingRateSheetWidget({
    super.key,
    required this.serviceName,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16.w,
        end: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('قيّم «$serviceName»', style: AppTextStyles.cardTitle),
          verticalSpace(4),
          Text(
            'رأيك بيساعد ناس تانية تختار',
            style: AppTextStyles.caption,
          ),
          verticalSpace(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final star = index + 1;
              return SizedBox(
                height: 48.r,
                width: 48.r,
                child: IconButton(
                  onPressed: () => onRatingChanged(star),
                  icon: Icon(
                    star <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 32.r,
                    color: star <= rating
                        ? AppSemanticColors.rating
                        : AppSemanticColors.borderStrong,
                  ),
                ),
              );
            }),
          ),
          verticalSpace(12),
          TextField(
            controller: commentController,
            maxLines: 3,
            maxLength: 500,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'اكتب رأيك (اختياري)',
              hintStyle: AppTextStyles.bodyMdMuted,
              filled: true,
              fillColor: AppSemanticColors.surfaceSunken,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.s.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          verticalSpace(8),
          AppButtonWidget(
            label: 'إرسال التقييم',
            isLoading: isLoading,
            // `null` = معطّل. مفيش تقييم من غير نجوم.
            onPressed: rating > 0 ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}
