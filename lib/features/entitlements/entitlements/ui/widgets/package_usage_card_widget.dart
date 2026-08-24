import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_shell_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_progress_widget.dart';

/// كارت **بركة وحدات** — `usage_based`.
///
/// ⚠ **الكارت ده عمره ما يقول «جلسة»** إلا لو الوحدة نفسها اسمها كده
/// (`unit_name` جاي من السيرفر، فيه باقات وحدتها «جلسة ليزر» فعلاً).
/// الفرق إن الكلمة **بتاعت السيرفر مش بتاعتنا**.
class PackageUsageCardWidget extends StatelessWidget {
  const PackageUsageCardWidget({
    required this.package,
    this.onTap,
    this.onBook,
    super.key,
  });

  final UsagePackageEntitlement package;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final isTerminal = package.status.isTerminal;

    return EntitlementCardShellWidget(
      title: package.packageName,
      subtitle: package.owner.providerName.isEmpty
          ? null
          : package.owner.providerName,
      status: package.status,
      expiresAt: package.expiresAt,
      expiresSoon: package.expiresSoon(),
      isMuted: isTerminal,
      onTap: onTap,
      action: package.isBookableFromApp && onBook != null
          ? AppButtonWidget(label: 'احجز جلسة', onPressed: onBook)
          : null,
      blockedReason: package.blockedReason,
      body: <Widget>[
        Text(
          'فاضل ${AppFormat.digits(package.availableUnits)} ${package.unitName}',
          style: AppTextStyles.bodyMdStrong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSpacing.s12.h),

        // البركة مالهاش «محجوز» في الرد — السيرفر بيرجّع مستهلك ومتاح بس.
        // فبنمرّر صفر بدل ما نخترع شريحة.
        EntitlementProgressWidget(
          used: package.totalUnitsConsumed,
          reserved: 0,
          available: package.availableUnits,
          usedLabel: 'اتصرف',
          availableLabel: 'متاح',
        ),

        // **الوحدات المنتهية سطر ثانوي — عمرها ما تدخل الرقم الأساسي.**
        //
        // ضمّها للمتاح كدب صريح، وضمّها للمستهلك بيخفي إن العميلة دفعت في
        // حاجة وضاعت. السطر ده هو الطريقة الوحيدة الصادقة.
        if (package.expiredUnits > 0) ...<Widget>[
          SizedBox(height: AppSpacing.s8.h),
          Text(
            '${AppFormat.digits(package.expiredUnits)} ${package.unitName} '
            'انتهت صلاحيتها',
            style: AppTextStyles.caption.copyWith(
              color: AppSemanticColors.dangerOnSoft,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (package.allowedServices.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.s12.h),
          Text(
            'تنفع على: ${package.allowedServices.map((s) => s.name).join(' · ')}',
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // بركة من كذا شرا — كل شرا ليه انتهاء لوحده، والرقم الكبير بيخفي
        // ده. الأكورديون بيفتحه لمن يسأل من غير ما يزحم الكارت.
        if (package.purchaseCount > 1) ...<Widget>[
          SizedBox(height: AppSpacing.s12.h),
          Text(
            'الرصيد ده من ${AppFormat.digits(package.purchaseCount)} شراءات '
            'بتواريخ انتهاء مختلفة',
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
