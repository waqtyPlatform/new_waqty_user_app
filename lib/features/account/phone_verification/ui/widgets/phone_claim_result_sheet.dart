import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/phone_verification/ui/widgets/phone_claim_result_band_widget.dart';

/// **ورقة النتيجة بعد تأكيد الرقم.**
///
/// ## ليه ورقة مش snackbar
///
/// دي **لحظة العائد** بتاعت الفيتشر كله: العميلة أكّدت رقمها، والسيرفر
/// ربط سجلات الفرع بحسابها. snackbar بيروح في أربع ثواني وممكن تفوتها
/// وهي بتبص على الشاشة بتحمّل — والرسالة دي هي اللي بتفسّر ليه الشاشة
/// اللي كانت فاضية بقى فيها حاجة.
///
/// ونفس نمط `BookingDetailsScreen._afterCancel` الموجود أصلاً: فعل مهم
/// خلص ← ورقة بتقول النتيجة وبتعرض الخطوة الجاية.
class PhoneClaimResultSheet {
  const PhoneClaimResultSheet._();

  /// [packagesFound] بييجي من **إعادة تحميل** الـentitlements بعد النجاح.
  ///
  /// السيرفر بيرجّع `linked` (عدد سجلات العملاء) مش عدد الباقات، فالرقم
  /// ده مش موجود في رد التأكيد — بييجي من النداء اللي بعده.
  static Future<void> show(
    BuildContext context, {
    required PhoneClaimResultUiModel result,
    int? packagesFound,
    VoidCallback? onOpenEntitlements,
  }) {
    final found = result.relinkedBookings > 0 || (packagesFound ?? 0) > 0;

    return AppSheetWidget.show<void>(
      context,
      icon: Icons.check_circle_outline_rounded,
      iconTone: AppSemanticColors.positive,
      title: 'رقمك اتأكّد',
      content: PhoneClaimResultBandWidget(
        result: result,
        packagesFound: packagesFound,
      ),
      actions: (sheetContext) => <Widget>[
        // زرار «شوف باقاتك» بيظهر **لما فيه حاجة تتشاف بس**.
        if (found && onOpenEntitlements != null)
          AppButtonWidget(
            label: 'شوف باقاتك',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              onOpenEntitlements();
            },
          ),
        AppButtonWidget(
          label: 'تمام',
          variant: found && onOpenEntitlements != null
              ? AppButtonVariant.ghost
              : AppButtonVariant.primary,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
  }
}
