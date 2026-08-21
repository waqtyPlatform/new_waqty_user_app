import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_shell_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_progress_widget.dart';

/// كارت باقة **بتتعدّ بالجلسات** — `multi_session` و`single_visit`.
///
/// ⚠ **الكارت ده عمره ما يقول «وحدة».** بياخد [SessionPackageEntitlement]
/// بالتحديد، فالحقول اللي بتاعت الوحدات **مش موجودة في نطاقه أصلاً** —
/// الخلط بين النوعين مستحيل يتكتب مش بس ممنوع.
class PackageSessionCardWidget extends StatelessWidget {
  const PackageSessionCardWidget({
    required this.package,
    this.onTap,
    super.key,
  });

  final SessionPackageEntitlement package;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTerminal = package.status.isTerminal;

    return EntitlementCardShellWidget(
      title: package.packageName,
      subtitle: package.serviceName,
      status: package.status,
      expiresAt: package.expiresAt,
      expiresSoon: package.expiresSoon(),
      isMuted: isTerminal,
      onTap: onTap,
      blockedReason: isTerminal ? null : package.blockedReason,
      body: <Widget>[
        if (package.isSingleVisit)
          // زيارة واحدة — الشريط بيقول «١ من ١» وده ضوضاء. السؤال هنا
          // «إيه اللي جواها» واللي بيتجاوب من `serviceName` فوق.
          Text(
            package.availableSessions > 0
                ? 'زيارة واحدة لسه ما اتستخدمتش'
                : 'الزيارة اتستخدمت',
            style: AppTextStyles.bodyMd,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        else ...<Widget>[
          Text(
            'فاضل ${AppFormat.digits(package.availableSessions)} '
            'من ${AppFormat.digits(package.totalSessions)} جلسات',
            style: AppTextStyles.bodyMdStrong,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.s12.h),
          EntitlementProgressWidget(
            used: package.completedSessions,
            reserved: package.reservedSessions,
            available: package.availableSessions,
          ),
          if (package.reservedSessions > 0) ...<Widget>[
            SizedBox(height: AppSpacing.s8.h),
            Text(
              'فيه جلسة محجوزة لميعاد جاي',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ],
    );
  }
}
