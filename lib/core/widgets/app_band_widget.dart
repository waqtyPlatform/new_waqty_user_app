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

  /// غسلة ركنية فوق [color].
  ///
  /// جاية من [AppGradients] مش مكتوبة في مكان النداء — الشريط ده أكبر سطح
  /// في الأبلكيشن، ولون مكتوب بالإيد عليه بيخرج من نظام الوضعين على طول.
  final Gradient? gradient;

  /// طبقة بترسم **ورا** المحتوى وبتتقص بحدود الشريط.
  ///
  /// موجودة عشان اللي بينده يقدر يحط حاجة تلمس حواف الشريط — الحشوة
  /// بتتطبّق على [child] بس. من غيرها كان لازم اللي بينده يشيل الحشوة
  /// ويعيد تركيبها بنفسه.
  final Widget? backdrop;

  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppBandWidget({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.backdrop,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // `AnimatedContainer` عشان الشريط لما يغيّر لونه (مثلاً من حبر لأخضر
    // لما يبقى دورك) يتحوّل بدل ما ينطّ.
    //
    // اللون جوه الـ `decoration` مش في `color:` — الاتنين مع بعض بيرموا
    // assertion، والتدرّج مالوش مكان غير الـ decoration.
    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? AppSemanticColors.surfaceInk,
        gradient: gradient,
      ),
      // `ClipRect` عشان الـ [backdrop] يقدر يخرج بره الشريط من غير ما
      // يترسم على الصفحة. الـ `Stack` غير مقيّد بالحجم — `Positioned.fill`
      // على الطبقة الخلفية بس، والمحتوى هو اللي بيحدد الارتفاع.
      child: ClipRect(
        child: Stack(
          children: [
            if (backdrop != null) Positioned.fill(child: backdrop!),
            Material(
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
          ],
        ),
      ),
    );
  }
}
