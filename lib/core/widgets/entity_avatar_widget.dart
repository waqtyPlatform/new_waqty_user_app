import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_entity_tint.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// شكل الأفاتار.
enum AvatarShape {
  /// **بني آدم — دايرة.** من الـ DNA: `Circular avatars, 40-48px for lists,
  /// 56-64px for specialist grids`.
  person,

  /// **محل — مربع مستدير.** الـ DNA بيرسم المحلات كـ `image thumbnails` جوه
  /// كروت، والصورة المربعة بتقرا «ده مكان» مش «ده حد».
  entity,
}

/// صورة كيان **صغيرة** — من ٣٢ لـ ٨٨.
///
/// ## ليه ده منفصل عن `EntityPanelWidget`
///
/// كان في widget واحد بفلاج `isWide` بيغيّر التركيب **والسلّم والقص** مع
/// بعض — يعني widget-ين في بالطو واحد. وده اللي طلّع حرف ٤٨sp مش موجود في
/// سلّم الخطوط أصلاً، وبقى **أضخم حرف في الأبلكيشن** بالصدفة.
///
/// الحد الفاصل عند ~٦٠px: تحته، الحرف المقصوص اللي خارج من إطاره **مابيقراش
/// كتصميم — بيقرا كباج رسم**.
///
/// ## الاستدارة بقت من [shape] مش رقم
///
/// كانت `radius` رقم، وكل موضع كان بيكتب `size / 2` بإيده عشان يعمل دايرة —
/// في خمس أماكن (`28/14` · `36/18` · `40/20` · `32/16` · `72/36`). أول مقاس
/// حد ينساه بيطلّع أفاتار بيضاوي جنب دواير.
class EntityAvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final AvatarShape shape;

  /// حلقة اللمسة حوالين الأفاتار — **للحالة المختارة بس**.
  /// من الـ DNA: `with subtle border on some states`.
  final bool isSelected;

  const EntityAvatarWidget({
    super.key,
    required this.name,
    this.size = 88,
    this.shape = AvatarShape.person,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = AppEntityTint.of(name);
    final initial = AppEntityTint.initialOf(name);

    final borderRadius = switch (shape) {
      AvatarShape.person => BorderRadius.circular(size.r / 2),
      AvatarShape.entity => AppRadius.rXs,
    };

    return Container(
      height: size.r,
      width: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.ground,
        borderRadius: borderRadius,
        border: isSelected
            ? Border.all(color: AppSemanticColors.accent, width: 2.r)
            : null,
      ),
      child: initial == null
          ? null
          : Text(
              initial,
              style: AppTextStyles.entityGlyph(size * 0.42, color: tint.ink),
            ),
    );
  }
}
