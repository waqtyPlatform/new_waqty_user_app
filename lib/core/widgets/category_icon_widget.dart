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
/// ## اللغة
///
/// كل الملفات في `assets/icons/categories/` ماشية على نفس القواعد:
///
/// - شبكة `24×24` · `fill="none"`
/// - `stroke-width="2"` · `stroke-linecap` و `stroke-linejoin` = `round`
/// - مسار واحد لكل ملف — مفيش مجموعات ولا أقنعة
///
/// اللون بيتحط من برّه بـ[ColorFilter]، فالملف نفسه لونه مالوش لازمة —
/// وعشان كده الأيقونة بتقلب مع الوضع الغامق زي أي توكن تاني.
///
/// ## لما التصنيفات تيجي من السيرفر
///
/// `CategoryUiModel` هياخد `iconUrl` وقتها، و[assetFor] بتبقى الخطة
/// البديلة للأسماء اللي السيرفر مابعتش ليها صورة. لحد ساعتها الربط بالاسم
/// هو المتاح — والاسم بيتغيّر أصعب من الـ uuid في الداتا الوهمية.
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

  /// مسار الرسم المناسب للاسم — و[generic] لأي اسم مش معروف.
  static String assetFor(String name) => switch (name.trim()) {
    'حلاقة رجالي' => 'assets/icons/categories/barber.svg',
    'كوافير حريمي' => 'assets/icons/categories/hair.svg',
    'عناية بالبشرة' => 'assets/icons/categories/skin.svg',
    'مساج واسترخاء' => 'assets/icons/categories/massage.svg',
    'أظافر' => 'assets/icons/categories/nails.svg',
    'عيادات جلدية' => 'assets/icons/categories/clinic.svg',
    _ => 'assets/icons/categories/generic.svg',
  };

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
