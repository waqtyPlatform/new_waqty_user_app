import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_entity_tint.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// صورة كيان **صغيرة** — من ٣٢ لـ ٨٨.
///
/// ## ليه ده منفصل عن [EntityPanelWidget]
///
/// كان في widget واحد بفلاج `isWide` بيغيّر التركيب **والسلّم والقص** مع
/// بعض — يعني widget-ين في بالطو واحد. وده اللي طلّع حرف ٤٨sp مش موجود
/// في سلّم الخطوط أصلاً، وبقى **أضخم حرف في الأبلكيشن** بالصدفة.
///
/// الحد الفاصل عند ~٦٠px: تحته، الحرف المقصوص اللي خارج من إطاره
/// **مابيقراش كتصميم — بيقرا كباج رسم**. فالصغير بيفضل بسيط: متوسّط،
/// مسطّح، مقصوص من غير حيل.
class EntityAvatarWidget extends StatelessWidget {
  final String name;
  final double size;

  /// نصف المقاس = دايرة.
  final double radius;

  const EntityAvatarWidget({
    super.key,
    required this.name,
    this.size = 88,
    this.radius = AppRadius.xs,
  });

  @override
  Widget build(BuildContext context) {
    final tint = AppEntityTint.of(name);
    final initial = AppEntityTint.initialOf(name);

    return Container(
      height: size.r,
      width: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.ground,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: initial == null
          ? null
          : Text(
              initial,
              style: AppTextStyles.entityGlyph(
                size * 0.42,
                weight: FontWeight.w600,
              ).copyWith(color: tint.ink),
            ),
    );
  }
}
