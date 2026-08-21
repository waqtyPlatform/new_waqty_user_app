import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **شريط «عندك ٣ جلسات» في «حجوزاتي».**
///
/// ## المشكلة اللي بيحلها
///
/// العميلة اللي اشترت باقة من الفرع **مش عارفة إن التطبيق يعرف**. لو
/// الباقات عايشة في «حسابي» بس، هي لازم تدوّر على حاجة هي أصلاً مش
/// متأكدة إنها موجودة — وده مابيحصلش.
///
/// «حجوزاتي» هو التبويب اللي بتفتحه وهي بتفكّر في مواعيدها، فده أقرب مكان
/// للحظة اللي الباقة بتنفع فيها.
///
/// ⚠ **بيختفي بالكامل لما مافيش حاجة قابلة للتصرف.** شريط بيقول «عندك ٠»
/// أوحش من مفيش شريط، وشريط دايم بيتحوّل لخلفية والعين بتعدّي عليه.
class EntitlementStripWidget extends StatelessWidget {
  const EntitlementStripWidget({
    required this.package,
    required this.followUpCount,
    this.onTap,
    super.key,
  });

  /// أول باقة شغّالة. `null` = مفيش باقات، والشريط بيتكلم عن المتابعات بس.
  final PackageEntitlementUiModel? package;

  final int followUpCount;

  final VoidCallback? onTap;

  /// **بيتكلم عن حاجة واحدة بالتحديد، مش عن مجموع.**
  ///
  /// «عندك ٣ جلسات في باقة قص الشعر» فعل. «عندك ٤ استحقاقات» تصنيف —
  /// والعميلة مش بتفكّر بكلمة «استحقاق» أصلاً.
  String? get message {
    final current = package;

    if (current is SessionPackageEntitlement &&
        current.availableSessions > 0 &&
        !current.isSingleVisit) {
      return 'عندك ${AppFormat.digits(current.availableSessions)} جلسات '
          'في ${current.packageName}';
    }

    if (current is UsagePackageEntitlement && current.availableUnits > 0) {
      return 'فاضلك ${AppFormat.digits(current.availableUnits)} '
          '${current.unitName} في ${current.packageName}';
    }

    if (current is SessionPackageEntitlement &&
        current.isSingleVisit &&
        current.availableSessions > 0) {
      return 'عندك زيارة في ${current.packageName} لسه ما اتستخدمتش';
    }

    if (followUpCount > 0) {
      return followUpCount == 1
          ? 'عندك متابعة مستحقة'
          : 'عندك ${AppFormat.digits(followUpCount)} متابعات مستحقة';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
      child: AppSurfaceWidget(
        level: AppElevation.raised,
        radius: AppRadius.m,
        padding: EdgeInsets.all(AppSpacing.cardPadding.r),
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.card_giftcard_rounded,
              size: 20.r,
              color: AppSemanticColors.accentText,
            ),
            SizedBox(width: AppSpacing.s12.w),
            // النص هو اللي بيتنازل والسهم لأ — والـ`Expanded` مش `Spacer`
            // عشان الصف مايفيضش عند مقياس خط ١٫٣.
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMd,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSpacing.s8.w),
            const DirectionalChevronWidget(),
          ],
        ),
      ),
    );
  }
}
