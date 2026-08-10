import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// شريط تقدّم خطي.
///
/// ⚠ **مش `LinearProgressIndicator`.** بتاع ماتيريال بيرسم مسار بارتفاع
/// ٤ ثابت من غير استدارة، وبيقرا «تحميل» مش «قد إيه خلص». ده بيقرا
/// الاتنين حسب [showLabel].
class AppProgressWidget extends StatelessWidget {
  const AppProgressWidget({
    required this.value,
    this.label,
    this.trailingLabel,
    this.tone,
    this.height = 8,
    super.key,
  });

  /// من ٠ لـ ١. **بيتقصّ** — قيمة برّه المدى غلط في الداتا مش سبب لكراش.
  final double value;

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String? label;
  final String? trailingLabel;

  final Color? tone;
  final double height;

  bool get _showLabel => label != null || trailingLabel != null;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final fill = tone ?? AppSemanticColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showLabel) ...[
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              if (trailingLabel != null) ...[
                SizedBox(width: AppSpacing.s8.w),
                Text(trailingLabel!, style: AppTextStyles.captionStrong),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.s4.h),
        ],
        ClipRRect(
          borderRadius: AppRadius.rPill,
          child: SizedBox(
            height: height.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: AppSemanticColors.surfaceSunken),
                ),
                // `FractionallySizedBox` بيتقلب لوحده مع الاتجاه لما يبقى
                // جوه `Align` باتجاه `AlignmentDirectional`.
                Positioned.fill(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AnimatedFractionallySizedBox(
                      duration: AppMotion.base,
                      curve: AppMotion.standard,
                      widthFactor: clamped,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: AppRadius.rPill,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// حلقة تقدّم — للنِسب الصغيرة جنب رقم.
class AppProgressRingWidget extends StatelessWidget {
  const AppProgressRingWidget({
    required this.value,
    this.size = 44,
    this.strokeWidth = 4,
    this.tone,
    this.center,
    super.key,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? tone;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.r,
      height: size.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth.r,
              strokeCap: StrokeCap.round,
              backgroundColor: AppSemanticColors.surfaceSunken,
              valueColor: AlwaysStoppedAnimation(
                tone ?? AppSemanticColors.accent,
              ),
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}
