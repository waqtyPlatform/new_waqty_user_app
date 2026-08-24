import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';

/// اتجاه السهم **بالنسبة لاتجاه القراءة، مش بالنسبة للشاشة**.
enum ChevronDirection {
  /// «كمّل / ادخل» — بيشاور لبرّه في اتجاه القراءة.
  /// عربي: شمال · إنجليزي: يمين
  forward,

  /// «ارجع» — عكس اتجاه القراءة.
  back,
}

/// سهم بيتقلب لوحده مع اتجاه اللغة.
///
/// ## ⚠ الـ widget ده شغّال لأنه **مش بيعمل حاجة**
///
/// `chevron_left` و`chevron_right` معرّفين في فلاتر بـ
/// `matchTextDirection: true` — يعني **فلاتر بيعكسهم لوحده في الـ RTL**.
/// فإحنا بنسمّي الأيقونة بمعناها في اتجاه القراءة العادي (يسار←يمين)
/// وبنسيبها.
///
/// اللي بيقلبها بإيده بيقلبها **مرتين** وبترجع غلط. وده الباج اللي الـ
/// widget ده اتعمل عشانه: زرار «رجوع» بـ`arrow_forward` بيشاور **شمال**
/// في العربي، ومعناه ساعتها «كمّل».
class DirectionalChevronWidget extends StatelessWidget {
  const DirectionalChevronWidget({
    this.direction = ChevronDirection.forward,
    this.size = 20,
    this.color,
    super.key,
  });

  final ChevronDirection direction;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      direction == ChevronDirection.forward
          ? Icons.chevron_right_rounded
          : Icons.chevron_left_rounded,
      size: size.r,
      color: color ?? AppSemanticColors.textTertiary,
    );
  }
}
