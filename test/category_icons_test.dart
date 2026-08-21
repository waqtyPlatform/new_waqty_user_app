import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/widgets/category_icon_widget.dart';

/// **رسوم التصنيفات.**
///
/// `SvgPicture.asset` بمسار غلط **مابيرميش** — بيرسم مكان فاضي بمقاس
/// الأيقونة ويسكت. يعني حرف ناقص في اسم ملف بيخلي التصنيف يظهر كدايرة
/// فاضية على الجهاز، و`flutter analyze` واختبارات الرسم الاتنين بيعدّوا.
///
/// الاختبار ده هو اللي بيمسك ده: بيقرا كل ملف من الـ bundle فعلاً.
///
/// ## ⚠ والأهم: بيمسك أسماء السيرفر مش الفكسشرز بس
///
/// النسخة القديمة كانت بتختبر `MockCategories` وبس. أول ما الأبلكيشن اتربط
/// بالسيرفر، **الست تصنيفات كلهم وقعوا على الرسم الافتراضي** — والاختبار
/// كان لسه أخضر لأن أسماء الفكسشرز مطابقة للخريطة.
///
/// `serverCategories` تحت **منقولة من نداء حقيقي** على
/// `GET /api/public/categories`. لو الباك-إند ضاف تصنيف جديد، السطر ده هو
/// اللي هيقول إن الأبلكيشن محتاج رسم ليه.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generic = CategoryIconWidget.genericAsset;

  /// أسماء التصنيفات زي ما السيرفر بيبعتها — من `GET /api/public/categories`.
  const List<String> serverCategories = [
    'عيادة طبية',
    'مجمع عيادات',
    'مستشفى',
    'مجمع مستشفيات',
    'حلاق رجالي',
    'كوافير نسائي',
  ];

  group('⚠ تصنيفات السيرفر الحقيقية', () {
    test('كل واحد ليه رسم مخصوص مش الافتراضي', () {
      for (final name in serverCategories) {
        expect(
          CategoryIconWidget.assetFor(name),
          isNot(generic),
          reason:
              '«$name» واقع على الرسم الافتراضي — زوّد كلمة في '
              '`CategoryIconWidget._rules`',
        );
      }
    });

    test('الطبي بياخد رسم طبي مش رسم صالون', () {
      expect(CategoryIconWidget.assetFor('عيادة طبية'), contains('clinic'));
      expect(CategoryIconWidget.assetFor('مجمع عيادات'), contains('clinic'));
      expect(CategoryIconWidget.assetFor('مستشفى'), contains('hospital'));
      expect(
        CategoryIconWidget.assetFor('مجمع مستشفيات'),
        contains('hospital'),
      );
    });

    test('التجميل بياخد رسمه', () {
      expect(CategoryIconWidget.assetFor('حلاق رجالي'), contains('barber'));
      expect(CategoryIconWidget.assetFor('كوافير نسائي'), contains('hair'));
    });
  });

  group('صياغات مختلفة لنفس التصنيف', () {
    test('«حلاق» و«حلاقة» نفس الرسم', () {
      // ده بالظبط اللي كسر الربط: السيرفر «حلاق رجالي» والخريطة
      // «حلاقة رجالي» — حرف واحد.
      expect(
        CategoryIconWidget.assetFor('حلاق رجالي'),
        CategoryIconWidget.assetFor('حلاقة رجالي'),
      );
    });

    test('«نسائي» و«حريمي» نفس الرسم', () {
      expect(
        CategoryIconWidget.assetFor('كوافير نسائي'),
        CategoryIconWidget.assetFor('كوافير حريمي'),
      );
    });

    test('الهمزات مابتفرقش', () {
      expect(
        CategoryIconWidget.assetFor('أظافر'),
        CategoryIconWidget.assetFor('اظافر'),
      );
    });

    test('التاء المربوطة مابتفرقش', () {
      expect(
        CategoryIconWidget.assetFor('عيادة'),
        CategoryIconWidget.assetFor('عياده'),
      );
    });

    test('الألف المقصورة مابتفرقش', () {
      expect(
        CategoryIconWidget.assetFor('مستشفى'),
        CategoryIconWidget.assetFor('مستشفي'),
      );
    });
  });

  test('كل تصنيف في الفكسشرز ليه رسم مخصوص', () {
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
      for (final name in serverCategories) CategoryIconWidget.assetFor(name),
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
    // ⚠ الافتراضي مش فشل — تصنيف جديد من السيرفر بياخد نجمة لحد ما
    // يتعملّه رسم. اللي مايتقبلش هو إن **كل** التصنيفات تاخد نجمة.
    expect(CategoryIconWidget.assetFor('تصنيف جديد من السيرفر'), generic);
    expect(CategoryIconWidget.assetFor(''), generic);
    expect(CategoryIconWidget.assetFor('   '), generic);
  });

  /// المسافات الزيادة بتيجي من السيرفر كتير، والمطابقة على نص خام
  /// بتقع فيها بالسكوت.
  test('المسافات الزيادة مابتكسرش الربط', () {
    expect(
      CategoryIconWidget.assetFor('  حلاقة رجالي  '),
      CategoryIconWidget.assetFor('حلاقة رجالي'),
    );
  });
}
