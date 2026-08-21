import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_shell_widget.dart';

/// التحميل **بنفس هيكل الكارت الحقيقي**.
///
/// بيمرّ على [EntitlementCardShellWidget] نفسه بدل ما يقلّد حشوته — نفس
/// سبب `MyBookingRowSkeletonWidget` و`ProviderRowSkeletonWidget`: التقليد
/// بيتكسر أول ما الحشوة تتغيّر، والـskeleton بيفضل على شكله القديم في
/// صمت وبيبقى في الشاشة «قفزة» بين التحميل والمحتوى محدش شايف سببها.
class EntitlementCardSkeletonWidget extends StatelessWidget {
  const EntitlementCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonGroupWidget(
      child: EntitlementCardShellWidget(
        // العنوان بيتبعت فاضي والمستطيل بيقوم مقامه — الهيكل بيرسم
        // `SizedBox.shrink` للنص الفاضي فمافيش سطر شبح.
        title: '',
        status: PackageStatus.active,
        body: <Widget>[
          const AppSkeletonBoxWidget(width: 160, height: 16),
          SizedBox(height: AppSpacing.s12.h),
          const AppSkeletonBoxWidget(
            width: double.infinity,
            height: 8,
            radius: AppRadius.pill,
          ),
          SizedBox(height: AppSpacing.s8.h),
          Row(
            children: <Widget>[
              const AppSkeletonBoxWidget(width: 64, height: 12),
              SizedBox(width: AppSpacing.s12.w),
              const AppSkeletonBoxWidget(width: 64, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
