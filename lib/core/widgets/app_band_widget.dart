import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';

/// شريط أفقي بيملا العرض كله وبخلفية مملوكة.
///
/// **العنصر الوحيد في الأبلكيشن اللي مالوش استدارة.** وده مقصود: بعد ١٥
/// صندوق مستدير فوق طية الهوم، الحاجة اللي بتكسر الشكل بتاخد الانتباه
/// من غير ما تحتاج لون صارخ ولا حجم أكبر.
///
/// ## مابيحاولش يهرب من هامش الأب
///
/// اللي بينده بيبطّل يلفّه في `Padding`. `HomeScreen` مبني للحالة دي أصلاً:
/// الـ `ListView` مالهوش هامش أفقي، والهامش بيتحط لكل ابن على حدة بـ
/// `_gutter()` — فالشريط ببساطة مابيتلفّش.
///
/// الحيلة البديلة (`Transform.translate` بالسالب أو `OverflowBox`) بتكسر
/// الـ hit-testing وبتتصرف غلط في الـ RTL.
class AppBandWidget extends StatelessWidget {
  final Widget child;

  /// الافتراضي حبر — ده الاستخدام الأساسي.
  final Color? color;

  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppBandWidget({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // `AnimatedContainer` عشان الشريط لما يغيّر لونه (مثلاً من حبر لأخضر
    // لما يبقى دورك) يتحوّل بدل ما ينطّ.
    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      width: double.infinity,
      color: color ?? AppSemanticColors.surfaceInk,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                padding ??
                EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.pageGutter.w,
                  vertical: AppSpacing.s24.h,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}
