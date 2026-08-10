import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// سلّم المسافات.
///
/// employee-app مالوش سلّم — عنده `verticalSpace(double)` بيقبل أي رقم،
/// والنتيجة **٢٠ قيمة مختلفة** منهم سبعة خارج شبكة الـ 4pt
/// (3 · 7 · 14 · 18 · 22 · 26 · 34).
///
/// السلّم هنا مطلّع من التوزيع الحقيقي: **12 (×١٠٥) · 16 (×٤٤) · 8 (×٤٢) ·
/// 4 (×٢٧)** هما ٨٠٪ من كل المسافات في الأبلكيشن. الخارجين عن الشبكة
/// بيتلموا على أقرب درجة.
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  /// الحد الأدنى لأي هدف لمس — **`.r` في كل مكان مش `.h`**.
  ///
  /// نفس القاعدة لو اتكتبت `.h` بتطلع بمقاس مختلف على شاشة عريضة، فبتبقى
  /// قاعدتين بنفس الاسم.
  static const double touchTarget = 44;

  /// أقصى تكبير للخط بنسمح بيه.
  ///
  /// بيتفرض مرة واحدة في مدخل الأبلكيشن بـ
  /// `MediaQuery.withClampedTextScaling`. **كل ارتفاع ثابت في الكيت محسوب
  /// لحد الرقم ده بس** — لو اتشال، الصفوف بتفيض.
  static const double maxTextScale = 1.3;

  /// ارتفاع بيكبر مع مقياس الخط — **بس في الجزء اللي فيه نص**.
  ///
  /// ده الحل الصح لمشكلة «الصندوق الثابت بيفيض مع تكبير الخط». الحل الغلط
  /// إنك تخلي الصندوق كله يتضاعف: الحشوة والأيقونات مالهاش دعوة بمقياس
  /// الخط، فبتطلع بلاطة فاضية وسط.
  ///
  /// [fixed] الحشوة والأيقونات والمسافات · [text] مجموع ارتفاعات النص عند
  /// مقياس ١٫٠.
  ///
  /// ⚠ **زوّد ١–٢ نقطة على [text].** فلاتر بيقرّب ارتفاع السطر لأعلى وقت
  /// التشكيل، والحسبة الدقيقة بتسيب صفر فراغ فبتفيض عند ١٫٣.
  static double scaledHeight(
    BuildContext context, {
    required double fixed,
    required double text,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return fixed + (text * scale);
  }

  // ── أسماء الأدوار ────────────────────────────────────────────────────
  //
  // القاعدة تبقى مكتوبة، مش محفوظة في دماغ اللي كتبها.
  //
  // ⚠ الأرقام دي **هندسة employee-app مش user-app**: الهامش ١٦ مش ٢٤،
  // وحشوة الكارت ١٢ مش ١٦. الكيت بيقرا أكثف، وده اللي اتطلب.

  /// هامش الصفحة الأفقي.
  static const double pageGutter = s16;

  /// بين قسم وقسم. **مفيش حاجة تانية بتعمل فاصل أقسام.**
  static const double sectionBreak = s24;

  /// بين لابل القسم والمحتوى بتاعه.
  static const double headerToContent = s8;

  /// حشوة الكارت — الدرجة المسيطرة في employee-app (١٠٥ استخدام).
  static const double cardPadding = s12;

  /// كارت فيه محتوى تقيل (تفاصيل، ملخص) — درجة واحدة أوسع.
  static const double cardPaddingLoose = s16;

  static const double listRowGap = s12;
  static const double chipGap = s8;

  /// جوه الكارت — قيمتين بس.
  static const double titleToSubtitle = s4;
  static const double subtitleToMeta = s8;

  /// أسفل أي شاشة بتسكرول — **في التحميل وفي المحمّل بنفس القيمة**.
  static const double screenBottom = s24;

  /// ارتفاع هيدر الشاشة.
  ///
  /// الـ **٩ هيدرز** في employee-app كلهم `SizedBox(height: 48.h)` بدايرة
  /// رجوع `48.r` — الرقم كان متكرر تسع مرات ومالوش اسم.
  static const double headerHeight = 48;

  // ── جاهزات ───────────────────────────────────────────────────────────
  // getters مش const عشان ScreenUtil تكون اتهيّأت وقت الاستدعاء.

  static EdgeInsetsDirectional get page =>
      EdgeInsetsDirectional.symmetric(horizontal: pageGutter.w);

  static EdgeInsetsDirectional get card =>
      EdgeInsetsDirectional.all(cardPadding.r);

  static EdgeInsetsDirectional get cardLoose =>
      EdgeInsetsDirectional.all(cardPaddingLoose.r);
}
