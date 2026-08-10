import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/widgets/category_icon_widget.dart';

/// **رسوم التصنيفات.**
///
/// `SvgPicture.asset` بمسار غلط **مابيرميش** — بيرسم مكان فاضي بمقاس
/// الأيقونة ويسكت. يعني حرف ناقص في اسم ملف بيخلي التصنيف يظهر كدايرة
/// فاضية على الجهاز، و`flutter analyze` و اختبارات الرسم الاتنين بيعدّوا.
///
/// الاختبار ده هو اللي بيمسك ده: بيقرا كل ملف من الـ bundle فعلاً.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generic = 'assets/icons/categories/generic.svg';

  test('كل تصنيف في الداتا ليه رسم مخصوص مش الافتراضي', () {
    for (final category in MockCategories.all) {
      expect(
        CategoryIconWidget.assetFor(category.name),
        isNot(generic),
        reason: '«${category.name}» واقع على الرسم الافتراضي',
      );
    }
  });

  test('كل الرسوم موجودة في الـ bundle و SVG صالح', () async {
    final paths = <String>{
      generic,
      for (final category in MockCategories.all)
        CategoryIconWidget.assetFor(category.name),
    };

    for (final path in paths) {
      final source = await rootBundle.loadString(path);

      expect(source, contains('<svg'), reason: '$path مش SVG');
      expect(source, contains('</svg>'), reason: '$path ناقص');

      // نفس لغة الرسم بتاعة أيقونات التبويبات — لو حد ضاف ملف مليان
      // أو بسمك تاني، الصف بيبان كأن أيقوناته من مكتبتين.
      expect(
        source,
        contains('viewBox="0 0 24 24"'),
        reason: '$path شبكته غلط',
      );
      expect(source, contains('fill="none"'), reason: '$path مليان مش خطوط');
      expect(source, contains('stroke-width="2"'), reason: '$path سمكه غلط');
      expect(
        source,
        contains('stroke-linecap="round"'),
        reason: '$path رؤوسه مش مدوّرة',
      );
    }
  });

  test('اسم مش معروف بيقع على الرسم الافتراضي', () {
    expect(CategoryIconWidget.assetFor('تصنيف جديد من السيرفر'), generic);
    expect(CategoryIconWidget.assetFor(''), generic);
  });

  /// المسافات الزيادة بتيجي من السيرفر كتير، والـ `switch` على نص خام
  /// بيقع فيها بالسكوت.
  test('المسافات الزيادة مابتكسرش الربط', () {
    expect(
      CategoryIconWidget.assetFor('  حلاقة رجالي  '),
      CategoryIconWidget.assetFor('حلاقة رجالي'),
    );
  });
}
