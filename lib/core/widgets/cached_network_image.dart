import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// صورة من الشبكة.
///
/// **ملحوظة:** كل `imagePath` في الـ mock فاضي دلوقتي، و`EntityImageWidget`
/// بيقصّر على البديل قبل ما يوصل هنا — فالـ widget ده عمليًا مش بيتنادى.
/// سايبينه لأن الـ API الحقيقي ممكن يبعت لوجوهات للمحلات بعدين.
class CachedNetworkImageWidget extends StatelessWidget {
  final String imgUrl;
  final BorderRadius radius;
  final BoxFit? fit;

  const CachedNetworkImageWidget({
    required this.imgUrl,
    required this.radius,
    this.fit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        fit: fit ?? BoxFit.cover,
        imageUrl: imgUrl,
        placeholder: (context, url) => _loading(),
        errorWidget: (context, url, error) => DecoratedBox(
          decoration: BoxDecoration(
            color: AppSemanticColors.surfaceSunken,
            borderRadius: radius,
          ),
          child: Icon(
            Icons.broken_image_rounded,
            color: AppSemanticColors.textTertiary,
          ),
        ),
      ),
    );
  }

  /// كان shimmer **رمادي غامق على أسود ٦٠٪** — في أبلكيشن كله فاتح.
  /// دلوقتي بيستخدم نفس موجة الـ skeleton في باقي الأبلكيشن.
  Widget _loading() => SkeletonGroupWidget(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.skeletonBase,
        borderRadius: radius,
      ),
      child: const SizedBox.expand(),
    ),
  );
}
