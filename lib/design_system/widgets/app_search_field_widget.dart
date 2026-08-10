import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import 'app_text_field.dart';

/// حقل بحث.
///
/// ⚠ **الاستدارة اتصلّحت من ٩ لـ [AppRadius.l] (٢٠).** نسخة employee-app
/// (`search_widget.dart`) بتستخدم `9.r` بينما الحقل اللي بيقعد جنبه في
/// نفس الفورم بيستخدم `20.r` — نفس الدور بشكلين، وده كان بيقرا كأنهم
/// كنترولين من نظامين مختلفين.
///
/// السطح **مرفوع مش غاطس**: الغاطس لغة الكروم اللي بيترجع لورا، والبحث
/// حاجة بتتداس.
class AppSearchFieldWidget extends StatelessWidget {
  const AppSearchFieldWidget({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String hintText;

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// لما تتحط، بيظهر زرار مسح لما يبقى فيه نص.
  final VoidCallback? onClear;

  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;

    return AppTextFormField(
      hintText: hintText,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s12.w,
          end: AppSpacing.s8.w,
        ),
        child: Icon(
          Icons.search_rounded,
          size: 20.r,
          color: AppSemanticColors.textSecondary,
        ),
      ),
      suffixIcon: onClear != null && hasText
          ? GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: AppSpacing.touchTarget.r,
                height: AppSpacing.touchTarget.r,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.r,
                  color: AppSemanticColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }
}
