import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// bottom sheet — **بيستبدل تلات نسخ متطابقة**.
///
/// `logout_bottom_sheet_widget.dart` ·
/// `my_booking_item_card_widget.dart:311 _CancelVisitBottomSheet` ·
/// `booking_details_body_widget.dart:362 _CancelVisitConfirmationSheet`
/// — تلاتتهم نفس التصميم: مقبض، عنوان، رسالة، زرارين.
///
/// ## ⚠ المقبض مش مرسوم هنا
///
/// بييجي من `bottomSheetTheme.showDragHandle: true` في `appTheme()`.
/// لو الـ widget رسمه كمان، بيبقى مقبضين — وده اللي بيحصل لما حد ينسخ
/// الـ sheet من تطبيق لتطبيق.
///
/// ## ⚠ اللي بينده هو اللي بيقفل
///
/// الـ sheet **مابيناديش `Navigator.pop`** — نسخة employee-app بتنادي
/// `context.pushNamedAndRemoveUntil(Routes.loginScreen)` **من جوه
/// الـ widget**، وبتنادي `getIt<AppPinService>()` كمان. الكيت بيرجّع
/// النتيجة عن طريق [show] واللي بينده بيقرر.
class AppSheetWidget extends StatelessWidget {
  const AppSheetWidget({
    required this.title,
    required this.actions,
    this.message,
    this.icon,
    this.iconTone,
    this.content,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? message;

  final IconData? icon;
  final Color? iconTone;

  /// محتوى مخصوص بين الرسالة والأزرار.
  final Widget? content;

  /// الأزرار من فوق لتحت. الأساسي الأول.
  final List<Widget> actions;

  /// بيفتح الـ sheet وبيرجّع اللي [Navigator.pop] اترمى بيه.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<Widget> Function(BuildContext sheetContext) actions,
    String? message,
    IconData? icon,
    Color? iconTone,
    Widget? content,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (sheetContext) => AppSheetWidget(
        title: title,
        message: message,
        icon: icon,
        iconTone: iconTone,
        content: content,
        actions: actions(sheetContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.pageGutter.w,
          end: AppSpacing.pageGutter.w,
          // ⚠ **`viewInsets` مش تزويدة.** أي ورقة فيها حقل نص في [content]
          // — سبب إلغاء، تعليق تقييم — الكيبورد بيغطّيها من غير السطر ده،
          // والزراير اللي تحت الحقل بتبقى مش موصولة أصلاً. بيساوي صفر لما
          // مافيش كيبورد، فمالوش تكلفة على باقي الأوراق.
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.s24.h,
          top: AppSpacing.s8.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 40.r,
                color: iconTone ?? AppSemanticColors.accentText,
              ),
              SizedBox(height: AppSpacing.s12.h),
            ],
            Text(
              title,
              style: AppTextStyles.titleLg,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.s8.h),
              Text(
                message!,
                style: AppTextStyles.bodyMdMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[
              SizedBox(height: AppSpacing.s16.h),
              content!,
            ],
            SizedBox(height: AppSpacing.s24.h),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.s8.h),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}
