import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';

/// مستطيل skeleton.
///
/// ⚠ **مابيعملش شيمر بنفسه.** لازم يقعد جوه [AppSkeletonGroupWidget].
/// من غير المجموعة كل مستطيل بيعمل موجته لوحده، والكارت اللي فيه خمس
/// مستطيلات بيبقى فيه **خمس موجات مالهاش علاقة ببعض** — وده بيقرا
/// «الشاشة اتكسرت» مش «الداتا جاية».
class AppSkeletonBoxWidget extends StatelessWidget {
  const AppSkeletonBoxWidget({
    this.width,
    this.height = 12,
    this.radius,
    super.key,
  });

  final double? width;
  final double height;

  /// `null` = pill. شريط الـ skeleton ارتفاعه ١٠–١٦ نقطة، فالـ pill
  /// عليه بيقرا «سطر نص» — والاستدارة الصغيرة بتقرا «مربع ناقص».
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height.h,
      decoration: BoxDecoration(
        color: AppSemanticColors.skeletonBase,
        borderRadius: radius == null
            ? AppRadius.rPill
            : BorderRadius.circular(radius!.r),
      ),
    );
  }
}

/// دايرة skeleton — للأفاتار.
class AppSkeletonCircleWidget extends StatelessWidget {
  const AppSkeletonCircleWidget({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: AppSemanticColors.skeletonBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// غلاف الشيمر — **موجة واحدة لكل مجموعة**.
///
/// ⚠ الألوان بتتقرا من التوكنز، فالوضع الغامق بياخد وميض **لطيف**:
/// الفرق بين الأرضية والموجة أقل من ١٫٥:١ بقصد. الوميض الأبيض على كارت
/// أسود ستروب مش تحميل، و`dark_mode_test.dart` بيقفل ده.
class AppSkeletonGroupWidget extends StatelessWidget {
  const AppSkeletonGroupWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ⚠ الحركة دي بتلفّ للأبد — `pumpAndSettle` في الاختبارات بيعلّق
    // عليها. اختبارات الكيت بتستخدم `pump(Duration)` بدلها.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return Shimmer.fromColors(
      baseColor: AppSemanticColors.skeletonBase,
      highlightColor: AppSemanticColors.skeletonHighlight,
      period: AppMotion.entrance * 3,
      child: child,
    );
  }
}
