import 'package:flutter/widgets.dart';

import 'app_semantic_colors.dart';

/// التدرّجات — **غسلات ركنية، مش رامبات**.
///
/// الرامب اللي بيمشي من حافة لحافة مالوش **مصدر ضوء**، فالعين بتقراه
/// زخرفة. الغسلة الركنية بتقرا «فيه نور جاي من هنا»، وده بيدي السطح جسم
/// من غير ما يلفت النظر لنفسه.
///
/// employee-app عنده ٦ تدرّجات كلهم inline، وواحد منهم
/// (`estimated_pay_card_widget.dart`) مكتوب بـ `Alignment` العادي —
/// **مابيتقلبش في RTL**. كلهم هنا `AlignmentDirectional`.
class AppGradients {
  AppGradients._();

  /// مصدر الضوء — الركن **العلوي في اتجاه القراءة**. بيتقلب مع اللغة.
  static const AlignmentGeometry _lightSource = AlignmentDirectional(1, -1);

  /// قد إيه الركن بيتنوّر. أكتر من كده بيبان تدرّج مقصود.
  static const double _lift = 0.12;

  /// البدائي — سطح متنوّر من ركن.
  ///
  /// [surface] لون السطح · [light] اللي بينوّره · [lift] قد إيه.
  static Gradient wash(Color surface, Color light, {double lift = _lift}) =>
      RadialGradient(
        center: _lightSource,
        radius: 1.3,
        colors: [Color.lerp(surface, light, lift)!, surface],
        stops: const [0, 0.85],
      );

  /// لوح الحبر — البؤرة الغامقة، متنوّرة بأخضر خفيف.
  static Gradient get ink =>
      wash(AppSemanticColors.surfaceInk, AppSemanticColors.accent);

  /// **الشريط الأخضر** — التدرّج الوحيد اللي الهوية بتملكه فعلًا.
  ///
  /// employee-app بيرسمه `#009354 → #007341` في تلات مواضع (كارت الأرباح
  /// المتوقّعة، هيرو قسيمة الراتب، هيدر البروفايل) و**التلاتة شايلين نص
  /// أبيض**. الطرف الفاتح `#009354` بيدي **3.96:1** مع الأبيض — راسب.
  ///
  /// فالكيت بينقل الشريط لطرف الرامب الغامق: الأساس [surfaceAccentDeep]،
  /// والركن متنوّر باللمسة. أسوأ نقطة توقّف في أسوأ وضع بتدي **5.11:1**
  /// مع [textOnAccentMuted].
  ///
  /// ⚠ **بيفتّح، مش بيغمّق** — وده اختلاف عن user-app اللي غسلته بتغمّق.
  /// السبب رقم: عند user-app النص الثانوي على الأخضر الغامق **4.74:1**،
  /// يعني ٠٫٢٤ فوق AA — أي تفتيح كان بيكسره. هنا الرقم **6.00:1**، يعني
  /// فيه هامش ١٫٥ يسمح بمصدر ضوء حقيقي.
  static Gradient get brandBand =>
      wash(AppSemanticColors.surfaceAccentDeep, AppSemanticColors.accent);

  /// لوح غاطس محدّب — للحقول وأشرطة التبويب.
  ///
  /// خطي رأسي مش غسلة: التحدّب بيتقرا لما النور يجي من فوق على طول العرض،
  /// مش من ركن.
  static Gradient get plate => LinearGradient(
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    colors: [
      Color.lerp(
        AppSemanticColors.surfaceSunken,
        AppSemanticColors.surfaceRaised,
        0.55,
      )!,
      AppSemanticColors.surfaceSunken,
    ],
  );

  /// نفس التحدّب على الحالة المختارة.
  static Gradient get plateSelected => LinearGradient(
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    colors: [
      Color.lerp(
        AppSemanticColors.surfaceAccentSoft,
        AppSemanticColors.surfaceRaised,
        0.55,
      )!,
      AppSemanticColors.surfaceAccentSoft,
    ],
  );

  /// وهج خفيف أعلى الصفحة — بيخلي الشاشة الفاضية مش بلاطة.
  ///
  /// ⚠ **آخر نقطة توقّف شفافة تمامًا.** لو انتهى بلون صلب، بيبان له حافة.
  static Gradient get pageGlow => RadialGradient(
    center: _lightSource,
    radius: 1.1,
    colors: [
      AppSemanticColors.accent.withValues(alpha: .10),
      AppSemanticColors.accent.withValues(alpha: 0),
    ],
    stops: const [0, 1],
  );
}
