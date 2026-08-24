import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// الخدمات اللي الرصيد ينفع يتصرف عليها.
///
/// **السؤال اللي بتجاوبه: «الرصيد ده ينفع في إيه؟»** — وده نص سؤال البركة.
/// النص التاني «فاضل كام» وبيتجاوب فوق. من غير الجزء ده، العميلة عندها
/// رقم مالوش معنى.
class EntitlementAllowedServicesWidget extends StatelessWidget {
  const EntitlementAllowedServicesWidget({required this.services, super.key});

  final List<AllowedServiceUiModel> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const AppSectionHeaderWidget(title: 'ينفع على'),
        for (final service in services)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s8.h),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    service.name,
                    style: AppTextStyles.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (service.durationMinutes > 0) ...<Widget>[
                  SizedBox(width: AppSpacing.s8.w),
                  Text(
                    AppFormat.duration(service.durationMinutes),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
