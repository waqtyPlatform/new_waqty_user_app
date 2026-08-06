import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// نوع الزرار — **الشكل بيتقرر من الدور مش من مكان الاستدعاء**.
enum AppButtonVariant {
  /// الإجراء الأساسي في الشاشة. **واحد بس في الشاشة.**
  primary,

  /// إجراء تاني بنفس الأهمية البصرية بس مش هو المقصود.
  secondary,

  /// إجراء بيوّدي لخسارة: «إلغاء الحجز».
  danger,

  /// إجراء هادي جوه كارت أو فوتر — من غير حد ولا ملء.
  ghost,
}

/// زرار الأبلكيشن.
///
/// ## اللي كان قبل كده
///
/// `ButtonWidget` كان بياخد **١٧ باراميتر** كلهم شكل: `backGroundColor`
/// و`borderColor` و`borderWidth` و`borderRadius` و`fourGroundColor`
/// و`textStyle`... يعني كل موضع استدعاء كان بيصمّم زراره من الأول.
///
/// النتيجة المتوقعة: **٤ ارتفاعات مختلفة و٣ استدارات** في ١٤ موضع، والزرار
/// الأحمر في «إلغاء الحجز» كان لونه مكتوب بالإيد فمكانش بيقلب مع الوضع الغامق.
///
/// دلوقتي الشكل كله جوه، والاستدعاء بيقول **الدور** بس.
///
/// ## المقاسات من الـ design DNA
///
/// `Full-width rounded rectangle, solid fill, 12px border-radius, semibold,
/// ~50px height`. الارتفاع هنا **52** عشان يتقسّم صح على شبكة الـ ٤ ويسيب
/// للنص العربي (`bodyLg` بـ leading ١٫٤٠) هوا كفاية.
class AppButtonWidget extends StatelessWidget {
  final String label;

  /// `null` معناها **معطّل** — مش محتاج فلاج تاني، ودي نفس لغة `ElevatedButton`.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  /// وهو بيحمّل الزرار **مابيستقبلش ضغط**. قبل كده كان بيضرب `onTap` عادي
  /// أثناء التحميل — يعني ضغطتين سريعة = حجزين.
  final bool isLoading;

  final IconData? icon;

  /// الافتراضي عرض كامل (من الـ DNA). `false` للزراير اللي جوه صف.
  final bool expand;

  const AppButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadius.rS;
    final style = _style;

    // الارتفاع بيكبر مع مقياس الخط في الجزء اللي فيه نص بس — الحشوة
    // مالهاش دعوة بالمقياس، ومن غير ده الزرار بيفيض عند ١٫٣.
    final height = AppSpacing.scaledHeight(
      context,
      fixed: 30,
      text: 16 * 1.40,
    );

    final child = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      height: height.h,
      width: expand ? double.infinity : null,
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.s20.w),
      decoration: BoxDecoration(
        color: style.fill,
        borderRadius: radius,
        border: style.borderColor == null
            ? null
            : Border.all(color: style.borderColor!, width: 1.5.r),
        // الظل الأخضر بيبان تحت الأساسي **وهو شغّال بس** — تحت زرار معطّل
        // بيقرا كأن الزرار لسه بيشتغل.
        boxShadow: style.hasShadow && _isEnabled ? AppShadows.accent : null,
      ),
      child: isLoading
          ? SizedBox(
              height: 20.r,
              width: 20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.r,
                color: style.ink,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18.r, color: style.ink),
                  SizedBox(width: AppSpacing.s8.w),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.button.copyWith(color: style.ink),
                  ),
                ),
              ],
            ),
    );

    return Opacity(
      opacity: onPressed == null ? .45 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: radius,
          // الضغط بيغمّق اللمسة بدل ما يعمل موجة رمادية فوق ملء ملوّن.
          splashColor: style.ripple,
          highlightColor: style.ripple,
          child: child,
        ),
      ),
    );
  }

  _ButtonStyle get _style => switch (variant) {
    AppButtonVariant.primary => _ButtonStyle(
      fill: AppSemanticColors.accent,
      ink: AppSemanticColors.textOnAccent,
      ripple: AppSemanticColors.accentPressed.withValues(alpha: .35),
      hasShadow: true,
    ),
    AppButtonVariant.secondary => _ButtonStyle(
      fill: Colors.transparent,
      ink: AppSemanticColors.accent,
      borderColor: AppSemanticColors.accent,
      ripple: AppSemanticColors.accentSoft,
    ),
    // **الملء سطح مرفوع مش `dangerSoft`.**
    //
    // الأحمر على الوردي الفاتح بيدي 4.62:1 وعلى الكارت 5.15:1. الفرق مش
    // كبير، بس ده زرار «إلغاء الحجز» — آخر حاجة العميل بيقراها قبل ما يخسر
    // ميعاده. والحد الأحمر كفاية عشان يقول «ده مش زرار عادي».
    AppButtonVariant.danger => _ButtonStyle(
      fill: AppSemanticColors.surfaceRaised,
      ink: AppSemanticColors.danger,
      borderColor: AppSemanticColors.dangerBorder,
      ripple: AppSemanticColors.dangerSoft,
    ),
    AppButtonVariant.ghost => _ButtonStyle(
      fill: Colors.transparent,
      ink: AppSemanticColors.textSecondary,
      ripple: AppSemanticColors.borderStrong.withValues(alpha: .4),
    ),
  };
}

@immutable
class _ButtonStyle {
  final Color fill;
  final Color ink;
  final Color? borderColor;
  final Color ripple;
  final bool hasShadow;

  const _ButtonStyle({
    required this.fill,
    required this.ink,
    required this.ripple,
    this.borderColor,
    this.hasShadow = false,
  });
}
