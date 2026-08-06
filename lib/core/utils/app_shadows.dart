import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// نظام الظلال — تلات مستويات، كل واحد طبقتين.
///
/// **ليه طبقتين:** الطبقة الضيقة (blur صغير، بدون إزاحة تقريبًا) بتقرا كتلامس
/// مع السطح. الواسعة (blur كبير، spread سالب) بتقرا كضوء محيط. الجمع ده بالذات
/// هو الفرق بين «ناعم ومرفوع» و«ظل مرمي».
///
/// **ليه لون الحبر مش أسود:** الأسود الصافي على خلفية بيضا بيبان متسخ ورمادي.
/// والظل البارد على صفحة دافية بيعمل نفس الحاجة — عشان كده اللون هو نفس حبر
/// البؤرة `#141314` مش `#0D0D12` الأزرق.
///
/// ## في الوضع الغامق
///
/// الظل على أرضية سودا مش بيرفع حاجة — بيعمل **هالة** حوالين الكارت. العمق
/// هناك بيتقال بفرق إضاءة الأسطح (`page → surfaceRaised → surfaceInk`)، فالألفا
/// بتتضرب في `shadowScale` (٠٫٥٥) وبتنزل لمستوى بيأكّد الحافة من غير ما يبقى
/// فيه دخان تحت كل كارت.
class AppShadows {
  AppShadows._();

  static Color get _ink => AppSemanticColors.palette.shadowInk;

  static double _a(double alpha) =>
      alpha * AppSemanticColors.palette.shadowScale;

  /// مستوى ١ — المحتوى القاعد **على** الصفحة: الكروت والصفوف.
  static List<BoxShadow> get raised => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.03)),
      offset: Offset(0, 1.r),
      blurRadius: 2.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: Offset(0, 4.r),
      blurRadius: 12.r,
      spreadRadius: -2.r,
    ),
  ];

  /// مستوى ٢ — اللي بيطفو **فوق** المحتوى: الـ sheets والفوتر.
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: Offset(0, 2.r),
      blurRadius: 4.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.10)),
      offset: Offset(0, 12.r),
      blurRadius: 28.r,
      spreadRadius: -6.r,
    ),
  ];

  /// نفس المستوى ٢ بس الضوء جاي من تحت — لشريط التبويبات وأي فوتر مثبّت.
  static List<BoxShadow> get floatingUp => [
    BoxShadow(
      color: _ink.withValues(alpha: _a(.05)),
      offset: Offset(0, -1.r),
      blurRadius: 3.r,
    ),
    BoxShadow(
      color: _ink.withValues(alpha: _a(.08)),
      offset: Offset(0, -8.r),
      blurRadius: 24.r,
      spreadRadius: -6.r,
    ),
  ];

  /// ظل أخضر خفيف تحت الزرار الأساسي وزرار «احجز» الوسطاني.
  ///
  /// دي اللمسة الفخمة، **وأول حاجة نشيلها لو بانت نيون على الجهاز.**
  ///
  /// اللون هنا هو اللمسة نفسها مش الحبر، فمابيتضربش في `shadowScale` بالكامل —
  /// في الغامق اللمسة بتفتح، والهالة الخضرا تحت الزرار هي اللي بتقول إنه مرفوع
  /// بدل الظل الأسود اللي مش بيبان.
  static List<BoxShadow> get accent => [
    BoxShadow(
      color: AppSemanticColors.accent.withValues(
        alpha: AppSemanticColors.isDark ? .28 : .20,
      ),
      offset: Offset(0, 6.r),
      blurRadius: 16.r,
      spreadRadius: -4.r,
    ),
  ];
}
