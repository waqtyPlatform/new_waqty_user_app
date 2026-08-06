import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// حقل كود التفعيل.
///
/// ## ليه اتنقل للـ core
///
/// كان **ملفين متطابقين حرف بحرف** — واحد في `forget_verify_code` وواحد في
/// `register_verify_code`، ٧٠ سطر لكل واحد، والفرق بينهم اسم الـ cubit بس.
/// نفس التلات `PinTheme` مكتوبين ست مرات بأرقام مكتوبة بالإيد
/// (`70.w` · `50.h` · `1.3` · `10.r`).
///
/// أول ما استدارة الحقول اتغيّرت من ٢٠ لـ ١٢، الملفين دول كانوا هيفضلوا ١٠
/// لو محدش فتحهم.
///
/// ## المقاسات
///
/// الخانة **٦٤×٥٦** بدل ٧٠×٥٠: العرض نزل عشان الأربع خانات بهامش صفحة ٢٤
/// يفضلوا داخلين على شاشة ٣٦٠ (٤×٦٤ + ٣×١٢ فاصل = ٢٩٢ < ٣١٢)، والارتفاع
/// طلع عشان الرقم في `bodyLg` مايتخنقش.
class AppPinFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final int length;

  const AppPinFieldWidget({
    super.key,
    required this.controller,
    this.onCompleted,
    this.length = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: length,
      controller: controller,
      showCursor: true,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      defaultPinTheme: _theme(AppSemanticColors.border),
      submittedPinTheme: _theme(AppSemanticColors.borderStrong),
      focusedPinTheme: _theme(
        AppSemanticColors.accent,
        fill: AppSemanticColors.accentSoft,
        width: 1.5,
      ),
      errorPinTheme: _theme(AppSemanticColors.danger, width: 1.5),
      onCompleted: onCompleted,
    );
  }

  PinTheme _theme(Color border, {Color? fill, double width = 1}) => PinTheme(
    width: 64.w,
    height: 56.h,
    textStyle: AppTextStyles.bodyLg,
    decoration: BoxDecoration(
      color: fill ?? AppSemanticColors.surfaceRaised,
      border: Border.all(color: border, width: width.r),
      borderRadius: AppRadius.rS,
    ),
  );
}
