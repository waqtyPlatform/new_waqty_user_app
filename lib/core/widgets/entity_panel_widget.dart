import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

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
              //
              // الكيت مالوش `entityGroundsDeep`، فالغسلة بتتولّد من لون
              // واحد عن طريق `AppGradients.wash` — نفس مصدر الضوء الركني
              // اللي كل أسطح الكيت ماشية عليه. **ماتولّدش الغامق بـ
              // `Color.lerp`** — ده لون خام في widget.
              gradient: AppGradients.wash(
                tint.ground,
                AppSemanticColors.surfaceRaised,
              ),
            ),
            child: name.trim().isEmpty
                // اسم فاضي على لوح ١٤٤px: علامة استفهام ضخمة مش تصميم،
                // دي رسالة خطأ. أرضية ملوّنة ساكتة أحسن.
                //
                // الشرط بقى على **الاسم** مش على ناتج `initialOf`: الكيت
                // بيرجّع `'؟'` كبديل مرئي بدل `null`، فالمقارنة القديمة
                // بقت دايمًا `false` والفرع مات في صمت.
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
                      style: AppTextStyles.numeric(
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
