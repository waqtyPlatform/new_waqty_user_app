import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';

/// دخول العنصر: **يبان وهو طالع شوية**، بتأخير حسب ترتيبه.
///
/// ## ليه الحركة مش زخرفة هنا
///
/// الرئيسية بتظهر كتلة واحدة: هيدر وبحث وتصنيفات وبؤرة وكروت، كلهم في
/// نفس الإطار. اللي بيحصل إن العين مالهاش نقطة تبدأ منها، فالشاشة بتقرا
/// كصورة واحدة — وده أكتر سبب بيخلي واجهة تحس إنها متولّدة مش متصمّمة.
///
/// التدرّج بيدّي **ترتيب قراية**: البؤرة الأول، بعدها اللي تحتها. تلت
/// ثانية بس، بس العين بتمشي في الطريق ده وبتفضل ماشية فيه بعد ما الحركة
/// تخلص.
///
/// ## بيتنفّذ من غير حالة
///
/// `TweenAnimationBuilder` بيشغّل نفسه مرة واحدة عند أول بناء وخلاص — مفيش
/// `setState` ومفيش `AnimationController` يتعمل له dispose. والتأخير جاي من
/// `Interval` جوه المنحنى مش من مؤقت، فمفيش حاجة تفضل شغّالة بعد ما الشجرة
/// تروح.
///
/// ⚠ **بيتلغي بالكامل لو المستخدم قافل الحركة** من إعدادات الجهاز
/// (`MediaQuery.disableAnimations`). ناس بتتعبها الحركة فعلاً، والـ widget
/// اللي بيتجاهل الإعداد ده بيمنعهم من الشاشة مش بيزوّقهالهم.
class AppRevealWidget extends StatelessWidget {
  /// ترتيب العنصر في الشاشة — بيحدّد تأخيره.
  final int index;

  /// المسافة اللي بيطلعها وهو داخل.
  ///
  /// ١٢ صغيرة عن قصد: الحركة الكبيرة بتلفت الانتباه لنفسها، والمطلوب هنا
  /// إنها **تتحس مش تتشاف** — العنصر يبان كأنه استقر مش كأنه رمى نفسه.
  final double rise;

  final Widget child;

  const AppRevealWidget({
    super.key,
    required this.child,
    this.index = 0,
    this.rise = 12,
  });

  /// أقصى تأخير — بعد كده كل العناصر بتدخل مع بعض.
  ///
  /// من غير السقف ده الشاشة الطويلة بتاخد تانيتين لحد ما آخر عنصر يبان،
  /// واللي بيسحب بسرعة بيشوف كروت بتتولد قدامه.
  static const int _maxSteps = 5;

  /// نصيب كل خطوة من المدة الكلية.
  static const double _stepShare = 0.10;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;

    final step = index.clamp(0, _maxSteps);
    final start = step * _stepShare;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      // المدة بتشمل التأخير — الـ `Interval` بيقسّمها، فكل العناصر
      // بتخلص في نفس اللحظة مهما كان ترتيبها.
      duration:
          AppMotion.entrance +
          Duration(milliseconds: (_maxSteps * _stepShare * 400).round()),
      curve: Interval(start, 1, curve: AppMotion.standard),
      builder: (context, t, child) => Opacity(
        opacity: t,
        // `Transform.translate` مش `Padding`: الإزاحة مابتأثرش على التخطيط،
        // فالعناصر اللي تحت مابتتزحلقش وهي داخلة.
        child: Transform.translate(
          offset: Offset(0, (1 - t) * rise.h),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
