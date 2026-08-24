import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// مفتاح تشغيل/إيقاف.
///
/// منقول من `notification_setting_list_widget.dart:131 _NotificationToggleWidget`
/// — كان **خاص**، وهو **الكنترول المخصوص الوحيد في employee-app** وجزء
/// من الهوية. الكيت بيطلّعه عام.
///
/// ⚠ الحالة الوسيطة ([isLoading]) موجودة لأن التوجل غالبًا بينده API:
/// من غيرها الواجهة بتقلب فورًا وبترجع لو الطلب فشل، والعميل بيشوف
/// «اتغيّر… لأ ما اتغيّرش».
class AppToggleWidget extends StatelessWidget {
  const AppToggleWidget({
    required this.value,
    required this.onChanged,
    this.isLoading = false,
    super.key,
  });

  final bool value;

  /// `null` = معطّل.
  final ValueChanged<bool>? onChanged;

  final bool isLoading;

  static const double _width = 48;
  static const double _height = 28;

  bool get _enabled => onChanged != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final track = !_enabled && !isLoading
        ? AppSemanticColors.border
        : value
        ? AppSemanticColors.accent
        : AppSemanticColors.borderStrong;

    return GestureDetector(
      onTap: _enabled ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // هدف اللمس أكبر من الشكل — الشكل ٢٨ والهدف ٤٤.
        width: AppSpacing.touchTarget.r,
        height: AppSpacing.touchTarget.r,
        child: Center(
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            width: _width.r,
            height: _height.r,
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: track,
              borderRadius: AppRadius.rPill,
            ),
            child: AnimatedAlign(
              duration: AppMotion.fast,
              curve: AppMotion.standard,
              // ⚠ `AlignmentDirectional` — المفتاح بيتقلب مع اللغة.
              alignment: value
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Container(
                width: (_height - 6).r,
                height: (_height - 6).r,
                decoration: BoxDecoration(
                  color: AppSemanticColors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(4.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppSemanticColors.accent,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// صف فيه لابل ومفتاح — الشكل اللي التوجل بيتحط بيه ٩٩٪ من الوقت.
class AppToggleRowWidget extends StatelessWidget {
  const AppToggleRowWidget({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.isLoading = false,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String title;
  final String? subtitle;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          // ⚠ `Expanded`: من غيره اللابل الطويل بيفيض الصف عند مقياس ١٫٣.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.bodyMdStrong),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.titleToSubtitle.h),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          AppToggleWidget(
            value: value,
            onChanged: onChanged,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
