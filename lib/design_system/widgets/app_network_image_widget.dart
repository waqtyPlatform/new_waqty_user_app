import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import 'app_skeleton_widget.dart';

/// صورة من الشبكة بحالات تحميل وخطأ.
///
/// ## ⚠ من غير `cached_network_image`
///
/// نسخة employee-app بتجرّ الحزمة دي عشان صورة واحدة (`done.png` هي
/// الصورة الوحيدة في الأبلكيشن كله). `Image.network` بتاعة فلاتر عندها
/// كاش في الذاكرة أصلًا، والكاش على الديسك مايستاهلش تبعية في كيت
/// المفروض تبعياته تبقى إثبات إنه مالوش علاقة بتطبيق.
///
/// المتبنّي اللي محتاج كاش على الديسك بيستبدل الملف ده — وهو الملف
/// الوحيد اللي هيحتاج يتغيّر.
class AppNetworkImageWidget extends StatelessWidget {
  const AppNetworkImageWidget({
    required this.url,
    this.width,
    this.height,
    this.radius,
    this.fit = BoxFit.cover,
    this.fallback,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final double? radius;
  final BoxFit fit;

  /// اللي بيتعرض لو المسار فاضي أو التحميل وقع.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular((radius ?? AppRadius.s).r);
    final box = SizedBox(width: width?.w, height: height?.h);

    if (url == null || url!.isEmpty) {
      return ClipRRect(borderRadius: borderRadius, child: _fallback(box));
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url!,
        width: width?.w,
        height: height?.h,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return AppSkeletonGroupWidget(
            child: AppSkeletonBoxWidget(
              width: width,
              height: height ?? 120,
              radius: radius ?? AppRadius.s,
            ),
          );
        },
        errorBuilder: (context, _, _) => _fallback(box),
      ),
    );
  }

  Widget _fallback(Widget box) {
    if (fallback != null) {
      return SizedBox(width: width?.w, height: height?.h, child: fallback);
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: AppSemanticColors.surfaceSunken),
      child: Stack(
        alignment: Alignment.center,
        children: [
          box,
          Icon(
            Icons.image_outlined,
            size: 24.r,
            color: AppSemanticColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
