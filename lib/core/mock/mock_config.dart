import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';

/// MOCK — يتشال كله لما كل الشاشات تتربط بالـ API
///
/// السويتشات دي هي اللي بتخلينا نشوف حالات التحميل والخطأ والفاضي.
/// من غيرها الـ mock بيرجّع نجاح على طول، ويبقى ٣ حالات من ٤ محدش شافها.
class MockConfig {
  MockConfig._();

  /// السيناريو الشغال دلوقتي — بيحدد شكل الـ fixtures.
  ///
  /// **متعامد على السويتشات اللي تحت مش بديل ليها.** تقدر تشغّل
  /// `arrivedInBranch` **مع** `forceError` أو شبكة بطيئة.
  ///
  /// `ValueNotifier` مش حقل عادي عشان المبدّل يقدر يعيد بناء الشجرة
  /// كلها لما السيناريو يتغيّر — الـ cubits بتتعمل مرة واحدة في
  /// `IndexedStack`، فمن غير إعادة بناء التغيير مكانش هيبان غير بعد
  /// hot restart، وده بالظبط اللي بنحاول نخلص منه.
  static final ValueNotifier<MockScenario> scenarioListenable =
      ValueNotifier<MockScenario>(MockScenario.happyPath);

  static MockScenario get scenario => scenarioListenable.value;

  static set scenario(MockScenario value) => scenarioListenable.value = value;

  /// تأخير مصطنع عشان نشوف الـ skeletons. صفر = عرض سريع.
  static Duration delay = const Duration(milliseconds: 600);

  /// خلي كل نداء يرجّع خطأ — عشان نجرّب شاشة الخطأ وزرار إعادة المحاولة.
  static bool forceError = false;

  /// خلي كل نداء يرجّع ليستة فاضية — عشان نجرّب الحالات الفاضية.
  static bool forceEmpty = false;

  /// أيام الأسبوع اللي مالهاش مواعيد (1 = الاثنين ... 7 = الأحد).
  ///
  /// **لازم تطابق `MockProviders._standardHours`.** كارت الفرع بيعلن
  /// المواعيد والمولّد ده بيديها — ولو اختلفوا الـ prototype بيناقض نفسه
  /// وكل جلسة اختبار بتضيّع نتيجة على باج مش حقيقي. كان `[5, 6]` والكارت
  /// بيقول السبت مفتوح ١٠ص–١٠م، فالسبت كان بيبان فاضي من غير سبب.
  ///
  /// الجمعة بس مقفولة — إيقاع طبيعي في مصر، وبيخلي التقويم يبان فيه فراغ
  /// حقيقي بدل ما يبقى كله متاح.
  static List<int> emptySlotsDays = <int>[5];

  /// أقصى مدى للحجز المقدّم بالأيام.
  ///
  /// السيرفر بيسمح للفرع يحدد ده، فـ ٦٠ يوم المكتوبة بالإيد في
  /// `MockSlots` مكانتش بتسمح نجرّب فرع بيقبل حجز أسبوع بس قدام.
  static int maxAdvanceDays = 365;

  /// رسالة الخطأ اللي بتظهر وقت `forceError`.
  static const String errorMessage = 'حصل خطأ، حاول تاني';

  // ── القيم الفعلية ────────────────────────────────────────────────────
  // السيناريو والسويتشات بيتجمعوا هنا. الكود بره لازم يقرا من دول مش من
  // الحقول فوق — عشان `slowNetwork` مثلاً يشتغل من غير ما حد يفتكر
  // يعدّل `delay` بإيده.

  static bool get isErrorForced =>
      forceError || scenario == MockScenario.networkError;

  static bool get isEmptyForced =>
      forceEmpty || scenario == MockScenario.emptyState;

  static Duration get effectiveDelay =>
      scenario == MockScenario.slowNetwork ? const Duration(seconds: 3) : delay;
}
