import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_semantic_colors.dart';

/// أيقونة من طقم الكيت — **رسم SVG، مش `Icon` من ماتيريال**.
///
/// ## ليه
///
/// أيقونات الكيت خطوط بسمك ٢ على شبكة ٢٤ برؤوس مدوّرة. أيقونات ماتيريال
/// مليانة وبمقاييس تانية، والصف اللي فيه الاتنين بيقرا كأنه من مكتبتين.
/// ده بالظبط السبب اللي خلى أيقونات التصنيفات تتشال من ماتيريال
/// (مكتوب في `category_icon_widget.dart`).
///
/// ## اللون
///
/// `srcIn` بيستبدل لون الرسم كله ويسيب الشفافية — فالخطوط بتاخد اللون
/// اللي بيتبعت والفراغ بينها بيفضل فاضي. الـ`#000000` اللي في الملف
/// **بديل مش لون**.
///
/// ⚠ **مسار غلط مابيرميش استثناء** — `SvgPicture.asset` بترسم مكان فاضي
/// بمقاس الأيقونة وتسكت. عشان كده المسارات كلها ثوابت في [AppIcons]
/// و`icons_test.dart` بيقرا كل ملف من الـbundle فعلاً.
///
/// ⚠ **الأيقونات الاتجاهية مش هنا.** `arrow_back` والشيفرون الأفقي
/// بيعدّوا على ماتيريال عن قصد لأن فلاتر بيقلبهم لوحده في الـRTL —
/// اقرا الملاحظة في [AppIcons].
class AppIconWidget extends StatelessWidget {
  const AppIconWidget(
    this.asset, {
    this.size = 20,
    this.color,
    super.key,
  });

  /// مسار من [AppIcons] — مش نص حر.
  final String asset;

  /// المقاس بيتحسب بـ`.r` عشان الأيقونة تفضل مربعة عند أي مقياس خط.
  final double size;

  /// الافتراضي `textPrimary` — أي لون تاني لازم ييجي من الطبقة الدلالية.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final side = size.r;

    return SvgPicture.asset(
      asset,
      width: side,
      height: side,
      colorFilter: ColorFilter.mode(
        color ?? AppSemanticColors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
