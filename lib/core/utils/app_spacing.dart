import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// سلّم المسافات.
///
/// قبل كده كل موضع كان بيكتب رقمه بإيده، والنتيجة إن ٣٣٪ من المسافات الرأسية
/// و٤٢٪ من الأفقية كانت خارج أي شبكة (٢/٥/٦/١٠/١٤). وأكبر مسافة في الأبلكيشن
/// كانت ٢٤ — فمكانش فيه حاجة بتقرا كفاصل بين قسم وقسم.
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  /// الحد الأدنى لأي هدف لمس.
  ///
  /// القاعدة دي كانت متكتوبة `44.r` في مكانين و`44.h` في سبعة — يعني نفس
  /// القاعدة بتطلع بمقاسين مختلفين. من هنا ورايح `.r` في كل مكان.
  static const double touchTarget = 44;

  /// أقصى تكبير للخط بنسمح بيه.
  ///
  /// بيتفرض مرة واحدة في `my_app.dart`. من غيره الجهاز ممكن يوصّل ٢×
  /// و**كل ارتفاع ثابت في الأبلكيشن بيفيض**.
  static const double maxTextScale = 1.3;

  /// ارتفاع بيكبر مع مقياس الخط — **بس في الجزء اللي فيه نص**.
  ///
  /// ده الحل الصح لمشكلة «الصندوق الثابت بيفيض مع تكبير الخط». الحل
  /// الغلط إنك تخلي الصندوق كله يتضاعف: الحشوة والأيقونات مالهاش دعوة
  /// بمقياس الخط، فبتطلع بلاطة فاضية وسط.
  ///
  /// [fixed] الحشوة والأيقونات والمسافات · [text] مجموع ارتفاعات النص
  /// عند مقياس ١٫٠.
  static double scaledHeight(
    BuildContext context, {
    required double fixed,
    required double text,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return fixed + (text * scale);
  }

  // ── أسماء الأدوار ────────────────────────────────────────────────────
  // القاعدة تبقى مكتوبة، مش محفوظة في دماغ اللي كتبها.

  /// هامش الصفحة الأفقي.
  static const double pageGutter = s16;

  /// بين قسم وقسم. **مفيش حاجة تانية بتعمل فاصل أقسام.**
  ///
  /// طلع من ٣٢ لـ ٤٠ لما لابل القسم صغر من ١٨ لـ ١٢. **لما الخط يبطّل
  /// يشيل الفصل، المسافة لازم تشيله** — لو سبنا ٣٢ مع لابل ١٢، حدود
  /// الأقسام بتختفي والصفحة بترجع عمود واحد.
  static const double sectionBreak = 40;

  /// بين لابل القسم والمحتوى بتاعه. قرّب من ١٢ لـ ٨ عشان اللابل يلزق
  /// بمحتواه — الفصل بقى فوقه مش تحته.
  static const double headerToContent = s8;

  static const double cardPadding = s12;
  static const double cardPaddingLoose = s16;
  static const double listRowGap = s12;
  static const double chipGap = s8;

  /// جوه الكارت — قيمتين بس.
  static const double titleToSubtitle = s4;
  static const double subtitleToMeta = s8;

  /// أسفل أي شاشة بتسكرول — **في التحميل وفي المحمّل بنفس القيمة**.
  /// اختلافهم كان بيخلي اللستة تنطّ ٢٤ بكسل لما الداتا توصل.
  static const double screenBottom = s32;

  // ── جاهزات ───────────────────────────────────────────────────────────
  // getters مش const عشان ScreenUtil تكون اتهيّأت وقت الاستدعاء.

  static EdgeInsetsDirectional get page =>
      EdgeInsetsDirectional.symmetric(horizontal: pageGutter.w);

  static EdgeInsetsDirectional get card =>
      EdgeInsetsDirectional.all(cardPadding.r);

  static EdgeInsetsDirectional get cardLoose =>
      EdgeInsetsDirectional.all(cardPaddingLoose.r);
}
