import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_shell_widget.dart';

/// كارت **متابعة مستحقة**.
///
/// ## دي الحاجة الوحيدة في الشاشة اللي بتتحجز فعلاً
///
/// الباقة مالهاش طريق للفرع (BE-A1). المتابعة عندها `original_booking_uuid`
/// — ومنه `GET /user/bookings/{uuid}` بيدّي `branch.uuid`، ومنه المواعيد.
/// فالزرار هنا **شغّال**، وهو الفرق العملي بين التبويبين النهاردة.
class FollowUpCardWidget extends StatelessWidget {
  const FollowUpCardWidget({
    required this.followUp,
    this.onBook,
    this.onTap,
    super.key,
  });

  final FollowUpEntitlementUiModel followUp;
  final VoidCallback? onBook;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bookable = followUp.isBookableFromApp;

    return EntitlementCardShellWidget(
      title: 'متابعة ${followUp.serviceName}',
      subtitle: _priceLine,
      status: followUp.status,
      expiresAt: followUp.validUntil,
      expiresSoon: _expiresSoon,
      isMuted: followUp.status.isTerminal,
      onTap: onTap,
      blockedReason: _blockedReason,
      action: bookable && onBook != null
          ? AppButtonWidget(label: 'احجز المتابعة', onPressed: onBook)
          : null,
      body: <Widget>[
        if (followUp.employeeRule == FollowUpEmployeeRule.sameRequired &&
            followUp.employee != null)
          // **مفيش اختيار أخصائي هنا — والسبب مكتوب.**
          //
          // القاعدة `same_employee_required` جاية من إعدادات الخدمة، وفي
          // السياق الطبي دي مش تفضيل — دي استمرارية علاج. عرض picker
          // بيوحي إن فيه اختيار، والتأكيد كان هيترفض من السيرفر.
          Row(
            children: <Widget>[
              Icon(
                Icons.person_outline_rounded,
                size: 16.r,
                color: AppSemanticColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  'المتابعة مع ${followUp.employee!.name}',
                  style: AppTextStyles.bodyMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        else
          Text(
            followUp.availableCount > 0
                ? 'متاحة لحد ما الصلاحية تخلص'
                : 'اتستخدمت',
            style: AppTextStyles.bodyMd,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// السعر — **مجانية** أو **بخصم** أو ساكت.
  String get _priceLine {
    if (followUp.isFree) return 'المتابعة دي مجانية';
    if (followUp.isDiscounted) {
      return 'بخصم · ${AppFormat.money(followUp.effectivePrice)}';
    }
    return AppFormat.money(followUp.effectivePrice);
  }

  bool get _expiresSoon {
    if (followUp.status != PackageStatus.active) return false;
    final days = followUp.daysUntilExpiry();
    return days != null && days >= 0 && days <= 7;
  }

  /// **الأخصائي مشي والقاعدة بتقول لازم هو — قرار BE-A5 لسه مفتوح.**
  ///
  /// مابنرخّيش القاعدة من عندنا. في متابعة طبية ده معناه نحط مريضة مع
  /// دكتور تاني بقرار اتاخد في الموبايل — وده مش قرار التطبيق.
  String? get _blockedReason {
    if (followUp.status.isTerminal) return null;
    if (followUp.isOrphaned) {
      return 'الأخصائي بتاع المتابعة مابقاش متاح — كلّم الفرع عشان يظبطلك ميعاد';
    }
    if (followUp.originalBookingUuid.isEmpty && followUp.availableCount > 0) {
      return 'مش قادرين نوصل لبيانات الفرع دلوقتي — كلّم الفرع للحجز';
    }
    return null;
  }
}
