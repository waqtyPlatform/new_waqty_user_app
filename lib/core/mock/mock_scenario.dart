/// MOCK — سيناريوهات مسمّاة للعرض والاختبار.
///
/// ## المشكلة اللي بيحلها
///
/// عشان نوري «العميل وصل الفرع» كان لازم حد يفتح ملف fixtures، يعدّل
/// حالة، ويعمل hot restart. التكلفة دي هي السبب إن جلسة الاختبار بتغطي
/// أربع حالات بدل تمنتاشر، وإن كل عرض على أصحاب القرار بيطلع مختلف.
///
/// وأهم من كده: **بيخلي تقرير الباج قابل للتكرار.** «سيناريو
/// `waitingInBranch`، افتح مواعيدي» ده خطوات إعادة إنتاج. «احجز حاجة
/// واستنى» مش خطوات.
///
/// ## علاقتها بسويتشات `MockConfig`
///
/// **متعامدة عليها مش بديلة ليها.** `delay` و`forceError` و`forceEmpty`
/// بيفضلوا شغالين فوق أي سيناريو — عشان تقدر تشغّل `arrivedInBranch`
/// **مع** شبكة بطيئة. الكود اللي كاتبهم كان فاهم ليه موجودين، فمش
/// بنعيد بناءه.
enum MockScenario {
  // ── بناء الحجز ──────────────────────────────────────────────────────
  /// خدمة واحدة، زيارة واحدة، في المستقبل.
  happyPath,

  /// تلات خدمات ورا بعض في نفس الزيارة — ١٢ قرار جوه «خطوة ٢ من ٣».
  multiServiceOneVisit,

  /// خدمتين في يومين مختلفين — «حجز واحد، رحلتين».
  multiVisitTwoDays,

  /// زيارتين في نفس اليوم — بيشغّل منطق الدمج/الفصل.
  multiVisitSameDay,

  /// محل بفرعين بمواعيد مختلفة.
  twoBranches,

  /// نفس المحل بفرعين — بس المرة دي **الأسعار والطاقم مختلفين**.
  ///
  /// مش تكرار لـ[twoBranches]: ده بيسأل «العميل واخد باله هو حاجز في أنهي
  /// فرع؟»، ودي بتسأل «واخد باله إن اللي قدامه اتغيّر لما غيّره؟» — سؤالين
  /// مختلفين وكل واحد بيتجاب في جلسة لوحده.
  twoBranchesDifferentPricing,

  /// اليوم المختار مقفول — مفيش مواعيد خالص.
  branchClosedToday,

  /// الميعاد بدأ خلاص فالإلغاء اتقفل — الحالة اللي النص بيتعرض فيها.
  cancelWindowClosed,

  /// عميل قديم عنده ٤٠ حجز — بيشغّل الترقيم.
  manyBookings,

  // ── الرحلة جوه الفرع ────────────────────────────────────────────────
  /// العميل وصل ومستني ينده عليه.
  arrivedInBranch,

  /// في الطابور.
  waitingInBranch,

  /// الخدمة شغالة دلوقتي.
  inService,

  // ── التعافي ─────────────────────────────────────────────────────────
  /// الميعاد راح وإحنا بنأكد — خطّاف الـ `:15`.
  slotLostAtConfirm,

  /// الفرع عرض ميعاد والحجز المؤقت ٥ دقايق شغّال.
  waitlistOffered,

  /// الحجز المؤقت عدّى.
  waitlistExpired,

  // ── النهايات ────────────────────────────────────────────────────────
  /// تلات خدمات مكتملة، ولا واحدة اتقيّمت.
  completedUnrated,

  /// واحدة منشورة وواحدة تحت المراجعة.
  completedPartiallyRated,

  /// حجز ملغي بسبب مكتوب.
  cancelledBooking,

  /// العميل ما حضرش.
  noShow,

  // ── الفلوس ──────────────────────────────────────────────────────────
  /// خصم مجموعة عملاء — «كان ٢٥٠ · بقى ٢٠٠».
  discountedCustomer,

  // ── حالات النظام ────────────────────────────────────────────────────
  networkError,
  emptyState,
  slowNetwork;

  /// سطر بيقول السيناريو ده بيوري إيه — بيتعرض في مبدّل السيناريوهات.
  String get title => switch (this) {
    MockScenario.happyPath => 'حجز عادي',
    MockScenario.multiServiceOneVisit => 'تلات خدمات · زيارة واحدة',
    MockScenario.multiVisitTwoDays => 'زيارتين · يومين',
    MockScenario.multiVisitSameDay => 'زيارتين · نفس اليوم',
    MockScenario.twoBranches => 'محل بفرعين',
    MockScenario.twoBranchesDifferentPricing => 'فرعين بأسعار وطاقم مختلفين',
    MockScenario.branchClosedToday => 'الفرع مقفول',
    MockScenario.cancelWindowClosed => 'الميعاد بدأ — الإلغاء مقفول',
    MockScenario.manyBookings => 'عميل بـ40 حجز',
    MockScenario.arrivedInBranch => 'وصل الفرع',
    MockScenario.waitingInBranch => 'في الانتظار',
    MockScenario.inService => 'في الخدمة',
    MockScenario.slotLostAtConfirm => 'الميعاد راح وإحنا بنأكد',
    MockScenario.waitlistOffered => 'عرض بعدّاد 5 دقايق',
    MockScenario.waitlistExpired => 'الحجز المؤقت عدّى',
    MockScenario.completedUnrated => 'مكتمل · من غير تقييم',
    MockScenario.completedPartiallyRated => 'مكتمل · تقييم جزئي',
    MockScenario.cancelledBooking => 'ملغي',
    MockScenario.noShow => 'لم يحضر',
    MockScenario.discountedCustomer => 'عميل عليه خصم',
    MockScenario.networkError => 'خطأ شبكة',
    MockScenario.emptyState => 'القوايم فاضية',
    MockScenario.slowNetwork => 'شبكة بطيئة',
  };

  /// **السؤال اللي السيناريو ده بيجاوبه في جلسة الاختبار.**
  ///
  /// ده مش وصف — ده الغرض. سيناريو مالوش سؤال يبقى مالوش لزمة.
  String get question => switch (this) {
    MockScenario.happyPath => 'الفلو الأساسي واضح؟',
    MockScenario.multiServiceOneVisit => 'السلة بتستحمل 12 قرار؟',
    MockScenario.multiVisitTwoDays => 'الناس فاهمة «حجز واحد، رحلتين»؟',
    MockScenario.multiVisitSameDay => 'حد بيلاقي كنترول الدمج ولا بيستخدمه؟',
    MockScenario.twoBranches => 'العميل واخد باله هو حاجز في أنهي فرع؟',
    MockScenario.twoBranchesDifferentPricing =>
      'لما غيّر الفرع، واخد باله إن السعر والأخصائيين اتغيّروا؟',
    MockScenario.branchClosedToday => 'الفرق بين «مقفول» و«محجوز بالكامل» بيوصل؟',
    // من غير `**` — المبدّل بيعرض النص خام، والنجوم بتطلع على الشاشة.
    MockScenario.cancelWindowClosed => 'العميل فاهم ليه مش قادر يلغي؟',
    MockScenario.manyBookings => 'القايمة الطويلة بتفضل قابلة للاستعمال؟',
    MockScenario.arrivedInBranch => '«إنت لسه داخل المحل — ده بيقولك إيه؟»',
    MockScenario.waitingInBranch => 'التقدير بالشخص والوقت بيتصدّق أكتر من رقم الدور؟',
    MockScenario.inService => 'محتاج يبقى فيه أي حاجة هنا أصلاً؟',
    MockScenario.slotLostAtConfirm => 'الفشل بيحس إنه غلطته ولا غلطة الأبلكيشن؟',
    MockScenario.waitlistOffered => '5 دقايق كفاية؟ وبيحاولوا يقبلوا بنفسهم؟',
    MockScenario.waitlistExpired => 'ضياع الميعاد مقبول ولا محبط؟',
    MockScenario.completedUnrated => 'فاهمين إن التقييم لكل خدمة؟',
    MockScenario.completedPartiallyRated => '«قيد المراجعة» بتطمّن ولا بتقلق؟',
    MockScenario.cancelledBooking => 'معرفة السبب بتغيّر رد الفعل؟',
    MockScenario.noShow => 'متوقعين يعملوا إيه من الشاشة دي؟',
    MockScenario.discountedCustomer => 'الخصم بيتلاحظ من غير لابل؟',
    MockScenario.networkError => 'الخطأ متميّز عن الفاضي؟',
    MockScenario.emptyState => 'الفاضي متميّز عن الخطأ؟',
    MockScenario.slowNetwork => 'الـ skeletons بتطمّن ولا بتوتّر؟',
  };

  /// كل المحلات ليها فرعين في السيناريو ده؟
  ///
  /// من غير كده السيناريو بيبقى تعليمة شفهية («افتح صالون كابتن») — اسم في
  /// القايمة مالوش أثر. أي محل التستر يفتحه بيوصله لاختيار الفرع.
  bool get hasTwoBranches =>
      this == MockScenario.twoBranches ||
      this == MockScenario.twoBranchesDifferentPricing;

  /// الحجز الظاهر في السيناريو ده حالته جوه الفرع؟
  bool get isInBranch =>
      this == MockScenario.arrivedInBranch ||
      this == MockScenario.waitingInBranch ||
      this == MockScenario.inService;
}
