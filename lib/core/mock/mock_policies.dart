import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/policy_ui_model.dart';

/// MOCK — يتشال عند نزول BE-B1 (`policies` على payload الفرع).
///
/// السياسات دي **مكتوبة فعلاً** في `Livewire/Settings/Policies.php` ومتخزّنة
/// في `provider_settings`. الناقص هو المورد العام بس. فالنصوص هنا مكتوبة
/// بطول واقعي — مزوّد بيكتب فقرة، مش سطر — عشان الأكورديون والـ`maxLines`
/// يتجرّبوا على الحالة الصعبة مش السهلة.
class MockPolicies {
  MockPolicies._();

  /// الخمس حقول مليانة، ونص الإلغاء والاسترجاع طويل بالقصد.
  static const PolicyUiModel full = PolicyUiModel(
    bookingInstructions:
        'تعالى قبل ميعادك بـ10 دقايق عشان نجهّزك. لو معاك حد مستنيك، فيه '
        'مكان قعدة في الاستقبال.',
    cancellationPolicy:
        'تقدر تلغي مجانًا لحد 4 ساعات قبل الميعاد. بعد كده بيتخصم 25% من '
        'قيمة الخدمة، لأن الميعاد بيكون اتقفل على أخصائي وماعادش ينفع '
        'يتحجز لحد تاني.',
    refundPolicy:
        'الفلوس بترجع بنفس طريقة الدفع خلال 3 أيام شغل. لو دفعت كاش في '
        'الفرع، الاسترجاع بيبقى كاش من الفرع نفسه.',
    noShowPolicy:
        'لو ما حضرتش من غير إلغاء مرتين ورا بعض، الحجز من التطبيق بيتقفل '
        'ويرجع بالتليفون بس.',
    preVisitInstructions:
        'ياريت تيجي بشعر نضيف ومن غير أي منتجات تصفيف — بيوفّر وقت الغسيل.',
  );

  /// مفيش أي سياسة — الحالة الافتراضية النهاردة لكل الفروع.
  static const PolicyUiModel none = PolicyUiModel.none;

  /// الإلغاء بس — بتختبر إن الأكورديون بيرسم بند واحد من غير ما يبان ناقص.
  static const PolicyUiModel cancellationOnly = PolicyUiModel(
    cancellationPolicy: 'الإلغاء مقفول بعد ما الميعاد يبدأ.',
  );

  /// السياسة المستخدمة في السيناريو الشغّال دلوقتي.
  ///
  /// الافتراضي **[none]** مش [full]: ده اللي السيرفر بيرجّعه فعلاً النهاردة،
  /// فالمراجعة بتشوف الشكل الحقيقي إلا لما حد يطلب العكس صراحة.
  static PolicyUiModel get current => switch (MockConfig.scenario) {
    MockScenario.policiesFull => full,
    MockScenario.cancelWindowClosed => cancellationOnly,
    _ => none,
  };
}
