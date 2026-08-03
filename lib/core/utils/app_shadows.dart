import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

/// نظام الظلال — تلات مستويات، كل واحد طبقتين.
///
/// الأبلكيشن كله كان فيه **ظل واحد** (شريط التبويبات، وبقيمة `blurRadius: 40`
/// غير مُقاسة). وكل السطوح كانت أبيض على `#F6F8FA` — فرق إضاءة ٢٪ — بخط حدود
/// تباينه ٧٪ تقريبًا مش باين على شاشة 3x. ده كان كل نظام العمق.
///
/// **ليه طبقتين:** الطبقة الضيقة (blur صغير، بدون إزاحة تقريبًا) بتقرا كتلامس
/// مع السطح. الواسعة (blur كبير، spread سالب) بتقرا كضوء محيط. الجمع ده بالذات
/// هو الفرق بين «ناعم ومرفوع» و«ظل مرمي».
///
/// **ليه لون الحبر مش أسود:** الأسود الصافي على خلفية بيضا بيبان متسخ ورمادي.
/// والظل البارد على صفحة دافية بيعمل نفس الحاجة — عشان كده اللون هنا هو
/// نفس حبر البؤرة `#141314` مش `#0D0D12` الأزرق.
class AppShadows {
  AppShadows._();

  static const Color _ink = AppColors.inkColor;

  /// مستوى ١ — المحتوى القاعد **على** الصفحة: الكروت والصفوف.
  ///
  /// خفّينا من `.04/.06` لـ `.03/.05` بعد ما الصفحة بقت دافية: دلوقتي فيه
  /// **إشارتين عمق** (فرق الإضاءة + الظل) مكان واحدة، وخلي الاتنين على
  /// قوتهم بيخلي الكارت يبان مضغوط مرتين.
  static List<BoxShadow> get raised => [
    BoxShadow(
      color: _ink.withValues(alpha: .03),
      offset: Offset(0, 1.r),
      blurRadius: 2.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: .05),
      offset: Offset(0, 4.r),
      blurRadius: 12.r,
      spreadRadius: -2.r,
    ),
  ];

  /// مستوى ٢ — اللي بيطفو **فوق** المحتوى: الـ sheets والفوتر.
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: _ink.withValues(alpha: .05),
      offset: Offset(0, 2.r),
      blurRadius: 4.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: .10),
      offset: Offset(0, 12.r),
      blurRadius: 28.r,
      spreadRadius: -6.r,
    ),
  ];

  /// نفس المستوى ٢ بس الضوء جاي من تحت — لشريط التبويبات وأي فوتر مثبّت.
  static List<BoxShadow> get floatingUp => [
    BoxShadow(
      color: _ink.withValues(alpha: .05),
      offset: Offset(0, -1.r),
      blurRadius: 3.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: .08),
      offset: Offset(0, -8.r),
      blurRadius: 24.r,
      spreadRadius: -6.r,
    ),
  ];

  /// ظل أخضر خفيف تحت الزرار الأساسي.
  ///
  /// دي اللمسة الفخمة، **وأول حاجة نشيلها لو بانت نيون على الجهاز.**
  static List<BoxShadow> get accent => [
    BoxShadow(
      color: AppColors.greenColor500.withValues(alpha: .20),
      offset: Offset(0, 6.r),
      blurRadius: 16.r,
      spreadRadius: -4.r,
    ),
  ];
}
