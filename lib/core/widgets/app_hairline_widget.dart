import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// خط شعري بسُمك **بكسل فيزيائي واحد**.
///
/// ## ليه مش `1.h`
///
/// `1.h` على جهاز عرضه ٣٧٥ بيطلع ١٫٠٧ بكسل منطقي. فلاتر مابيقدرش يرسم جزء
/// بكسل، فبيوزّع اللون على **بكسلين** بشفافية — والنتيجة خط رمادي مضبّب
/// بدل خط حاد. ودي بالظبط اللي بتخلي الفواصل تبان «رخيصة».
///
/// `1 / devicePixelRatio` بيدّي **بكسل واحد حقيقي** على أي كثافة: ٠٫٣٣ منطقي
/// على 3x، و٠٫٥ على 2x. الخط بيطلع حاد زي خطوط الـ iOS.
///
/// ## ليه مش `Divider`
///
/// `Divider` بيجيب سُمكه من الثيم بس بيحجز `height` أكبر من السُمك (٢٤ افتراضي)
/// — يعني بيضيف مسافة مخفية جوه أي `Column`. هنا المسافة قرار اللي بينده،
/// مش أثر جانبي.
class AppHairlineWidget extends StatelessWidget {
  /// إزاحة من بداية السطر — عشان الفاصل يبدأ من تحت النص مش من حافة الكارت.
  /// `EdgeInsetsDirectional` فبيتقلب لوحده في الـ RTL.
  final double indent;

  final Color? color;

  const AppHairlineWidget({super.key, this.indent = 0, this.color});

  @override
  Widget build(BuildContext context) {
    final onePixel = 1 / MediaQuery.devicePixelRatioOf(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent.w),
      child: SizedBox(
        height: onePixel,
        width: double.infinity,
        child: ColoredBox(color: color ?? AppSemanticColors.border),
      ),
    );
  }
}
