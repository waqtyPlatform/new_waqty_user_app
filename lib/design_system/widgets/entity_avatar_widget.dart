import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_entity_tint.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_text_styles.dart';

/// شكل الأفاتار.
enum AvatarShape {
  /// كيان (محل، فرع) — مربع باستدارة.
  entity,

  /// شخص (موظف، عميل) — دايرة.
  person,
}

/// أفاتار بحرف على لون ثابت.
///
/// ⚠ **نسبة الحرف للمقاس مملوكة هنا.** employee-app بيكتبها بالإيد في
/// خمس أماكن بنسب مختلفة، فالأفاتار ٤٠ والأفاتار ٥٦ بيقروا كأنهم من
/// نظامين. النسبة `0.42` ثابتة لكل المقاسات.
class EntityAvatarWidget extends StatelessWidget {
  const EntityAvatarWidget({
    required this.name,
    this.size = 44,
    this.shape = AvatarShape.entity,
    this.imageUrl,
    this.badge,
    super.key,
  });

  /// اسم الكيان — منه بيتحدد اللون والحرف.
  final String name;

  final double size;
  final AvatarShape shape;

  /// لو اتحطت، الصورة بتغطي الحرف. الحرف بيفضل تحتها كبديل.
  final ImageProvider? imageUrl;

  /// شارة صغيرة على الحافة — حالة، عدد.
  final Widget? badge;

  static const double _glyphRatio = 0.42;

  @override
  Widget build(BuildContext context) {
    final tint = AppEntityTint.of(name);
    final radius = shape == AvatarShape.person
        ? AppRadius.rPill
        : BorderRadius.circular((size * 0.28).r);

    final avatar = Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: tint.ground,
        borderRadius: radius,
        image: imageUrl == null
            ? null
            : DecorationImage(image: imageUrl!, fit: BoxFit.cover),
      ),
      child: imageUrl != null
          ? null
          : Text(
              AppEntityTint.initialOf(name),
              style: AppTextStyles.numeric(size * _glyphRatio, color: tint.ink),
              maxLines: 1,
            ),
    );

    if (badge == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        PositionedDirectional(bottom: -2.h, end: -2.w, child: badge!),
      ],
    );
  }
}

/// كومة أفاتارات متراكبة — «٣ موظفين على الحجز ده».
class EntityAvatarStackWidget extends StatelessWidget {
  const EntityAvatarStackWidget({
    required this.names,
    this.size = 32,
    this.max = 3,
    super.key,
  });

  final List<String> names;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final extra = names.length - shown.length;
    final overlap = size * 0.3;

    return SizedBox(
      height: size.r,
      width:
          (size + (shown.length - 1 + (extra > 0 ? 1 : 0)) * (size - overlap))
              .clamp(size, double.infinity)
              .r,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            PositionedDirectional(
              start: (i * (size - overlap)).w,
              child: Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: AppSemanticColors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: EntityAvatarWidget(
                  name: shown[i],
                  size: size,
                  shape: AvatarShape.person,
                ),
              ),
            ),
          if (extra > 0)
            PositionedDirectional(
              start: (shown.length * (size - overlap)).w,
              child: Container(
                width: (size + 4).r,
                height: (size + 4).r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppSemanticColors.surfaceSunken,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppSemanticColors.surfaceRaised,
                    width: 2,
                  ),
                ),
                child: Text(
                  '+$extra',
                  style: AppTextStyles.overline,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
