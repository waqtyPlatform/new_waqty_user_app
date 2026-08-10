import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_segmented_widget.dart';

/// شريط تبويبات بخط سفلي.
///
/// منقول من `my_booking_tab_bar_widget.dart` — بس اللابلات كانت متحطوطة
/// جوّه (`myBooking.upcoming/completed/canceled`) والكيت مالوش لوكلة.
///
/// ## إمتى ده وإمتى [AppSegmentedWidget]
///
/// | | |
/// |---|---|
/// | **التبويب** | بيقسم **نفس النوع** من المحتوى لحالات: قادم / خلص / ملغي. الفصل دايم. |
/// | **المقسّم** | بيغيّر **مدى** نفس المحتوى: الشهر ده / الشهر اللي فات. الفصل مؤقت. |
///
/// عند ٣ تبويبات فأكتر بيبقى قابل للسكرول أفقيًا بدل ما اللابلات تتقص.
class AppTabBarWidget<T> extends StatelessWidget {
  const AppTabBarWidget({
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.scrollable = false,
    super.key,
  });

  final List<AppSegment<T>> tabs;
  final T value;
  final ValueChanged<T> onChanged;

  /// لابلات طويلة أو أكتر من تلاتة.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (final tab in tabs)
          if (scrollable)
            _Tab(
              label: tab.label,
              selected: tab.value == value,
              onTap: () => onChanged(tab.value),
            )
          else
            Expanded(
              child: _Tab(
                label: tab.label,
                selected: tab.value == value,
                onTap: () => onChanged(tab.value),
              ),
            ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: AppSemanticColors.border),
        ),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.s8.w,
              ),
              child: row,
            )
          : row,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(minHeight: AppSpacing.touchTarget.r),
            alignment: Alignment.center,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s12.w,
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
            ),
          ),
          AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            height: 2.h,
            decoration: BoxDecoration(
              color: selected
                  ? AppSemanticColors.accentText
                  : Colors.transparent,
              borderRadius: AppRadius.rPill,
            ),
          ),
        ],
      ),
    );
  }
}
