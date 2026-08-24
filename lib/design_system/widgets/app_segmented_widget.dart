import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// قسم واحد في [AppSegmentedWidget].
@immutable
class AppSegment<T> {
  const AppSegment({required this.value, required this.label});

  final T value;

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String label;
}

/// كنترول مقسّم — **بيستبدل تلات نسخ**.
///
/// | النسخة | مشكلتها |
/// |---|---|
/// | `stats_filter_widget.dart` | اللابلات `['Today','Week','Month']` **إنجليزي متحطوط** في تطبيق عربي |
/// | `my_earning_period_switcher_widget.dart` | بينادي `context.read<MyEarningCubit>()` **جوه كنترول صافي** |
/// | `earning_trend_period_switcher_widget.dart` | نفس الحاجة بالظبط |
///
/// generic + كولباك بيقتلوا التلات مشاكل مرة واحدة: الكنترول مابيعرفش
/// حاجة عن الداتا ولا عن الـ state.
///
/// ⚠ عند خمس أقسام أو أكتر بيبقى ضيّق — استخدم [AppChipWidget] في
/// `SingleChildScrollView` بدله.
class AppSegmentedWidget<T> extends StatelessWidget {
  const AppSegmentedWidget({
    required this.segments,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(4.r),
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceSunken,
        borderRadius: AppRadius.rM,
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: _Tab(
                label: segment.label,
                selected: segment.value == value,
                onTap: () => onChanged(segment.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        constraints: BoxConstraints(minHeight: (AppSpacing.touchTarget - 8).r),
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.s8.w),
        decoration: BoxDecoration(
          color: selected ? AppSemanticColors.surfaceRaised : null,
          borderRadius: AppRadius.rXs,
        ),
        child: Text(
          label,
          style: selected
              ? AppTextStyles.bodyMdStrong.copyWith(
                  color: AppSemanticColors.accentText,
                )
              : AppTextStyles.bodyMdMuted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
