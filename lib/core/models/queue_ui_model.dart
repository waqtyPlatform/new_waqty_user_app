/// حالة الدور في الفرع.
enum QueueState {
  /// الحجز مش النهاردة — مفيش طابور أصلاً.
  notToday,

  /// النهاردة بس الفرع لسه ما بدأش يخدم.
  scheduled,

  /// في الطابور وقدامك ناس.
  waiting,

  /// **قرب** — ابدأ تتحرك.
  soon,

  /// دورك دلوقتي.
  yourTurn,

  /// بتتخدم.
  inService,

  /// خلص.
  done,
}

extension QueueStateLabel on QueueState {
  /// اللابل الصغير فوق الرقم.
  ///
  /// **مافيش كلمة بتتكرر بين اللابل والعنوان والسطر التحتاني.** أول نسخة
  /// كانت بتقول «جاري الخدمة» و«جاري» و«جاري الخدمة» في تلات سطور فوق
  /// بعض — الشاشة كانت بتقرا كأنها اتلغبطت.
  String get label => switch (this) {
    QueueState.notToday => 'حجزك',
    QueueState.scheduled => 'موعدك الجاي',
    QueueState.waiting => 'دورك',
    QueueState.soon => 'استعد',
    QueueState.yourTurn => 'الدور',
    QueueState.inService => 'الخدمة',
    QueueState.done => 'الحجز',
  };

  /// الحالات اللي بتستاهل تاخد بؤرة الشاشة.
  bool get isLive =>
      this == QueueState.waiting ||
      this == QueueState.soon ||
      this == QueueState.yourTurn ||
      this == QueueState.inService;

  /// الحالات اللي بتستاهل شريط تنبيه على كل الشاشات.
  bool get needsAttention =>
      this == QueueState.soon || this == QueueState.yourTurn;
}

/// حالة الطابور لحجز واحد.
///
/// ## مفيش «رقم دور» مخزّن في أي حتة
///
/// الباك إند بيسجّل المادة الخام خلاص: `STATUS_ARRIVED` جوه `STATUS_FLOW`،
/// و`session_started_at`، و`employees.availability_status`. فالدور **بيتحسب**
/// من ده:
///
/// - [aheadOfMe] = عدد حجوزات الفرع النهاردة اللي قبلي ولسه شاغلة مكان
/// - [nowServing] = الحجز اللي حالته `in_service`
///
/// عمود `turn_number` جديد معناه حالة تانية محتاجة تتزامن مع الحقيقة —
/// **وبتقع في التزامن** أول ما حد يلغي أو يتأخر.
class QueueUiModel {
  /// ترتيبي في طابور النهاردة (١ = الأول).
  final int myPosition;

  /// اللي بيتخدم دلوقتي. صفر = الفرع لسه ما بدأش.
  final int nowServing;

  /// أقل تقدير للانتظار.
  final Duration estimateLow;

  /// أعلى تقدير.
  final Duration estimateHigh;

  /// وقت آخر تحديث — **بيتعرض للعميل**.
  final DateTime updatedAt;

  final QueueState state;

  const QueueUiModel({
    required this.myPosition,
    required this.nowServing,
    required this.estimateLow,
    required this.estimateHigh,
    required this.updatedAt,
    required this.state,
  });

  /// كام واحد قدامي.
  int get aheadOfMe {
    final ahead = myPosition - nowServing - 1;
    return ahead < 0 ? 0 : ahead;
  }

  /// **مدى مش رقم.**
  ///
  /// «باقي ٢٧ دقيقة» رقم بيكدب: الدور بيتأخر ويتقدّم، وأول ما الرقم
  /// يتكسر مرة العميل مابيثقش تاني في أي رقم بنعرضه. المدى بيقول
  /// «إحنا مش متأكدين» بصراحة، وبيفضل مفيد.
  String get estimateLabel {
    if (state == QueueState.yourTurn) return 'دورك دلوقتي';
    if (state == QueueState.inService) return 'جاري الخدمة';

    final low = estimateLow.inMinutes;
    final high = estimateHigh.inMinutes;
    if (high <= 0) return 'دقايق';
    if (low <= 5) return 'أقل من ${_ar(high)} دقيقة';
    return 'تقريبًا ${_ar(low)}–${_ar(high)} دقيقة';
  }

  /// «آخر تحديث: دلوقتي / من دقيقة / من ٣ دقايق».
  ///
  /// داتا حية ممكن تبقى بايتة **لازم تقول كده**. من غير السطر ده، رقم
  /// عمره خمس دقايق بيبان زي رقم عمره ثانية.
  String freshnessLabel(DateTime now) {
    final minutes = now.difference(updatedAt).inMinutes;
    if (minutes < 1) return 'آخر تحديث: دلوقتي';
    if (minutes == 1) return 'آخر تحديث: من دقيقة';
    if (minutes == 2) return 'آخر تحديث: من دقيقتين';
    return 'آخر تحديث: من ${_ar(minutes)} دقايق';
  }

  static String _ar(int n) =>
      n.toString().split('').map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)]).join();
}
