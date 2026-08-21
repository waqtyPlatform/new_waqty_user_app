import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **«متابعتك مجانية لحد ١٢ سبتمبر»** — في تفاصيل الحجز اللي ولّدها.
///
/// ## ليه في تفاصيل الحجز بالذات
///
/// المتابعة بتتولد لوحدها لما الخدمة تخلص — **العميلة ما طلبتهاش ومش
/// عارفة إنها بقت ليها**. وأقرب لحظة هتفكّر فيها في الخدمة دي تاني هي
/// وهي بتبص على الحجز اللي خلص.
///
/// لو استنينا لحد ما تفتح «باقاتي»، هي لازم تدوّر على حاجة مش متأكدة
/// إنها موجودة — وده مابيحصلش. عشان كده ده تالت مدخل للمتابعات، مش
/// تكرار.
///
/// ⚠ **بيقول تاريخ الصلاحية دايمًا.** متابعة مجانية من غير تاريخ بتقرا
/// عرض مفتوح، وهي بتنتهي فعلاً — والعميلة اللي تكتشف ده بعد ما تنتهي
/// بتحس إنها اتخدعت.
class FollowUpTeaserWidget extends StatelessWidget {
  const FollowUpTeaserWidget({required this.followUp, this.onTap, super.key});

  final FollowUpEntitlementUiModel followUp;
  final VoidCallback? onTap;

  /// السطر — السعر والصلاحية، لأن دول السؤالين.
  String get message {
    final until = followUp.validUntil;
    final price = followUp.isFree
        ? 'متابعتك مجانية'
        : 'متابعتك بخصم · ${AppFormat.money(followUp.effectivePrice)}';

    if (until == null) return price;
    return '$price لحد ${AppFormat.fullDate(until)}';
  }

  @override
  Widget build(BuildContext context) {
    // الأخصائي مشي والقاعدة بتقول لازم هو — الحجز مقفول (BE-A5)، فالسطر
    // بيقول الحقيقة بدل ما يوعد بحاجة هتفشل.
    if (followUp.isOrphaned) {
      return AppBannerWidget(
        title: 'ليكي متابعة',
        message:
            'الأخصائي بتاع المتابعة مابقاش متاح — كلّم الفرع عشان يظبطلك ميعاد',
        tone: AppPillTone.warning,
        icon: Icons.event_repeat_rounded,
      );
    }

    return AppBannerWidget(
      title: 'ليكي متابعة',
      message: message,
      tone: AppPillTone.positive,
      icon: Icons.event_repeat_rounded,
      actionLabel: onTap == null ? null : 'احجز المتابعة',
      onAction: onTap,
    );
  }
}
