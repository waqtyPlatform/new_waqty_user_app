import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// اتجاه السهم بالنسبة لاتجاه القراءة، مش بالنسبة للشاشة.
enum ChevronDirection {
  /// «كمّل / ادخل» — بيشاور لبرّه في اتجاه القراءة.
  /// عربي: شمال · إنجليزي: يمين
  forward,

  /// «ارجع» — عكس اتجاه القراءة.
  back,
}

/// سهم بيتقلب لوحده مع اتجاه اللغة.
///
/// **مهم:** `chevron_left` و `chevron_right` معرّفين في فلاتر بـ
/// `matchTextDirection: true` — يعني فلاتر بيقلبهم لوحده في RTL.
/// فإحنا **مابنقلبش بإيدينا**، بس بنسمّي الأيقونة بمعناها في اتجاه
/// القراءة العادي (يسار←يمين) ونسيب فلاتر يعكسها.
///
/// الباج اللي كان موجود إن الكود القديم كتب `chevron_left` وهو قاصد
/// «كمّل بالعربي» — وفلاتر عكسها فبقت بتشاور ناحية اليمين، عكس المطلوب.
/// ولو قلبناها إحنا كمان بتتقلب مرتين وترجع غلط تاني.
class DirectionalChevronWidget extends StatelessWidget {
  final ChevronDirection direction;
  final double size;
  final Color? color;

  const DirectionalChevronWidget({
    super.key,
    this.direction = ChevronDirection.forward,
    this.size = 20,
    this.color,
  });

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
