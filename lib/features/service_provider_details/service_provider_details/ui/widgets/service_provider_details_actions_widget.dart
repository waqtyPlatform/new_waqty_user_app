import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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
        // **كان `64.h` أصم.**
        //
        // «الاتجاهات» على تلت العرض عند مقياس خط ١٫٣ **بتتلف سطرين**،
        // فالعمود كان بيطلع ٦٧٫٧ في صندوق ٦٤ — فيضان ٤ بكسل. حاجتين
        // اتظبطوا: الارتفاع بقى بيكبر مع النص، واللابل بقى سطر واحد مقصوص.
        height: AppSpacing.scaledHeight(
          context,
          // أيقونة ٢٠ + مسافة ٤ + حشوة ٢٤.
          fixed: 48,
          // `captionInk` ١٢×١٫٤٠.
          text: 16.8,
        ).h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **رمادية مش خضرا** — تلات أيقونات خضرا جنب بعض كانت بتسحب
            // العين لأقل تلات أفعال أهمية في الصفحة.
            Icon(icon, size: 20.r, color: AppSemanticColors.textSecondary),
            verticalSpace(AppSpacing.s4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionInk,
            ),
          ],
        ),
      ),
    );
  }
}
