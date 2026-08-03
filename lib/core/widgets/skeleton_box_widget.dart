import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// مستطيل shimmer — اللبنة الأساسية لكل الـ skeletons.
///
/// القاعدة: التحميل يبقى **بشكل المحتوى وبمقاسه النهائي**. السبينر في
/// صندوق بيكبر بيخلي الصفحة تنطّ لما الداتا توصل.
///
/// الأساس والإضاءة اتفصلوا: كانوا `#F6F8FA` → `#F8F9FB`، فرق **قيمتين** —
/// يعني الموجة تقريبًا مش باينة والـ skeleton بيقرا كأنه مستطيل ميت.
class SkeletonBoxWidget extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  /// لما الـ skeleton يبقى جوه صف، الـ `Shimmer` لكل مستطيل بيدّي **موجات
  /// مش متزامنة**. خلّيها `false` ولُف الصف كله بـ [SkeletonGroupWidget].
  final bool animate;

  const SkeletonBoxWidget({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.xs,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width?.w ?? double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        color: AppSemanticColors.skeletonBase,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );

    return animate ? SkeletonGroupWidget(child: box) : box;
  }
}

/// موجة shimmer **واحدة** بتعدّي على كل اللي جواها.
///
/// من غيرها كل مستطيل بيعمل موجته لوحده وبتوقيته، والنتيجة وميض عشوائي بدل
/// حركة واحدة ماشية على الكارت.
class SkeletonGroupWidget extends StatelessWidget {
  final Widget child;

  const SkeletonGroupWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppSemanticColors.skeletonBase,
      highlightColor: AppSemanticColors.skeletonHighlight,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}
