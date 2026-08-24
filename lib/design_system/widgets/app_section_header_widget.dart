import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'directional_chevron_widget.dart';

/// لابل قسم + فعل اختياري.
///
/// ⚠ **بيملك مسافته بنفسه.** `sectionBreak` فوقه و`headerToContent` تحته —
/// عشان اللي بينده مايحطش المسافة بإيده وتطلع مختلفة في كل شاشة.
///
/// الـ `first` بيشيل المسافة العلوية لأول قسم في الشاشة.
class AppSectionHeaderWidget extends StatelessWidget {
  const AppSectionHeaderWidget({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.first = false,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String title;

  final String? actionLabel;
  final VoidCallback? onAction;

  /// أول قسم في الشاشة — مابياخدش مسافة فوقه.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: first ? 0 : AppSpacing.sectionBreak.h,
        bottom: AppSpacing.headerToContent.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.sectionHeader,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: AppSpacing.touchTarget.r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel!, style: AppTextStyles.label),
                    const DirectionalChevronWidget(size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
