import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// صف دفعة في السجل.
///
/// ⚠ **`Wrap` مش `Row` للسطر العلوي.** المبلغ أكبر خط في الصف والحالة
/// شارة — الاتنين مايتقصّوش. عند مقياس خط ١٫٣ الـ`Row` بيفيض، والـ`Wrap`
/// بينزّل الشارة سطر تحت وشكله عند المقاس العادي زي الـ`Row` بالظبط.
class PaymentRowWidget extends StatelessWidget {
  const PaymentRowWidget({
    required this.payment,
    this.showHairline = true,
    super.key,
  });

  final PaymentUiModel payment;
  final bool showHairline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.s12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.s8.w,
                runSpacing: AppSpacing.s4.h,
                children: [
                  // ⚠ `amount` بياخد **نص منسّق** مش رقم — الـwidget مابيقرّرش
                  // العملة ولا شكل الأرقام، `AppFormat.money` هي البوابة.
                  AppAmountWidget(
                    amount: AppFormat.money(payment.amount),
                    size: AppAmountSize.card,
                  ),
                  AppPillWidget(
                    label: payment.status.label,
                    tone: switch (payment.status) {
                      PaymentStatusUi.completed => AppPillTone.positive,
                      PaymentStatusUi.failed => AppPillTone.danger,
                      PaymentStatusUi.refunded => AppPillTone.warning,
                      _ => AppPillTone.neutral,
                    },
                  ),
                ],
              ),
              verticalSpace(AppSpacing.s4),
              Text(
                '${payment.methodLabel} · '
                '${AppFormat.relativeDate(payment.createdAt)}',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (payment.transactionId.isNotEmpty) ...[
                verticalSpace(AppSpacing.s4),
                Text(
                  payment.transactionId,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (showHairline) const AppHairlineWidget(),
      ],
    );
  }
}
