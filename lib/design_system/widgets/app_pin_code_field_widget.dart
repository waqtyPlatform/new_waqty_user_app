import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// حقل PIN / OTP.
///
/// ## ⚠ الـ LTR القسري — دي الحتة اللي لازم تتنقل زي ما هي
///
/// employee-app بيلفّ الحقل في
/// `Directionality(textDirection: ui.TextDirection.ltr)`
/// (`app_pin_code_field_widget.dart:93`). ده **صح ومش بديهي**: الرقم
/// السري بيتكتب من الشمال لليمين حتى في الواجهة العربية، لأن العميل
/// بيقرا الأرقام بالترتيب اللي بيدخّله. من غيره أول رقم بيظهر في آخر
/// خانة.
///
/// ⚠ **الخانات ٤×٦٤ بتزيد عن عرض ٣٦٠.** الحساب: ٤ × ٦٤ + ٣ × ١٢ فراغ =
/// ٢٩٢، زائد هامشين ١٦ = ٣٢٤. عدّت على ٣٦٠، بس عند ٦ خانات لازم المقاس
/// ينزل — عشان كده [boxSize] موجود.
class AppPinCodeFieldWidget extends StatelessWidget {
  const AppPinCodeFieldWidget({
    required this.length,
    this.controller,
    this.focusNode,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autofocus = false,
    this.hasError = false,
    this.boxSize,
    super.key,
  });

  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool autofocus;
  final bool hasError;

  /// `null` = بيتحسب من الطول عشان يعدّي على ٣٦٠.
  final double? boxSize;

  @override
  Widget build(BuildContext context) {
    final size = boxSize ?? (length <= 4 ? 64.0 : 48.0);

    final base = PinTheme(
      width: size.r,
      height: size.r,
      textStyle: AppTextStyles.titleXl,
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceRaised,
        borderRadius: AppRadius.rM,
        border: Border.all(
          color: hasError ? AppSemanticColors.danger : AppSemanticColors.border,
        ),
      ),
    );

    return Directionality(
      // ⚠ متقلبش دي. اقرا الشرح فوق.
      textDirection: ui.TextDirection.ltr,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscure,
        onCompleted: onCompleted,
        onChanged: onChanged,
        defaultPinTheme: base,
        separatorBuilder: (_) => SizedBox(width: AppSpacing.s12.w),
        focusedPinTheme: base.copyDecorationWith(
          border: Border.all(color: AppSemanticColors.accent, width: 1.5),
        ),
        submittedPinTheme: base.copyDecorationWith(
          color: AppSemanticColors.surfaceAccentSoft,
          border: Border.all(color: AppSemanticColors.accentText),
        ),
        errorPinTheme: base.copyDecorationWith(
          color: AppSemanticColors.dangerSoft,
          border: Border.all(color: AppSemanticColors.danger, width: 1.5),
        ),
        cursor: Container(
          width: 2.w,
          height: 22.h,
          color: AppSemanticColors.accent,
        ),
      ),
    );
  }
}
