import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_shadows.dart';

/// مستوى العمق.
enum AppElevation {
  /// الصفحة نفسها — من غير ظل ولا حدود.
  flat,

  /// محتوى قاعد **على** الصفحة: الكروت والصفوف.
  raised,

  /// بيطفو **فوق** المحتوى: الـ sheets والفوتر.
  floating,

  /// كروم بيترجع لورا — خلفية غاطسة من غير ظل ولا حدود.
  sunken,
}

/// السطح الأساسي في الأبلكيشن.
///
/// ## ليه widget واحد مش ظل بنضيفه في كل كارت
///
/// الكروت كلها كانت مبنية `Material(لون) → InkWell → Container(decoration)`.
/// لو حطينا الظل على الـ `Container` الداخلي، بنبقى بنرسم ظل **جوه** سطح
/// معتم — والترتيب الصح ثابت ومعروف:
///
///   **الظل بره · الـ Material شفاف جوه · الـ InkWell جواه.**
///
/// وبما إن الغلاف `AnimatedContainer`، **أي كارت بيغيّر لونه أو ارتفاعه عند
/// الاختيار بيتحرّك من غير أي كود زيادة** — وده اللي بيحقق «حركة على كل تغيير
/// حالة» من غير ما نعدّل عشرين ملف بالإيد.
///
/// `Clip.hardEdge` مش `antiAlias` — التانية بتكلّف `saveLayer` لكل كارت،
/// وعند استدارة ٢٠ على شاشة 3x مفيش فرق شايفه العين.
class AppSurfaceWidget extends StatelessWidget {
  final Widget child;
  final AppElevation level;

  /// الاستدارة. الافتراضي [AppRadius.m] (كارت — ١٦ من الـ design DNA).
  final double? radius;

  /// لون مخصص. لو `null` بيتحدد من [level].
  final Color? color;

  final EdgeInsetsGeometry? padding;

  /// حد. **متحطّش حد إلا في تلات حالات بس:** حافة فوتر، أو حالة مختارة،
  /// أو مربع صورة بديلة. غير كده الظل بيقوم بالدور.
  final BoxBorder? border;

  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppSurfaceWidget({
    super.key,
    required this.child,
    this.level = AppElevation.raised,
    this.radius,
    this.color,
    this.padding,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = radius ?? AppRadius.m;

    // استدارة صفر معناها مفيش حاجة تتقص — فطبقة الـ `Material` بـ
    // `Clip.hardEdge` بتبقى `saveLayer` فاضية. مع أربعين صف في القايمة
    // دي مش رخيصة.
    if (resolved == 0 && border == null) {
      return AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        width: width,
        height: height,
        color: color ?? _defaultColor,
        child: onTap == null
            ? Padding(padding: padding ?? EdgeInsets.zero, child: child)
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                ),
              ),
      );
    }

    final borderRadius = BorderRadius.circular(resolved.r);

    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.standard,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? _defaultColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: _shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }

  Color get _defaultColor => switch (level) {
    AppElevation.sunken => AppSemanticColors.surfaceSunken,
    _ => AppSemanticColors.surfaceRaised,
  };

  List<BoxShadow>? get _shadow => switch (level) {
    AppElevation.raised => AppShadows.raised,
    AppElevation.floating => AppShadows.floating,
    AppElevation.flat || AppElevation.sunken => null,
  };
}
