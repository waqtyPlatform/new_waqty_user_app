import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// مؤشّر خطوات أفقي — نقاط.
///
/// معمّم من `change_pin_progress_widget.dart` اللي كان **مقفول على تلات
/// خطوات**.
///
/// ⚠ النقطة الشغّالة بتطول مش بس بتتلوّن: اللون لوحده مش كفاية لحد
/// مايفرقش الألوان، والشكل بيشتغل من غيره.
class AppStepperWidget extends StatelessWidget {
  const AppStepperWidget({
    required this.steps,
    required this.current,
    this.labels,
    super.key,
  });

  final int steps;

  /// من ٠ لـ `steps - 1`.
  final int current;

  /// لابلات تحت النقاط. **نصوص جاهزة — مش مفاتيح.**
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < steps; i++) ...[
              if (i > 0) SizedBox(width: AppSpacing.s4.w),
              AnimatedContainer(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                width: (i == current ? 24 : 8).r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: i <= current
                      ? AppSemanticColors.accent
                      : AppSemanticColors.borderStrong,
                  borderRadius: AppRadius.rPill,
                ),
              ),
            ],
          ],
        ),
        if (labels != null && current < labels!.length) ...[
          SizedBox(height: AppSpacing.s8.h),
          Text(
            labels![current],
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// خط زمني رأسي — تاريخ حالة، خطوات حجز، سجل حركات.
///
/// ⚠ **الخط بيترسم بين النقط مش وراها.** آخر عنصر مالوش خط تحته، وده
/// اللي بيخلي القايمة تقرا «خلصت» بدل ما تقرا «فيه كمان».
class AppTimelineWidget extends StatelessWidget {
  const AppTimelineWidget({required this.items, super.key});

  final List<AppTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Rail(
                  isFirst: i == 0,
                  isLast: i == items.length - 1,
                  done: items[i].done,
                  tone: items[i].tone,
                ),
                SizedBox(width: AppSpacing.s12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: i == items.length - 1 ? 0 : AppSpacing.s16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                items[i].title,
                                style: AppTextStyles.bodyMdStrong,
                              ),
                            ),
                            if (items[i].meta != null) ...[
                              SizedBox(width: AppSpacing.s8.w),
                              Text(
                                items[i].meta!,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                        if (items[i].subtitle != null) ...[
                          SizedBox(height: AppSpacing.titleToSubtitle.h),
                          Text(
                            items[i].subtitle!,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// عنصر في [AppTimelineWidget]. **نصوص جاهزة — مش مفاتيح.**
@immutable
class AppTimelineItem {
  const AppTimelineItem({
    required this.title,
    this.subtitle,
    this.meta,
    this.done = false,
    this.tone,
  });

  final String title;
  final String? subtitle;

  /// وقت أو تاريخ على اليمين.
  final String? meta;

  final bool done;
  final Color? tone;
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.isFirst,
    required this.isLast,
    required this.done,
    required this.tone,
  });

  final bool isFirst;
  final bool isLast;
  final bool done;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final color =
        tone ??
        (done ? AppSemanticColors.accent : AppSemanticColors.borderStrong);

    return SizedBox(
      width: 16.r,
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: done ? color : AppSemanticColors.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(width: 2.w, color: AppSemanticColors.border),
            ),
        ],
      ),
    );
  }
}
