import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// عدّاد كمية — ناقص · رقم · زايد.
///
/// ⚠ **الأيقونتين `add` و`remove` مش اتجاهيتين** — علامة الزائد والناقص
/// مالهمش «بداية ونهاية». اللي بيتقلب هو **ترتيبهم في الصف**، وده بيحصل
/// لوحده لأن الـ `Row` بيتقلب مع الاتجاه.
///
/// وده مقصود: في العربي الناقص بيبقى على اليمين — نفس ترتيب اللي في
/// الإنجليزي بس مقلوب، فالعين بتلاقي «زوّد» في نهاية القراءة في اللغتين.
class AppQuantityWidget extends StatelessWidget {
  const AppQuantityWidget({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.formatValue,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  /// ⚠ **البوابة اللي كل رقم معروض بيعدّي منها.** الكيت بيرسم `'$value'`
  /// افتراضيًا؛ التطبيق اللي عايز أرقام عربية-هندية أو فواصل آلاف
  /// بيمرّر `AppFormat.digits` هنا.
  final String Function(int value)? formatValue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surfaceSunken,
        borderRadius: AppRadius.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Step(
            icon: Icons.remove_rounded,
            onTap: value - step >= min ? () => onChanged(value - step) : null,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 32.w),
            child: Text(
              formatValue?.call(value) ?? '$value',
              style: AppTextStyles.bodyMdStrong,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          _Step(
            icon: Icons.add_rounded,
            onTap: value + step <= max ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppSpacing.touchTarget.r,
          height: AppSpacing.touchTarget.r,
          child: Icon(
            icon,
            size: 18.r,
            color: onTap == null
                ? AppSemanticColors.textTertiary
                : AppSemanticColors.accentText,
          ),
        ),
      ),
    );
  }
}

/// نقطة عدّ فوق أيقونة — إشعارات، عربة.
class AppBadgeDotWidget extends StatelessWidget {
  const AppBadgeDotWidget({
    required this.child,
    this.count,
    this.show = true,
    this.tone,
    super.key,
  });

  final Widget child;

  /// `null` = نقطة صمّا من غير رقم.
  final String? count;

  final bool show;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    final ground = tone ?? AppSemanticColors.danger;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -2.h,
          end: -2.w,
          child: Container(
            constraints: BoxConstraints(
              minWidth: (count == null ? 8 : 16).r,
              minHeight: (count == null ? 8 : 16).r,
            ),
            padding: count == null
                ? EdgeInsets.zero
                : EdgeInsetsDirectional.symmetric(horizontal: 4.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ground,
              borderRadius: AppRadius.rPill,
              border: Border.all(color: AppSemanticColors.page, width: 1.5),
            ),
            child: count == null
                ? null
                : Text(
                    count!,
                    style: AppTextStyles.overline.copyWith(
                      color: AppSemanticColors.textOnDanger,
                    ),
                    maxLines: 1,
                  ),
          ),
        ),
      ],
    );
  }
}
