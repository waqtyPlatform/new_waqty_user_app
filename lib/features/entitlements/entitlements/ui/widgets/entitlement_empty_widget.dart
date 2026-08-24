import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';

/// **الفاضي هنا فاضيين، والفرق بينهم هو نص الشاشة.**
///
/// ## الحالتين
///
/// **① الرقم مش مأكّد.** `PackageEntitlementService::listForUser()` بيطابق
/// على `provider_customers.platform_user_id`. لو الريسبشن عمل العميلة من
/// رقم من غير ربط، السيرفر بيرجّع array فاضية **لعميلة ماسكة باقة مدفوعة**.
/// دي مش «مفيش باقات» — دي «مش شايفين باقاتك»، والفرق هو الفرق بين طريق
/// مسدود وزرار.
///
/// وهي **أكتر حالة متوقعة عند الإطلاق**، مش حالة حافة.
///
/// **② فاضي فعلاً.** الرقم مأكّد ومفيش حاجة.
///
/// ⚠ **ولا واحدة فيهم فيها CTA شرا.** مافيش catalogue ولا بوابة دفع
/// (`payments.payment_method` = `enum('cash','paymob')` من غير أي تكامل
/// Paymob في الكود). زرار «اشتري باقة» هيوعد بحاجة مش موجودة.
class EntitlementEmptyWidget extends StatelessWidget {
  const EntitlementEmptyWidget({
    required this.tab,
    required this.needsVerification,
    this.onVerify,
    super.key,
  });

  final EntitlementTab tab;

  /// `phone_verified_at == null` — الفرع الأول.
  final bool needsVerification;

  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    if (needsVerification) {
      return AppEmptyStateWidget(
        icon: Icons.phone_iphone_rounded,
        title: 'مش لاقي باقاتك؟',
        message: 'لو حجزت أو اشتريت باقة من الفرع، أكّد رقم تليفونك عشان '
            'يظهروا هنا.',
        actionLabel: 'أكّد رقمي',
        onAction: onVerify,
      );
    }

    return switch (tab) {
      EntitlementTab.packages => const AppEmptyStateWidget(
        icon: Icons.card_giftcard_rounded,
        title: 'لسه مافيش باقات',
        // بتقول **إزاي بتتشتري** من غير ما تدّعي إنك تقدر تشتريها من هنا.
        message: 'الباقات بتتشتري من الفرع نفسه.',
      ),
      EntitlementTab.followUps => const AppEmptyStateWidget(
        icon: Icons.event_repeat_rounded,
        title: 'مفيش متابعات مستحقة دلوقتي',
        message: 'المتابعة بتتولد لوحدها بعد ما خدمة تخلص، لو الفرع مفعّلها.',
      ),
    };
  }
}
