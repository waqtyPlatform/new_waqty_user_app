import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_shadows.dart';

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

/// **السطح الأساسي.** كل كارت في الكيت واحد من دول.
///
/// ## الترتيب اللي بيتكرر غلط
///
/// employee-app بيبني الكروت `Container(decoration بالظل) → Material →
/// InkWell`، يعني الظل بيتحط على نفس الصندوق اللي بيقص المحتوى. الترتيب
/// الصح ثابت ومعروف:
///
///   **الظل بره · الـ Material شفاف جوه · الـ InkWell جواه.**
///
/// وبما إن الغلاف `AnimatedContainer`، **أي كارت بيغيّر لونه أو ارتفاعه
/// عند الاختيار بيتحرّك من غير أي كود زيادة**.
///
/// ## ده بيستبدل إيه
///
/// `features/money/shared/widgets/my_earning_card_decoration.dart` (٢٧
/// استخدام) ونسختيه الخاصتين في `biometric_settings_screen.dart:659`
/// و`change_pin_info_card_widget.dart:63`.
///
/// ⚠ الديكوريشن ده كان شايل حد `greyColor100` بألفا `.2` — تباينه على
/// الأبيض **1.02:1**، يعني مش موجود بصريًا. الطبقة الملامسة في
/// [AppShadows.raised] بتقوم بدوره.
///
/// `Clip.hardEdge` مش `antiAlias` — التانية بتكلّف `saveLayer` لكل كارت،
/// وعند استدارة ١٠ على شاشة 3x مفيش فرق شايفه العين.
class AppSurfaceWidget extends StatelessWidget {
  const AppSurfaceWidget({
    required this.child,
    this.level = AppElevation.raised,
    this.radius,
    this.color,
    this.padding,
    this.border,
    this.onTap,
    this.width,
    this.height,
    super.key,
  });

  final Widget child;
  final AppElevation level;

  /// الافتراضي [AppRadius.s] — **١٠، استدارة الكارت في employee-app**
  /// (٧٩ استخدام، نص كل استدارة في الأبلكيشن).
  final double? radius;

  /// لون مخصص. لو `null` بيتحدد من [level].
  final Color? color;

  final EdgeInsetsGeometry? padding;

  /// ⚠ **متحطّش حد إلا في تلات حالات:** حافة فوتر، أو حالة مختارة، أو
  /// مربع صورة بديلة. غير كده الظل بيقوم بالدور.
  final BoxBorder? border;

  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final resolved = radius ?? AppRadius.s;

    // استدارة صفر معناها مفيش حاجة تتقص — فطبقة الـ `Material` بـ
    // `Clip.hardEdge` بتبقى `saveLayer` فاضية. مع أربعين صف في القايمة
    // دي مش رخيصة.
    if (resolved == 0 && border == null) {
      return _sized(
        AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.standard,
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
        ),
      );
    }

    final borderRadius = BorderRadius.circular(
      resolved == AppRadius.pill ? resolved : resolved.r,
    );

    return _sized(
      AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.standard,
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
      ),
    );
  }

  /// ⚠ **المقاس بره الـ `AnimatedContainer` بقصد.**
  ///
  /// لو الـ `width`/`height` اتحطوا **جوه** الـ `AnimatedContainer`، أي
  /// تغيير في الارتفاع بيتحرّك على مدى [AppMotion.base] — **والمحتوى
  /// جواه بيبقى بمقاسه الجديد من أول إطار**. النتيجة فيض مؤقت طول
  /// الحركة، وده بيحصل فعلاً لما مقياس الخط يتغيّر أو لما عنوان فرعي
  /// يظهر.
  ///
  /// المقاس **layout** والدهان **paint**. اللي بيتحرّك هو التاني بس.
  /// (`row_height_test.dart` مسك ده: فيض ١٠ بكسل عند الانتقال لمقياس ١٫٣.)
  Widget _sized(Widget child) => width == null && height == null
      ? child
      : SizedBox(width: width, height: height, child: child);

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
