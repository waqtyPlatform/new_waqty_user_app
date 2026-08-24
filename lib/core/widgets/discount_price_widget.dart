import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **السعر القديم المشطوب** — «كان ٢٥٠ · بقى ٢٠٠».
///
/// ## ليه widget بدل توكن خط
///
/// ده كان `AppTextStyles.captionStruck` قبل تبنّي الكيت. الكيت شايله لأن
/// **الخصم مفهوم دومين مش دور في سلّم الخط** — نفس السبب اللي خلّى ربط
/// `BookingStatus` بالنغمة ملك التطبيق (README الكيت §٦).
///
/// وهو widget مش `copyWith` متكرر في المكانين اللي بيستعملوه، لنفس السبب
/// اللي الكومنت الأصلي كتبه: لو كل واحد كتبه لنفسه، أول تغيير هيمشي في
/// مكان ويسيب التاني. المكانين: تفاصيل الحجز وصف القايمة.
///
/// ## ليه أحمر
///
/// **قرار مالك.** الأحمر محجوز للخطر، والخصم بيشارك اللون ده — تنازل
/// مقصود: أحمر الأوفر عُرف راسخ في السوق المصري (جوميا ونون وأي فاترينة)،
/// والشطب مع الأحمر بيقرا «أوفر» فورًا من غير لابل.
///
/// التباين على الكارت **5.15:1** — فوق حد النص الصغير.
class DiscountPriceWidget extends StatelessWidget {
  const DiscountPriceWidget({required this.amount, super.key});

  /// السعر **قبل** الخصم.
  final num amount;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppFormat.money(amount),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.caption.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: AppSemanticColors.danger,
        color: AppSemanticColors.danger,
      ),
    );
  }
}
