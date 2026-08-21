import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// رأس صفحة التفاصيل — الاسم والحالة وتواريخ الشرا والصلاحية.
///
/// ⚠ **مفيش اسم مزوّد ولا لوجو هنا** — ومش نسيان. رد
/// `/entitlements/packages` مافيهوش `provider` ولا `branch` في أي صف، فما
/// ينفعش نقول «باقة صالون كابتن» وإحنا مش عارفين. TODO(api): BE-A1.
class EntitlementDetailHeaderWidget extends StatelessWidget {
  const EntitlementDetailHeaderWidget({
    required this.title,
    required this.status,
    this.subtitle,
    this.purchasedAt,
    this.expiresAt,
    super.key,
  });

  final String title;
  final String? subtitle;
  final PackageStatus status;
  final DateTime? purchasedAt;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleLg,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (status.isTerminal) ...<Widget>[
              SizedBox(width: AppSpacing.s8.w),
              AppPillWidget(
                label: status.label,
                tone: status == PackageStatus.expired
                    ? AppPillTone.danger
                    : AppPillTone.neutral,
              ),
            ],
          ],
        ),

        if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.titleToSubtitle.h),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMdMuted,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        SizedBox(height: AppSpacing.s16.h),

        if (purchasedAt != null)
          AppDetailRowWidget(
            label: 'اتشرت في',
            value: AppFormat.fullDate(purchasedAt!),
          ),
        if (expiresAt != null)
          AppDetailRowWidget(
            label: status == PackageStatus.expired ? 'انتهت في' : 'صالحة لحد',
            value: AppFormat.fullDate(expiresAt!),
          ),
      ],
    );
  }
}
