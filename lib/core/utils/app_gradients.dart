import 'package:flutter/widgets.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';

/// التدرّجات — **غسلات ركنية، مش رامبات على السطح كله**.
///
/// القاعدة دي مكتوبة أصلاً في `EntityPanelWidget` والملف ده بيعمّمها:
///
/// > التدرّج الكامل بيقرا «خلفية مولّدة»؛ الغسلة الركنية بتقرا ضوء.
///
/// الفرق مش ذوق. التدرّج من حافة لحافة مالوش مصدر — العين مابتعرفش تفسّره
/// فبتقراه كزخرفة. الغسلة اللي مركزها ركن واحد ليها **مصدر ضوء ضمني**،
/// فالسطح بيقرا كجسم متضوّي مش كصورة خلفية.
///
/// ## ليه ملف مستقل مش ألوان جوه الـ widget
///
/// نفس سبب `AppSemanticColors`: أي `Color(0x…)` أو `Color.lerp` جوه widget
/// بيخرج من نظام الوضعين. كل حاجة هنا مبنية من التوكنز الدلالية، فبتقلب مع
/// الوضع لوحدها زي أي لون تاني في الأبلكيشن.
///
/// ⚠ **التباين متحقّق منه في `test/dark_mode_test.dart`.** أي غسلة بتفتّح
/// سطح شايل نص لازم أفتح نقطة فيها تعدّي AA مع نص السطح — النقطة دي هي
/// اللي بتتحسب في الاختبار، مش لون السطح الأساسي.
class AppGradients {
  AppGradients._();

  /// مكان مصدر الضوء — الركن العلوي **في ناحية النهاية**.
  ///
  /// `AlignmentDirectional` مش `Alignment`: في العربي النص بيبدأ من اليمين،
  /// فالضوء لازم ييجي من الشمال عشان يقع في المساحة الفاضية. لو كان ثابت
  /// كان هيقع فوق أول كلمة في الشريط.
  static const AlignmentDirectional _lightSource = AlignmentDirectional(
    1,
    -1,
  );

  /// شدة التفتيح عند مركز الغسلة.
  ///
  /// ٠٫١٢ رقم صغير عن قصد: الغسلة المفروض **تتحس** مش تتشاف. أي رقم أعلى
  /// وبيبقى فيه بقعة واضحة، والبقعة الواضحة هي بالظبط الشكل اللي بيقرا
  /// «قالب جاهز».
  static const double _lift = 0.12;

  /// غسلة ركنية على أي سطح — الأساس اللي كل حاجة تحت مبنية عليه.
  ///
  /// [surface] لون السطح، و[light] لون الضوء اللي بيتخلط فيه عند الركن.
  static Gradient wash(Color surface, Color light, {double lift = _lift}) {
    return RadialGradient(
      center: _lightSource,
      // أكبر من ١ عشان الغسلة تخرج بره الصندوق — كده أضعف نقطة فيها
      // بتبقى جوه الشاشة بدل ما تخلص عند الحافة وتعمل خط.
      radius: 1.3,
      colors: [Color.lerp(surface, light, lift)!, surface],
      stops: const [0, 0.85],
    );
  }

  /// لوح البؤرة وهو مستني — **الضوء أخضر خفيف على الحبر**.
  ///
  /// الأخضر هنا مش لمسة براند بتنادي على نفسها، هو حرارة: الحبر لوحده
  /// بيقرا رمادي ميت، وخلطة ١٢٪ بتخليه يقرا كأنه متضوّي من نفس عيلة
  /// اللون بتاعت الأبلكيشن.
  static Gradient get ink =>
      wash(AppSemanticColors.surfaceInk, AppSemanticColors.accent);

  /// لوح البؤرة لما الكرسي يجهز — **الضوء بيغمق مش بيفتح**.
  ///
  /// ⚠ عكس [ink] عن قصد. `surfaceAccentDeep` **نفس اللون في الوضعين**
  /// و`textOnAccentMuted` عليه **4.74:1** — يعني هامش ٠٫٢٤ بس فوق AA.
  /// أي تفتيح بياكل الهامش ده ويطيّح أهم شريط في الأبلكيشن. الغسلة
  /// بتغمق ناحية الركن، فالتباين ممكن يزيد بس ومايقلّش أبدًا.
  static Gradient get accentDeep => wash(
    AppSemanticColors.surfaceAccentDeep,
    AppSemanticColors.palette.scrimBase,
    lift: 0.16,
  );

  /// الطبق الدائري بتاع التصنيفات — **مضوّي من فوق**.
  ///
  /// دي الحالة الوحيدة اللي التدرّج فيها خطي مش ركني، لأن الشكل دايرة:
  /// الدايرة المضوّية من فوق بتقرا كقرص محدّب، ودي إشارة «ده جسم بيتداس».
  /// الدايرة المسطّحة بتقرا كخرم في الصفحة.
  static Gradient get plate => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(
        AppSemanticColors.surfaceSunken,
        AppSemanticColors.surfaceRaised,
        0.55,
      )!,
      AppSemanticColors.surfaceSunken,
    ],
  );

  /// الطبق وهو مختار — نفس المحدّب بس على اللمسة الخفيفة.
  static Gradient get plateSelected => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(
        AppSemanticColors.accentSoft,
        AppSemanticColors.accent,
        0.18,
      )!,
      AppSemanticColors.accentSoft,
    ],
  );

  /// هالة اللمسة اللي بتقعد **ورا** المحتوى في أول الصفحة.
  ///
  /// أعلى الشاشة كان فراغ مسطّح: تحية ومدينة على لون الصفحة الصافي.
  /// الهالة بتدّي للصفحة نقطة بداية — من غير ما تحط أي حاجة تتقري فوق
  /// المحتوى ولا تعمل حافة، لأنها بتنتهي عند شفافية صفر.
  static Gradient get pageGlow {
    final accent = AppSemanticColors.accent;
    return RadialGradient(
      center: _lightSource,
      radius: 1.0,
      colors: [
        accent.withValues(alpha: 0.10),
        accent.withValues(alpha: 0),
      ],
    );
  }
}
