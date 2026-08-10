import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// شيت التقييم — نجوم + تعليق اختياري.
///
/// **بيقيّم خدمة واحدة بعينها، والاسم في العنوان.** التقييمات مربوطة بـ
/// `booking_item_id` في السيرفر، فحجز بتلات خدمات = تلات تقييمات. من غير
/// الاسم، العميل اللي بيقيّم تانية خدمة مش عارف هو بيقيّم إيه.
///
/// ## ليه [AppSheetWidget] كـwidget مش `.show()`
///
/// الورقة دي **بتتغيّر وهي مفتوحة**: النجوم بتتملي، وزرار الإرسال بيتفعّل
/// أول نجمة، وبيقلب لحالة تحميل عند البعت. `AppSheetWidget.show()` بيبني
/// الأزرار **مرة واحدة**، فالورقة اللي بتتفاعل لازم تتلف في `BlocBuilder`
/// من بره — واللي بيحصل هنا: الشاشة بتفتح `showModalBottomSheet` وبتحط
/// الـ`BlocBuilder` فوق الـwidget ده.
///
/// ## اللي اتشال
///
/// خمس نجوم مكتوبين بالإيد (`List.generate` + `IconButton` جوه `SizedBox`
/// ٤٨) بقوا [AppRatingWidget] — وهو بيدّي **نص نجمة** كمان، يعني نفس
/// الـwidget بيعرض تقييم جاي من السيرفر (٤٫٥) مش بس بياخد إدخال.
///
/// وخمس أرقام خام (`16.w` · `16.h` · `4` · `12` · `8`) وحشوة الكيبورد
/// المحسوبة بالإيد — كلهم بقوا شغل [AppSheetWidget].
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
    return AppSheetWidget(
      title: 'قيّم «$serviceName»',
      message: 'رأيك بيساعد ناس تانية تختار',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ٣٢ عشان كل نجمة تفضل هدف لمس مريح — دي أهم ضغطة في الورقة.
          Center(
            child: AppRatingWidget(
              value: rating.toDouble(),
              size: 32,
              onChanged: onRatingChanged,
            ),
          ),
          verticalSpace(AppSpacing.s12),
          TextField(
            controller: commentController,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(hintText: 'اكتب رأيك (اختياري)'),
          ),
        ],
      ),
      actions: [
        AppButtonWidget(
          label: 'إرسال التقييم',
          isLoading: isLoading,
          // `null` = معطّل. مفيش تقييم من غير نجوم.
          onPressed: rating > 0 ? onSubmit : null,
        ),
      ],
    );
  }
}
