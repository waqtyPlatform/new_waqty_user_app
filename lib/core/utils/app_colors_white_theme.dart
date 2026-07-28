import 'package:flutter/material.dart';

/// الألوان الخام (السلّم).
///
/// **للأدوار استخدم `AppSemanticColors`** — الملف ده مصدر القيم بس.
class AppColors {
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  ///green
  static const Color greenColor505 = Color(0xffE5FFEE);
  static const Color greenColor300 = Color(0xff00CC77);
  static const Color greenColor500 = Color(0xff009354);

  /// حالة الضغط. مضاف جديد — `500` كان أغمق أخضر في السلّم، فمكانش فيه
  /// لون أغمق منه للضغط، و`400` كان أفتح فبيقرا hover مش press.
  static const Color greenColor600 = Color(0xff007A46);

  // ── الحبر والصفحة ────────────────────────────────────────────────────
  //
  // القيم دي بتتحط في المرحلة دي **من غير ما تتستخدم** عشان تقسيم التوكن
  // يطلع مطابق بالبكسل. اللي بيقلبها هي المرحلة اللي بعدها.

  /// سطح البؤرة. حبر دافي مش أسود أزرق.
  static const Color inkColor = Color(0xff141314);

  /// نص ثانوي على الحبر.
  static const Color inkMutedColor = Color(0xff9A968F);

  /// أبيض مكسور دافي — خلفية الصفحة والنص فوق الحبر.
  static const Color pageColor = Color(0xffFAF9F7);

  /// غاطس دافي — لازم يقعد **تحت** [pageColor] مش فوقه.
  static const Color sunkenColor = Color(0xffF1EFEC);

  ///grey
  static const Color greyColor0 = Color(0xffF8F9FB);
  static const Color greyColor25 = Color(0xffF6F8FA);
  static const Color greyColor50 = Color(0xffECEFF3);
  static const Color greyColor100 = Color(0xffDFE1E6);
  static const Color greyColor200 = Color(0xffC1C7CF);
  static const Color greyColor300 = Color(0xffA4ABB8);
  static const Color greyColor400 = Color(0xff808897);
  static const Color greyColor500 = Color(0xff666D80);
  static const Color greyColor700 = Color(0xff272835);
  static const Color greyColor900 = Color(0xff0D0D12);

  // ── توائم متطابقة بصريًا ─────────────────────────────────────────────
  //
  // التلاتة دول كانوا ألوان مستقلة **بعيدة وحدة واحدة** عن توائمهم:
  //   greyColor1001 = #DFE1E7  مقابل  greyColor100 = #DFE1E6
  //   greyColor4002 = #818898  مقابل  greyColor400 = #808897
  //   greyColor3003 = #A4ACB9  مقابل  greyColor300 = #A4ABB8
  //
  // النتيجة إن شاشات الـ auth كانت ماشية على سلّم رمادي وباقي الأبلكيشن على
  // سلّم تاني، والاتنين مش فارقين عن بعض بالعين.
  //
  // وجّهناهم بدل ما نحذفهم — كده **صفر ملف auth بيتلمس** والمشكلة ماتت.
  static const Color greyColor1001 = greyColor100;
  static const Color greyColor4002 = greyColor400;
  static const Color greyColor3003 = greyColor300;

  /// حبر غامق. مكانه في السلّم كان غلط (متحطّ بين 300 و400 وهو أغمق من 600).
  static const Color greyColor3004 = Color(0xff222222);

  ///blue
  static const Color blueColor0 = Color(0xffEFFBFF);
  static const Color blueColor200 = Color(0xff106A97);

  ///success
  static const Color successColor0 = Color(0xffEFFEFA);
  static const Color successColor200 = Color(0xff287F6E);

  ///warning
  static const Color warningColor0 = Color(0xffFFF6E0);
  static const Color warningColor200 = Color(0xff956321);
  static const Color warningColor3003 = Color(0xffFFB900);

  ///error
  static const Color errorColor0 = Color(0xffFEEFF2);
  static const Color errorColor50 = Color(0xffED8296);
  static const Color errorColor100 = Color(0xffDF1C41);
  static const Color errorColor200 = Color(0xff95122B);

  // ── تدرجات الصورة البديلة ────────────────────────────────────────────
  //
  // معظم المحلات مالهاش لوجو، فالبديل هو **الحالة الشائعة مش الاستثناء**.
  // ولما يبقى رمادي واحد لكل المحلات، اللستة بتقرا كأنها لسه بتحمّل.
  //
  // ٤ تدرجات هادية (تشبّع منخفض عشان ماتنافسش الأخضر). كل تدرج خلفية
  // بدرجة ~٩٦٪ إضاءة وحرف بدرجة ~٤٥٪ — التباين بينهم فوق 4.5:1.
  static const List<Color> placeholderBackgrounds = [
    Color(0xffEDF2F7), // أزرق مغبّر
    Color(0xffF3EFEA), // رملي
    Color(0xffECF1EE), // أخضر مغبّر
    Color(0xffF1EEF4), // بنفسجي مغبّر
  ];

  static const List<Color> placeholderForegrounds = [
    Color(0xff64748B),
    Color(0xff8A7B66),
    Color(0xff6B7F74),
    Color(0xff7C7189),
  ];
}
