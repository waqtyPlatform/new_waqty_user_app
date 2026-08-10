import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// دور الزرار — **مش ستايله**.
enum AppButtonVariant {
  /// الفعل الأساسي. **واحد بس في الشاشة.**
  primary,

  /// فعل تاني بنفس الأهمية تقريبًا — محدّد مش متعبّي.
  secondary,

  /// فعل مدمّر: حذف، إلغاء حجز.
  danger,

  /// فعل خفيف — نص بس.
  ghost,
}

/// الزرار.
///
/// ## ده بيستبدل إيه
///
/// `ButtonWidget` (١٤ باراميتر ستايل، مفيش variants) و**`AppPinButtonWidget`
/// (١٣ استخدام — أكتر زرار متكرر في employee-app، أكتر من `ButtonWidget`
/// نفسه)**. الاتنين بيختلفوا في الاستدارة بس: 12 مقابل `20.0` **من غير
/// `.r`**. الكيت بياخد **٢٠ مقاسة** زي الحقل اللي بيقعد فوقه.
///
/// البديل المرفوض: نسيب الاستدارتين. مرفوض لأن ده **باج مش قرار** — نفس
/// التوكن بسلوكين، وعلى موبايل ٤٢٨ نقطة الزرار بيبان أكثر تربيعًا من الحقل.
///
/// ## اللي اتصلّح كمان
///
/// نسخة employee-app بتنادي `onTap` **وهي بتحمّل** — ضغطتين سريعتين =
/// إرسالين. هنا `isLoading` بيقفل اللمس.
class AppButtonWidget extends StatelessWidget {
  const AppButtonWidget({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String label;

  /// `null` = معطّل.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// عرض كامل. `false` للزرار اللي جوه `Row`.
  final bool expand;

  static const double height = 50;
  static const double _fixedPart = 26;

  /// `button` = 16 × 1.40 = 22.4، **+١٫٦ هامش تقريب**.
  static const double _textPart = 24;

  static double heightOf(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final fg = _foreground;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18.r,
            height: 18.r,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18.r, color: fg),
            SizedBox(width: AppSpacing.s8.w),
          ],
          // ⚠ `Flexible` مش نص عاري: لابل طويل عند مقياس ١٫٣ بيفيض الزرار.
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      width: expand ? double.infinity : null,
      height: heightOf(context).h,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: AppRadius.rL,
        border: _border,
        boxShadow: variant == AppButtonVariant.primary && _enabled
            ? null
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.rL,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: AppRadius.rL,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.s16.w,
            ),
            child: Center(widthFactor: expand ? null : 1, child: content),
          ),
        ),
      ),
    );
  }

  Color get _background {
    if (!_enabled && !isLoading) {
      return switch (variant) {
        AppButtonVariant.primary ||
        AppButtonVariant.danger => AppSemanticColors.borderStrong,
        _ => Colors.transparent,
      };
    }
    return switch (variant) {
      // ⚠ `surfaceAccentDeep` مش `accent` — قرار D6. الأبيض على اللمسة
      // بيدي 3.96:1، وعلى دي 6.81:1.
      AppButtonVariant.primary => AppSemanticColors.surfaceAccentDeep,
      AppButtonVariant.danger => AppSemanticColors.danger,
      AppButtonVariant.secondary ||
      AppButtonVariant.ghost => Colors.transparent,
    };
  }

  Color get _foreground {
    if (!_enabled && !isLoading) return AppSemanticColors.textTertiary;
    return switch (variant) {
      AppButtonVariant.primary => AppSemanticColors.textOnAccentDeep,
      AppButtonVariant.danger => AppSemanticColors.textOnDanger,
      AppButtonVariant.secondary ||
      AppButtonVariant.ghost => AppSemanticColors.accentText,
    };
  }

  BoxBorder? get _border {
    if (variant != AppButtonVariant.secondary) return null;
    return Border.all(
      color: _enabled
          ? AppSemanticColors.accentText
          : AppSemanticColors.borderStrong,
      width: 1.5,
    );
  }
}
