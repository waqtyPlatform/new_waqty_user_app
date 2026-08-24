import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// حرف المحل **باهت وخارج من الحافة** — طبقة خلفية لأي سطح غامق.
///
/// ## ليه ده مش زخرفة
///
/// الأبلكيشن مالوش صور بقرار موثّق، و`EntityPanelWidget` بيحوّل القرار ده
/// لهوية: **الحرف الأول هو لوجو المحل**. الكروت والهيدرات بتستخدمه كبير
/// وملوّن، والشريط الغامق كان الحتة الوحيدة اللي مابتشاركش في اللغة دي —
/// فكان بيقرا كمستطيل رمادي ممكن يبقى في أي أبلكيشن.
///
/// الحرف هنا بيوصل نفس المعنى بصوت واطي: بيقول «الشريط ده بتاع المحل ده»
/// من غير ما يزاحم الرقم الكبير، ولأنه بيتغيّر بتغيّر الحجز، الشاشة
/// بتبقى **مختلفة لكل عميل** — وده بالظبط اللي القالب المولّد مابيعملوش.
///
/// ## الشفافية
///
/// [alpha] افتراضيه ٠٫٠٥. القياس مش «هل بيبان» — القياس إن النص اللي فوقه
/// مايتأثرش. أي رقم أعلى وبيبدأ ياكل من تباين السطر اللي مارّ عليه، وأقل
/// وبيختفي خالص فبيبقى كود ميت.
///
/// ⚠ **مكانه في الركن مش في النص.** أول نسخة كانت متوسّطة رأسيًا فالحرف
/// كان بيعدّي على الخط الشعري وعلى سطر «المحل · الفرع» — والشكل اللي
/// بيقطع سطرين بيقرا غلطة رسم مش طبقة. دلوقتي بيطلع لفوق وبيخرج من الحافة،
/// فاللي بيبان منه قوس واحد في المنطقة الفاضية جنب الرقم الكبير.
class AppWatermarkGlyphWidget extends StatelessWidget {
  /// الاسم اللي بيتاخد منه أول حرف.
  final String name;

  /// لون الحرف — بيتاخد من طقم السطح اللي تحته، مش من هوية المحل.
  ///
  /// عن قصد: الأرضيات الملوّنة بتاعة `AppEntityTint` معمولة لأسطح فاتحة،
  /// وعلى الحبر بتقرا بقعة متسخة. اللي بيتنقل من الهوية هو **الشكل** بس.
  final Color color;

  final double alpha;

  const AppWatermarkGlyphWidget({
    super.key,
    required this.name,
    required this.color,
    this.alpha = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    // **الشرط على المدخل مش المخرج.**
    //
    // `AppEntityTint.initialOf` بتاع الكيت بيرجّع `String` مش `String?` —
    // الاسم الفاضي بيدي `'؟'` كبديل **مرئي**. وده صح لأفاتار ٤٤ بس غلط
    // هنا: علامة استفهام بعرض ٢٦٠ بكسل ورا الشريط مش تصميم، دي رسالة خطأ.
    if (name.trim().isEmpty) return const SizedBox.shrink();

    final initial = AppEntityTint.initialOf(name);

    return LayoutBuilder(
      builder: (context, constraints) {
        // بالنسبة لارتفاع الشريط مش رقم ثابت — الشريط بيكبر مع مقياس الخط،
        // والحرف الثابت كان هيبقى صغير عند ١٫٣ وكبير عند ١٫٠.
        final glyph = (constraints.maxHeight * 1.15).clamp(80.0, 260.0);

        return IgnorePointer(
          child: OverflowBox(
            // الحرف بيخرج من الحافة — الجزء المقصوص هو اللي بيخلي الشكل
            // يقرا «طبقة تحت» مش «أيقونة متحطّة في الركن».
            //
            // ⚠ الـ `min` صفر مش زيادة: الـ `Positioned.fill` بيدّي قيد
            // **مشدود**، فلو الـ `OverflowBox` غيّر الـ `max` بس بيفضل
            // الـ `min` بعرض الشريط — وأول ما الحرف يطلع أصغر منه بيبقى
            // `min > max` والتخطيط بيرمي.
            minWidth: 0,
            minHeight: 0,
            maxWidth: glyph * 1.4,
            maxHeight: glyph * 1.4,
            alignment: const AlignmentDirectional(1.55, -0.45),
            child: Text(
              initial,
              maxLines: 1,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: AppTextStyles.numeric(
                glyph,
              ).copyWith(color: color.withValues(alpha: alpha)),
            ),
          ),
        );
      },
    );
  }
}
