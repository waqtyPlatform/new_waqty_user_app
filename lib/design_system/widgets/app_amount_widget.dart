import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// حجم الرقم في [AppAmountWidget].
enum AppAmountSize {
  /// جوه صف — `bodyMdStrong`.
  inline,

  /// عنوان كارت — 24.
  card,

  /// بطل الشاشة — 32.
  hero,
}

/// عرض مبلغ.
///
/// ## ليه widget مخصوص لرقم
///
/// الرقم الكبير مالوش «دور» في سلّم الخط — مقاسه بيتحدد بالمساحة مش
/// بالهيراركي، عشان كده [AppTextStyles.numeric] **دالة مش توكن**. والـ
/// widget ده بيلفّها بتلات قرارات بتتكرر في كل شاشة فلوس:
///
/// 1. **الرقم والعملة مش بنفس المقاس.** العملة بتتكتب أصغر وأخف، وإلا
///    بتاخد من انتباه الرقم.
/// 2. **الرقم `Flexible`.** مبلغ طويل جنب لابل بيفيض الصف من غير كده.
/// 3. **الاتجاه.** الرقم بيتكتب LTR جوه نص RTL، والعملة بعده في اتجاه
///    القراءة.
///
/// ⚠ **الكيت مابيعرفش العملة.** [amount] نص جاهز، و[currency] نص جاهز —
/// اللي بينده بيمرّرهم من `AppFormat` بتاعه.
class AppAmountWidget extends StatelessWidget {
  const AppAmountWidget({
    required this.amount,
    this.currency,
    this.size = AppAmountSize.card,
    this.color,
    this.prefix,
    this.strikethrough = false,
    super.key,
  });

  /// الرقم **متنسّق جاهز** — مش `num`.
  final String amount;

  /// «ج.م» مثلًا. `null` = من غير عملة.
  final String? currency;

  final AppAmountSize size;
  final Color? color;

  /// «+» أو «−» للحركات المالية.
  final String? prefix;

  final bool strikethrough;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppSemanticColors.textPrimary;

    final numberStyle =
        switch (size) {
          AppAmountSize.inline => AppTextStyles.bodyMdStrong.copyWith(
            color: ink,
          ),
          AppAmountSize.card => AppTextStyles.numeric(24, color: ink),
          AppAmountSize.hero => AppTextStyles.numeric(32, color: ink),
        }.copyWith(
          decoration: strikethrough ? TextDecoration.lineThrough : null,
          decorationColor: ink,
        );

    final currencyStyle = switch (size) {
      AppAmountSize.inline => AppTextStyles.caption,
      _ => AppTextStyles.bodyMd,
    }.copyWith(color: ink.withValues(alpha: .75));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (prefix != null) Text(prefix!, style: numberStyle, maxLines: 1),
        // ⚠ `Flexible`: المبلغ هو اللي بيتضغط، مش العملة.
        Flexible(
          child: Text(
            amount,
            style: numberStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (currency != null) ...[
          SizedBox(width: AppSpacing.s4.w),
          Text(currency!, style: currencyStyle, maxLines: 1),
        ],
      ],
    );
  }
}
