import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_entity_tint.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// لوح الكيان **الكبير** — كارت الصف الأفقي (١٤٤×٨٤) وهيدر صفحة المحل
/// (٣٧٥×٢٣٢).
///
/// ## ده مش بديل — ده التصميم
///
/// الأبلكيشن مالوش صور وده قرار مقصود. فبدل ما نعمل خانة صورة فاضية فيها
/// حرف صغير متوسّط (اللي بيقرا «الصورة ما حمّلتش»)، الحرف بياخد اللوح كله:
/// كبير، مزاح بصريًا، وخارج من إطاره. زي غلاف كتاب.
///
/// **بيملا الأب** — مالوش مقاس خاص بيه. الأب هو اللي بيحدد.
class EntityPanelWidget extends StatelessWidget {
  final String name;

  const EntityPanelWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final tint = AppEntityTint.of(name);
    final initial = AppEntityTint.initialOf(name);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shorter = constraints.biggest.shortestSide;
        final glyph = (shorter * 0.62).clamp(40.0, 168.0);

        return ClipRect(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tint.ground,
              // غسلة في الركن **المقابل** للحرف — مش تدرّج على اللوح كله.
              // التدرّج الكامل بيقرا «خلفية مولّدة»؛ الغسلة الركنية بتقرا ضوء.
              gradient: RadialGradient(
                center: const AlignmentDirectional(1.0, -1.0),
                radius: 1.1,
                colors: [tint.groundDeep, tint.ground],
                stops: const [0, 0.75],
              ),
            ),
            child: initial == null
                // اسم فاضي على لوح ١٤٤px: علامة استفهام ضخمة مش تصميم،
                // دي رسالة خطأ. أرضية ملوّنة ساكتة أحسن.
                ? const SizedBox.expand()
                : Align(
                    // **`AlignmentDirectional` مش `Alignment`.** الإزاحة
                    // الأفقية بتتقلب في الـ RTL — الحرف بيقعد ناحية جهة
                    // القراية ويتقص من عندها.
                    alignment: const AlignmentDirectional(-0.55, 0.28),
                    child: Text(
                      initial,
                      maxLines: 1,
                      // `height: 1` جوه `entityGlyph` + سلوك صريح هنا:
                      // من غيرهم حشوة الصعود والنزول بتاكل ~١٨٪ من الصندوق،
                      // فالـ 0.62 بتبقى كذبة.
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: AppTextStyles.entityGlyph(
                        glyph,
                      ).copyWith(color: tint.ink),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
