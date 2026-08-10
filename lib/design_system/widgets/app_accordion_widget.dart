import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_hairline_widget.dart';
import 'app_surface_widget.dart';

/// عنصر بيتفتح وبيتقفل.
///
/// معمّم من `help_faq_section_widget.dart` — كان مسمّى FAQ رغم إنه
/// أكورديون عادي، وشايل `HelpFaqItemData` (`uuid` · `question` ·
/// `answer` · `isExpanded`) وهو موديل feature.
///
/// ⚠ **الحالة جوه الـ widget بقصد.** فتح/قفل مالوش قيمة برّه الشاشة —
/// رفعه لـ state خارجي بيخلي كل مستخدم للأكوردين يكتب
/// `Set<String> expanded` بإيده.
///
/// السهم بيلفّ مش بيتبدّل: `chevron` بيتقلب في الـ RTL، والدوران **مش
/// اتجاهي** فبيقرا صح في اللغتين.
class AppAccordionWidget extends StatefulWidget {
  const AppAccordionWidget({
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
    this.onChanged,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? subtitle;

  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;

  @override
  State<AppAccordionWidget> createState() => _AppAccordionWidgetState();
}

class _AppAccordionWidgetState extends State<AppAccordionWidget> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _open = !_open);
    widget.onChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s8.h),
      child: AppSurfaceWidget(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title, style: AppTextStyles.bodyMdStrong),
                          if (widget.subtitle != null) ...[
                            SizedBox(height: AppSpacing.titleToSubtitle.h),
                            Text(
                              widget.subtitle!,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: AppMotion.fast,
                      curve: AppMotion.standard,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.r,
                        color: AppSemanticColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: AppMotion.base,
              sizeCurve: AppMotion.standard,
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHairlineWidget(),
                  Padding(
                    padding: AppSpacing.card,
                    child: DefaultTextStyle(
                      style: AppTextStyles.bodyMdMuted,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
