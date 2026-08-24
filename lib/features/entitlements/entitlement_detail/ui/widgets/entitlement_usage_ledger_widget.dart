import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/usage_transaction_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **دفتر الوحدات** — كل حركة برصيدها قبل وبعد.
///
/// ## ليه الرصيد بيتعرض مش الحركة بس
///
/// «−٦٠ دقيقة» لوحدها بتطلب من العميلة تجمع بإيدها عشان تتأكد إن الرقم
/// الكبير فوق صح. «١٩٥ ← ١٣٥» بتخلي السطر يثبت نفسه. ودي مش رفاهية:
/// الرصيد ده فلوس اتدفعت، وأول رقم مش مفهوم بيتحوّل لمكالمة للفرع.
class EntitlementUsageLedgerWidget extends StatelessWidget {
  const EntitlementUsageLedgerWidget({required this.transactions, super.key});

  final List<UsageTransactionUiModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const AppSectionHeaderWidget(title: 'حركة الرصيد'),
        for (final transaction in transactions) _Row(transaction: transaction),
      ],
    );
  }
}

/// ⚠ **مش `const`** — بيرسم لون حسب اتجاه الحركة.
class _Row extends StatelessWidget {
  const _Row({required this.transaction});

  final UsageTransactionUiModel transaction;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.isDebit;
    final sign = isDebit ? '−' : '+';

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // **النص هو اللي بيتنازل، والرقم لأ.** الرقم مقصوص = السطر
          // مالوش لزمة.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  transaction.reason.isEmpty ? _typeLabel : transaction.reason,
                  style: AppTextStyles.bodyMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (transaction.createdAt != null)
                  Text(
                    AppFormat.fullDate(transaction.createdAt!),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$sign${AppFormat.digits(transaction.units)}',
                style: AppTextStyles.bodyMdStrong.copyWith(
                  color: isDebit
                      ? AppSemanticColors.textPrimary
                      : AppSemanticColors.accentText,
                ),
                maxLines: 1,
              ),
              Text(
                'الرصيد ${AppFormat.digits(transaction.balanceAfter)}',
                style: AppTextStyles.caption,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// لو الموظف ما كتبش سبب، بنقول نوع الحركة بدل ما نسيب السطر فاضي.
  String get _typeLabel => switch (transaction.type) {
    'purchase' => 'شرا رصيد',
    'consume' => 'استهلاك',
    'refund' => 'استرجاع',
    'expire' => 'انتهت الصلاحية',
    _ => 'حركة',
  };
}
