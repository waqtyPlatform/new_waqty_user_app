import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// ورقة «الميعاد ده مش مناسب» — **النوتة مطلوبة**.
///
/// ⚠ السيرفر بيرفض `request-change` من غير `note` (٤٢٢). فالزرار مقفول لحد
/// ما العميل يكتب — أحسن من إنه يدوس ويستنى ويشوف خطأ.
///
/// والنوتة مش شكليات: الفرع بيقرا منها إيه اللي مش مناسب بالظبط عشان
/// المحاولة الجاية تبقى أقرب. تلات محاولات وبس، فالمحاولة اللي بتضيع من
/// غير معلومة غالية.
class ReassignmentChangeRequestSheet {
  const ReassignmentChangeRequestSheet._();

  /// بترجّع النوتة، أو `null` لو العميل قفل الورقة.
  ///
  /// [controller] بييجي من الـcubit عشان النص يعيش لو الورقة اتقفلت
  /// بالغلط — نفس نمط `cancelReasonController` في تفاصيل الحجز.
  static Future<String?> show(
    BuildContext context, {
    required TextEditingController controller,
  }) async {
    final confirmed = await AppSheetWidget.show<bool>(
      context,
      title: 'الميعاد ده مش مناسب',
      message:
          'قول للفرع إيه اللي مش مناسب عشان يقربلك في المحاولة الجاية.',
      // الحشوة والحدود والخلفية كلهم من `inputDecorationTheme`.
      content: TextField(
        controller: controller,
        maxLines: 3,
        // حد السيرفر على `note` — بنقفله هنا بدل ما نستنى ٤٢٢.
        maxLength: 500,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'مثلاً: الساعة ٨ متأخرة عليّا',
        ),
      ),
      actions: (sheetContext) => [
        // ⚠ **الزرار بيتقفل والحقل فاضي.** `ValueListenableBuilder` على
        // الـcontroller هو المصدر الطبيعي — القاعدة في المشروع Cubit-only،
        // والحالة دي محلية بالكامل (نص جوه ورقة) فمالهاش لزمة في cubit.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => AppButtonWidget(
            label: 'ابعت للفرع',
            onPressed: value.text.trim().isEmpty
                ? null
                : () => Navigator.of(sheetContext).pop(true),
          ),
        ),
        AppButtonWidget(
          label: 'رجوع',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    );

    if (confirmed != true) return null;

    final note = controller.text.trim();
    return note.isEmpty ? null : note;
  }
}
