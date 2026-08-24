import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// نجوم التقييم — عرض وإدخال.
///
/// employee-app بيرسم النجمة بالإيد في `review_card_widget.dart` بـ
/// `Icon(Icons.star)` — رغم إن `flutter_rating: ^2.0.2` في الـ pubspec
/// **ومش مستخدم**. الكيت مابيشحنش الحزمة: خمس أيقونات مش محتاجة تبعية.
///
/// ⚠ **اللون [AppSemanticColors.rating] مش `warning`.** التقييم **رسمة
/// مش نص**، وحدها ٣:١ مش ٤٫٥، والبنّي عليها بيقرا «معطّلة» مش «مقيّمة».
class AppRatingWidget extends StatelessWidget {
  const AppRatingWidget({
    required this.value,
    this.max = 5,
    this.size = 16,
    this.label,
    this.onChanged,
    super.key,
  });

  /// من ٠ لـ [max]. الكسور بتترسم نص نجمة.
  final double value;

  final int max;
  final double size;

  /// نص جنب النجوم — عدد المراجعات مثلًا. **جاهز مش مفتاح.**
  final String? label;

  /// لما يتحط، الودجت بيبقى **إدخال**: كل نجمة هدف لمس بالمقاس الكامل.
  final ValueChanged<int>? onChanged;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= max; i++) _star(i),
        if (label != null) ...[
          SizedBox(width: AppSpacing.s4.w),
          Flexible(
            child: Text(
              label!,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _star(int index) {
    final filled = value >= index;
    final half = !filled && value > index - 1;

    final icon = Icon(
      filled
          ? Icons.star_rounded
          : half
          ? Icons.star_half_rounded
          : Icons.star_outline_rounded,
      size: size.r,
      color: filled || half
          ? AppSemanticColors.rating
          : AppSemanticColors.borderStrong,
    );

    if (!_interactive) return icon;

    // ⚠ في وضع الإدخال كل نجمة لازم تبقى هدف لمس كامل — النجمة ١٦
    // نقطة، والهدف ٤٤.
    return GestureDetector(
      onTap: () => onChanged!(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppSpacing.touchTarget.r,
        height: AppSpacing.touchTarget.r,
        child: Center(child: icon),
      ),
    );
  }
}
