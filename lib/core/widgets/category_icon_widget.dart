import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// أيقونة التصنيف — **رسم مخصوص، مش أيقونة ماتيريال**.
///
/// ## ليه اتشالت أيقونات ماتيريال
///
/// الصف كان بياخد `content_cut` و `spa` و `self_improvement` من ماتيريال.
/// كلها أيقونات صح المعنى، وكلها **بتتشاف في مية تطبيق تاني** — والصف اللي
/// أيقوناته من مكتبة النظام بيقرا «شاشة اتبنت بسرعة»، مهما كان باقي التصميم
/// مظبوط.
///
/// ودي كمان مش من نفس عيلة الرسم بتاعة الأبلكيشن: أيقونات التبويبات
/// (`assets/icons/*.svg`) خطوط بسمك ٢ برؤوس مدوّرة على شبكة ٢٤، وأيقونات
/// ماتيريال المليانة كانت بتكسر ده في نص الرئيسية.
///
/// ## ⚠ ليه الربط بقى بالكلمة مش بالجملة كاملة
///
/// كان `switch` على الاسم **كامل**، والأسماء اللي فيه بتاعة الفكسشرز. أول
/// ما الأبلكيشن اتربط بالسيرفر **كل التصنيفات وقعت على الافتراضي** — وشاشة
/// فيها ست تصنيفات بنفس النجمة بتقرا شاشة مكسورة.
///
/// | السيرفر بيقول | الخريطة كانت فيها | |
/// |---|---|---|
/// | `حلاق رجالي` | `حلاقة رجالي` | حرف واحد |
/// | `كوافير نسائي` | `كوافير حريمي` | كلمة |
/// | `عيادة طبية` | — | مفيش |
/// | `مستشفى` | — | مفيش |
///
/// المطابقة بالكلمة بتلمّ الأربعة: «حلاق» بتطابق «حلاق رجالي» و«حلاقة
/// رجالي». الصياغة بتتغيّر أسهل من الجذر.
///
/// ## ⚠ الترتيب في [_rules] مقصود
///
/// «مجمع عيادات» فيها «عيادات». لو قاعدة عامة زي «مجمع» اتضافت فوقيهم،
/// المجمع الطبي هياخد أيقونة غلط. **الأخص قبل الأعم.**
///
/// ## لما السيرفر يبعت صورة
///
/// `PublicCategoryResource` بيبعت `image_url` وهو `null` في **كل**
/// التصنيفات دلوقتي. أول ما يتملّى، `CategoryUiModel.imagePath` بيتملى
/// معاه والشاشة تقدر تعرض الصورة — والرسوم دي بتبقى الخطة البديلة.
class CategoryIconWidget extends StatelessWidget {
  final String categoryName;
  final double size;
  final Color color;

  const CategoryIconWidget({
    super.key,
    required this.categoryName,
    required this.size,
    required this.color,
  });

  /// كلمة في الاسم ← الرسم بتاعها. **الأخص قبل الأعم.**
  static const List<(String, String)> _rules = [
    // ── طبي ────────────────────────────────────────────────────────────
    ('مستشفيات', 'hospital.svg'),
    ('مستشفى', 'hospital.svg'),
    ('عيادات', 'clinic.svg'),
    ('عيادة', 'clinic.svg'),
    ('طبي', 'clinic.svg'),

    // ── تجميل ──────────────────────────────────────────────────────────
    ('حلاق', 'barber.svg'),
    ('باربر', 'barber.svg'),
    ('كوافير', 'hair.svg'),
    ('شعر', 'hair.svg'),
    ('بشرة', 'skin.svg'),
    ('جلدية', 'skin.svg'),
    ('مساج', 'massage.svg'),
    ('استرخاء', 'massage.svg'),
    ('أظافر', 'nails.svg'),
  ];

  static const String _basePath = 'assets/icons/categories/';

  /// الرسم الافتراضي لأي اسم مش معروف.
  static const String genericAsset = '${_basePath}generic.svg';

  /// مسار الرسم المناسب للاسم — و[genericAsset] لأي اسم مش معروف.
  static String assetFor(String name) {
    final normalized = _normalize(name);
    if (normalized.isEmpty) return genericAsset;

    for (final (keyword, asset) in _rules) {
      if (normalized.contains(_normalize(keyword))) return '$_basePath$asset';
    }

    return genericAsset;
  }

  /// ⚠ **الهمزات والتاء المربوطة والألف المقصورة بتتوحّد.**
  ///
  /// السيرفر بيكتب «عيادة» والقاعدة «عيادات»، و«أظافر» و«اظافر»،
  /// و«مستشفى» و«مستشفي». من غير التوحيد ده كل صيغة محتاجة سطر في
  /// [_rules] — والسطر اللي هينسى هو اللي هيوقع على الافتراضي في صمت.
  static String _normalize(String value) => value
      .trim()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');

  @override
  Widget build(BuildContext context) {
    final side = size.r;

    return SvgPicture.asset(
      assetFor(categoryName),
      width: side,
      height: side,
      // `srcIn` بيستبدل لون الرسم كله ويسيب الشفافية — فالخطوط بتاخد لون
      // اللمسة والفراغ بينها بيفضل فاضي.
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
