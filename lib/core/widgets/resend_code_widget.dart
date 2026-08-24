import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// «ابعت الكود تاني» — زرار وقت ما ينفع، وعدّاد وقت ما ماينفعش.
///
/// ## ليه واحد بدل اتنين
///
/// `resend_code_widget.dart` و`register_resend_code_widget.dart` كانوا
/// **متطابقين سطر بسطر** ما عدا حاجتين: نوع الـ cubit ومفاتيح الترجمة.
/// نسختين من نفس المنطق يعني أي تصليح بيتعمل مرة وينسى مرة.
///
/// ## ليه بياخد قيم مش cubit
///
/// الـ cubitين نوعين مختلفين، فـ`BlocBuilder<T>` واحد مايقدرش يخدمهم.
/// الـ widget ده **عرض صافي** — بياخد الحالة جاهزة، واللي بينده هو اللي
/// بيلفّه في الـ`BlocBuilder` بتاعه. نفس مبدأ الكيت: النصوص بتوصل
/// متـرجمة، مش مفاتيح.
class ResendCodeWidget extends StatelessWidget {
  const ResendCodeWidget({
    required this.canResend,
    required this.timerText,
    required this.onResend,
    required this.resendLabel,
    required this.countdownPrefix,
    required this.countdownSuffix,
    super.key,
  });

  final bool canResend;

  /// العدّاد متنسّق جاهز.
  final String timerText;

  final VoidCallback onResend;

  /// «ابعت الكود تاني».
  final String resendLabel;

  /// «تقدر تبعت تاني بعد» · «ثانية» — الجملة متقسّمة عشان الرقم يقعد
  /// في النص بلون اللمسة.
  final String countdownPrefix;
  final String countdownSuffix;

  @override
  Widget build(BuildContext context) {
    // زرار حقيقي وقت ما ينفع الإرسال، ونص وقت العد. كان `GestureDetector`
    // — مالوش هدف لمس ولا ripple ولا دور لقارئ الشاشة.
    if (canResend) {
      return Center(
        child: TextButton(onPressed: onResend, child: Text(resendLabel)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(countdownPrefix, style: AppTextStyles.bodyMdMuted),
        Text(timerText, style: AppTextStyles.label),
        Text(countdownSuffix, style: AppTextStyles.bodyMdMuted),
      ],
    );
  }
}
