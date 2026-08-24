import 'package:waqty_user_application/core/utils/json_parse.dart';

/// سياسات الفرع — الخمس حقول اللي المزوّد بيملاها ومحدش بيشوفها.
///
/// المزوّد بيكتبهم في `Livewire/Settings/Policies.php` وبيتحفظوا فعلاً في
/// `provider_settings` تحت مفتاح `policies`. بس **مافيش مورد عام بيطلّعهم**:
/// `PublicProviderBranchResource` مابيبعتش ولا واحد فيهم.
///
/// ⚠ **الحقول كلها فاضية لحد ما BE-B1 تنزل.** كل سطح بيستخدمها بيطوي نفسه
/// بالكامل لو الحقل فاضي — **مافيش صندوق فاضي ولا هيدر من غير جسم** في أي
/// شاشة. وده مقصود: السياسة اللي المزوّد ما كتبهاش، التطبيق مايخترعهاش.
///
/// TODO(api): BE-B1 — `policies{booking_instructions, cancellation_policy,
/// refund_policy, no_show_policy, pre_visit_instructions}` على payload الفرع
/// مع fallback لمستوى المزوّد. السياسات **عمليات فرع** فالفرع الأول.
class PolicyUiModel {
  /// «قبل ما تحجز» — تعليمات الحجز نفسه.
  final String bookingInstructions;

  /// سياسة الإلغاء — نافذة الإلغاء وشروطه.
  final String cancellationPolicy;

  /// سياسة الاسترجاع — الفلوس بترجع إمتى وإزاي.
  final String refundPolicy;

  /// سياسة عدم الحضور.
  final String noShowPolicy;

  /// تعليمات قبل الزيارة — بتظهر قبل الميعاد بـ٢٤ ساعة.
  final String preVisitInstructions;

  const PolicyUiModel({
    this.bookingInstructions = '',
    this.cancellationPolicy = '',
    this.refundPolicy = '',
    this.noShowPolicy = '',
    this.preVisitInstructions = '',
  });

  /// فرع من غير أي سياسة — الحالة الافتراضية لحد ما BE-B1 تنزل.
  static const PolicyUiModel none = PolicyUiModel();

  /// هل فيه أي سياسة مكتوبة أصلاً؟ الـwidget الأب بيسأل ده قبل ما يرسم
  /// أي هيدر.
  bool get hasAny =>
      bookingInstructions.isNotEmpty ||
      cancellationPolicy.isNotEmpty ||
      refundPolicy.isNotEmpty ||
      noShowPolicy.isNotEmpty ||
      preVisitInstructions.isNotEmpty;

  /// اللي بيتعرض في أكورديون «قبل ما تحجز» — تعليمات الحجز + الإلغاء.
  bool get hasPreBooking =>
      bookingInstructions.isNotEmpty || cancellationPolicy.isNotEmpty;

  /// `policies` جوه payload الفرع. الشكل المتوقع لما BE-B1 تنزل:
  ///
  /// ```json
  /// {"policies":{"booking_instructions":"…","cancellation_policy":"…",
  ///  "refund_policy":"…","no_show_policy":"…","pre_visit_instructions":"…"}}
  /// ```
  ///
  /// أي مفتاح ناقص بيبقى نص فاضي — مش `null` — عشان كل سطح يسأل
  /// `isNotEmpty` سؤال واحد بس.
  factory PolicyUiModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return none;
    return PolicyUiModel(
      bookingInstructions: JsonParse.stringValue(json['booking_instructions']),
      cancellationPolicy: JsonParse.stringValue(json['cancellation_policy']),
      refundPolicy: JsonParse.stringValue(json['refund_policy']),
      noShowPolicy: JsonParse.stringValue(json['no_show_policy']),
      preVisitInstructions: JsonParse.stringValue(json['pre_visit_instructions']),
    );
  }
}
