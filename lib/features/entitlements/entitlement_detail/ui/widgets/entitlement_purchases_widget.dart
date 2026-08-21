import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **الشراءات اللي البركة اتجمّعت منها** — كل واحد بانتهاء لوحده.
///
/// ## المشكلة اللي بيحلها
///
/// السيرفر بيلمّ الشراءات في رقم واحد («فاضل ١٨ جلسة»). الرقم ده مريح بس
/// **بيخفي إن جزء منه بيموت قبل الباقي**: ١٠ بتنتهي الشهر الجاي و٨ بعد ٦
/// شهور. العميلة اللي شايفة ١٨ بتخطّط على ١٨.
///
/// الأكورديون بيخلّي التفصيل متاح للي بيسأل من غير ما يزحم الشاشة للي
/// مش بيسأل.
class EntitlementPurchasesWidget extends StatelessWidget {
  const EntitlementPurchasesWidget({required this.purchases, super.key});

  final List<UsagePurchaseUiModel> purchases;

  @override
  Widget build(BuildContext context) {
    if (purchases.length < 2) return const SizedBox.shrink();

    return AppAccordionWidget(
      title: 'الرصيد ده من ${AppFormat.digits(purchases.length)} شراءات',
      subtitle: 'كل شرا ليه تاريخ انتهاء لوحده',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final purchase in purchases) _PurchaseRow(purchase: purchase),
        ],
      ),
    );
  }
}

/// ⚠ **مش `const`** — بيرسم لون حسب حالة الشرا.
class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.purchase});

  final UsagePurchaseUiModel purchase;

  @override
  Widget build(BuildContext context) {
    final isSpent = purchase.remainingUnits <= 0;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'فاضل ${AppFormat.digits(purchase.remainingUnits)} '
                  'من ${AppFormat.digits(purchase.unitsPurchased)}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isSpent
                        ? AppSemanticColors.textSecondary
                        : AppSemanticColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (purchase.expiresAt != null)
                  Text(
                    'ينتهي ${AppFormat.fullDate(purchase.expiresAt!)}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (purchase.price > 0) ...<Widget>[
            SizedBox(width: AppSpacing.s8.w),
            Text(
              AppFormat.money(purchase.price),
              style: AppTextStyles.caption,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}
