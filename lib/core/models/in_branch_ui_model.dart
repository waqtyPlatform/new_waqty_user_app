import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// حالة العميل **وهو واقف في الفرع**.
///
/// ## ده بديل `QueueUiModel` — والفرق مش في الشكل
///
/// القديم كان مبني على **رقم دور**: `myPosition` و`nowServing` و«٣ قدامك».
/// ودي استعارة بنك — طابور واحد، شبّاك واحد، اللي جه الأول يتخدم الأول.
/// الصالون مش كده: تلات كراسي ومواعيد محجوزة، وإنت مش مستني **أخصائي**،
/// إنت مستني **أخصائيك**. رقمك مابيتحركش لما حد تاني يخلص عند حد تاني.
///
/// وكمان: الـ endpoint اللي القديم كان مبني عليه
/// (`GET /user/bookings/{uuid}/queue`) **مش موجود في السيرفر خالص**،
/// و`QueueState.soon` و`yourTurn` مكانش ليهم أي مقابل. يعني الشاشة كانت
/// بتعلّم حالات مستحيلة — نفس السبب اللي شال `BookingStatus.pending`.
///
/// ## اللي حقيقي واللي مقترح
///
/// **حقيقي:** [status] — `arrived`/`waiting`/`in_progress` كلهم في
/// `BookingStatus::lifecycleCases()`، والداشبورد بيطلّعهم كل يوم من زرار
/// «وصل». و[employeeName] جاي من عناصر الحجز.
///
/// **PROPOSED — مفيش مقابل في الـ backend:** [estimateLow] و[estimateHigh].
/// السيرفر عنده `arrived_at` و`actual_started_at` وبيحسب منهم
/// `waiting_time_minutes` — بس ده **وقت منقضي مش توقّع**. التقدير اللي
/// قدامك مضروب، والغرض منه نعرف من جلسة الاختبار: هل يستاهل نطلبه؟
class InBranchUiModel {
  final BookingStatus status;

  /// الأخصائي بتاعك — مش «اللي بيتخدم دلوقتي».
  final String employeeName;

  /// PROPOSED — أقل تقدير للانتظار.
  final Duration? estimateLow;

  /// PROPOSED — أعلى تقدير.
  final Duration? estimateHigh;

  /// متوقع تخلص إمتى — للخدمة الشغالة. محسوب من `endAt` بتاع العنصر.
  final DateTime? expectedFinishAt;

  /// وقت آخر تحديث — **بيتعرض للعميل**.
  final DateTime updatedAt;

  const InBranchUiModel({
    required this.status,
    required this.employeeName,
    required this.updatedAt,
    this.estimateLow,
    this.estimateHigh,
    this.expectedFinishAt,
  });

  /// اللابل الصغير فوق العنوان — **من ألفاظ السيرفر**.
  ///
  /// نفس الكلمة اللي الريسيبشن شايفها على الداشبورد، فلما العميل يقول
  /// «مكتوب عندي في الخدمة» الاتنين بيتكلموا نفس اللغة.
  String get label => status.label;

  /// العنوان الكبير — **كلمة أو اتنين، مش جملة**.
  ///
  /// كان `'$employeeName لسه مع عميل'` كله في العنوان. عند ٤٠sp الجملة
  /// دي مابتخشّش في سطر، فكانت بتتقص لـ«أحمد محمود لسه م…» — والقصّة
  /// بتاكل بالظبط الجزء اللي السيناريو معمول عشانه: **العميل مستني
  /// إيه**. سطر ٤٠sp سعته حوالي عشر حروف عربية، وده حجم اسم مش حجم جملة.
  ///
  /// دلوقتي الاسم هو المرساة (أكبر حاجة في الشاشة) و«لسه مع عميل» نزلت
  /// للسطر اللي تحت مع التقدير. المعلومة كلها لسه موجودة — بس كل جزء
  /// في المقاس اللي يشيله.
  String get headline => switch (status) {
    BookingStatus.arrived => 'وصلت',
    // **الشخص، مش الرقم.** «أحمد لسه مع عميل» هي الجملة اللي الريسيبشن
    // بيقولها فعلاً، وبتجاوب على السؤال الحقيقي: أنا مستني مين.
    BookingStatus.waiting => employeeName,
    BookingStatus.inProgress => 'الخدمة بدأت',
    _ => '',
  };

  /// السطر اللي تحت — **مابيكررش أي كلمة من [headline] ولا [label]**.
  String get subline => switch (status) {
    BookingStatus.arrived => 'استنى شوية، هننده عليك',
    // «لسه مع عميل» نزلت من العنوان هنا. الفاصل بيفصل الحقيقة (هو مشغول)
    // عن التقدير (وده تخمين) — العميل يقدر يصدّق الأولى حتى لو التانية
    // طلعت غلط.
    //
    // ⚠ **لما مفيش تقدير، الفاصل بيتشال معاه.** الجزء اللي على الشمال هو
    // الحقيقي، وهو اللي بيفضل. الفاصل مالوش شغل من غير حاجة على ناحيته
    // التانية.
    BookingStatus.waiting =>
      hasLiveEstimate ? 'لسه مع عميل · $estimateLabel' : 'لسه مع عميل',
    BookingStatus.inProgress =>
      expectedFinishAt == null
          ? ''
          : 'متوقع تخلص ${AppFormat.time(expectedFinishAt!)}',
    _ => '',
  };

  /// **مدى مش رقم.**
  ///
  /// «باقي ٢٧ دقيقة» رقم بيكدب: الدور بيتأخر ويتقدّم، وأول ما الرقم
  /// يتكسر مرة العميل مابيثقش تاني في أي رقم بنعرضه. المدى بيقول «إحنا
  /// مش متأكدين» بصراحة، وبيفضل مفيد.
  ///
  /// (القاعدة دي كانت مكتوبة في `QueueUiModel` واتنقلت معاها — هي أحسن
  /// حاجة في الكود القديم.)
  /// ⚠ **بترجّع `''` لما مفيش تقدير — مش كلمة بديلة.**
  ///
  /// كانت بترجّع «دقايق». وده بيقرا زي وحدة قياس اتعلّقت ورا رقم اتمسح:
  /// السطر كان بيطلع **«لسه مع عميل · دقايق»**، فاصل بيوعد بمعلومة
  /// وماوراهوش حاجة. والأسوأ إن `hasLiveEstimate` بترجّع `false` صح في
  /// الحالة دي، فبتخفي لابل «تقدير» — يعني الكلمة الوحيدة اللي كانت
  /// هتقول للعميل إن ده تخمين هي بالظبط اللي بتختفي، والكلام الباقي
  /// بيتقري كأنه حقيقة.
  ///
  /// السلسلة الفاضية بتخلي كل مستهلك **يقرر** يعمل إيه بدل ما ياخد نص
  /// جاهز مالوش معنى. المستهلكين بيسألوا [hasLiveEstimate] الأول.
  String get estimateLabel {
    final low = estimateLow?.inMinutes ?? 0;
    final high = estimateHigh?.inMinutes ?? 0;
    if (high <= 0) return '';
    if (low <= 5) return 'أقل من ${AppFormat.digits(high)} دقيقة';
    return 'تقريبًا ${AppFormat.digits(low)}–${AppFormat.digits(high)} دقيقة';
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
    return 'آخر تحديث: من ${AppFormat.digits(minutes)} دقايق';
  }

  /// فيه رقم حي على الشاشة؟ — لو أيوة، وقت آخر تحديث لازم يبان.
  bool get hasLiveEstimate =>
      status == BookingStatus.waiting && (estimateHigh?.inMinutes ?? 0) > 0;

  /// الحالة دي تستاهل تنبيه يقطع على العميل؟
  ///
  /// «وصلت» و«الكرسي جاهز» أيوة. «مستني» لأ — إلا لما يقرب.
  bool get needsAttention =>
      status == BookingStatus.inProgress ||
      (status == BookingStatus.waiting && (estimateLow?.inMinutes ?? 99) <= 5);

  /// نص التنبيه — بديل الـ push اللي مفيش transport ليه.
  ///
  /// **ده بيتقال مرة واحدة وقت التحوّل**، مش وصف حالة. عشان كده صيغته
  /// أمر: حاجة حصلت دلوقتي وإنت المفروض تتحرّك.
  String get announcement => switch (status) {
    BookingStatus.arrived => 'سجّلنا وصولك — هننده عليك',
    BookingStatus.waiting => 'إنت اللي جاي — استعد',
    BookingStatus.inProgress => 'الكرسي جاهز — اتفضل',
    _ => '',
  };

  /// نص الشريط اللي فوق التبويبات — **قاعد طول ما الحالة قايمة**.
  ///
  /// كان بياخد [announcement] نفسه، والنتيجة تناقض على نفس الشاشة:
  /// البؤرة بتقول «الخدمة بدأت» والشريط تحتها بيقول «الكرسي جاهز —
  /// اتفضل». العميل قاعد على الكرسي والأبلكيشن بينده عليه يدخل.
  ///
  /// السبب إن الاتنين شغلانتين مختلفتين اتصرفوا بنفس الجملة: التنبيه
  /// **لحظة** (بيولع مرة ويطفي)، والشريط **حالة** (بيفضل ظاهر). جملة
  /// أمر تتقال مرة تبقى صح؛ نفس الجملة قاعدة ربع ساعة تبقى كدب.
  String get bannerLabel => switch (status) {
    BookingStatus.arrived => 'مسجّل وصولك — استنى النداء',
    BookingStatus.waiting => 'إنت اللي جاي — استعد',
    BookingStatus.inProgress => 'الخدمة شغالة دلوقتي',
    _ => '',
  };
}
