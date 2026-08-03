import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// اتصال · الاتجاهات · مشاركة.
///
/// القديمة كانت ٣ مربعات شكلها زراير ومفيش فيها ولا واحد بيستقبل ضغط.
/// الاتجاهات بتشتغل دلوقتي فعلاً — `AppConstant.openMap` كانت مكتوبة
/// من زمان و `url_launcher` موجودة في المشروع، وما حدش نداها.
///
/// أي إجراء مش متاح للفرع ده بيتعرض **باهت** — مش شغّال وميت.
class ServiceProviderDetailsActionsWidget extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onDirections;
  final VoidCallback? onShare;

  const ServiceProviderDetailsActionsWidget({
    super.key,
    this.onCall,
    this.onDirections,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.call_rounded,
            label: 'اتصال',
            onTap: onCall,
          ),
        ),
        horizontalSpace(AppSpacing.chipGap),
        Expanded(
          child: _ActionTile(
            icon: Icons.directions_rounded,
            label: 'الاتجاهات',
            onTap: onDirections,
          ),
        ),
        horizontalSpace(AppSpacing.chipGap),
        Expanded(
          child: _ActionTile(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            onTap: onShare,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1 : 0.38,
      child: AppSurfaceWidget(
        onTap: onTap,
        // غاطسة — دي كنترولات مساعدة، مش المحتوى.
        level: AppElevation.sunken,
        radius: AppRadius.m,
        height: 64.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **رمادية مش خضرا** — تلات أيقونات خضرا جنب بعض كانت بتسحب
            // العين لأقل تلات أفعال أهمية في الصفحة.
            Icon(icon, size: 20.r, color: AppSemanticColors.textSecondary),
            verticalSpace(AppSpacing.s4),
            Text(label, style: AppTextStyles.captionInk),
          ],
        ),
      ),
    );
  }
}
