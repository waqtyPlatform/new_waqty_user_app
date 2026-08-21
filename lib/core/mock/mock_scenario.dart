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

  /// في الطابور — **من غير أي تقدير زمني**.
  ///
  /// ده الشكل اللي السيرفر بيوفّره النهاردة فعلاً: `waiting` موجودة كحالة،
  /// والتوقّع الزمني مالوش عمود ولا حساب خالص. يتشغّل جنب
  /// [waitingInBranch] والفرق بينهم هو **قرار BE-17**: المدى يستاهل
  /// نطلب من الباك إند يبنيه، ولا «لسه مع عميل» لوحدها بتطمّن زيّه؟
  waitingNoEstimate,

  /// الخدمة شغالة دلوقتي.
  inService,

  // ── التعافي ─────────────────────────────────────────────────────────
  /// الميعاد راح وإحنا بنأكد — خطّاف الـ `:15`.
  slotLostAtConfirm,

  /// ميعاد فضي والفرع بيراجع مين ياخده — قبل العرض بخطوة.
  ///
  /// الحالة دي اللي `markAvailabilityForReleasedBooking()` بيطلّعها أول
  /// ما حجز يتلغي. الأبلكيشن كان بيقع بيها على `pending`، فالعميل كان
  /// بيشوف «لما ميعاد يفضى» بعد ما الميعاد فضي.
  waitlistReviewing,

  /// الفرع عرض ميعاد والحجز المؤقت ٥ دقايق شغّال.
  waitlistOffered,

  /// كل حالات القائمة مرة واحدة — لشاشة قايمة الانتظار المستقلة.
  waitlistHistory,

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

  // ── الباقات والمتابعات ──────────────────────────────────────────────
  /// ٤ من ٨ جلسات مستهلكة، وواحدة **محجوزة** لميعاد جاي.
  ///
  /// الجلسة المحجوزة هي كل الفكرة: لو الشريط رسم شريحتين بس، العميلة
  /// بتشوف ٤ متاحين وهي عندها ٣.
  packageMultiSession,

  /// بركة ١٢٠ دقيقة عبر تلات خدمات مسموحة.
  packageUsageBased,

  /// تنتهي بعد ٥ أيام — بتختبر شكل التحذير.
  packageExpiringSoon,

  /// انتهت وفيها جلسات لسه — أصعب حالة.
  ///
  /// العميلة دفعت وضاع منها. الشاشة لازم تقول كده من غير ما تدّعي إن فيه
  /// حاجة تتعمل من التطبيق.
  packageExpired,

  /// بركة واحدة من تلات شراءات بتواريخ انتهاء مختلفة.
  packageMultiplePurchases,

  /// متابعة مجانية · نفس الأخصائي إجباري.
  followUpFree,

  /// متابعة بخصم ٥٠٪ · أي أخصائي.
  followUpDiscounted,

  /// الأخصائي ساب الشغل والمتابعة مربوطة بيه — بتختبر BE-A5.
  followUpEmployeeLeft,

  /// فاضي **عشان الرقم مش مأكّد** — مش عشان مفيش باقات.
  ///
  /// دي أكتر حالة فاضية متوقعة عند الإطلاق، ونصها لازم يبقى مختلف تمامًا
  /// عن [entitlementsEmptyGenuine].
  entitlementsEmptyUnlinked,

  /// فاضي فعلاً — الرقم مأكّد ومفيش باقات.
  entitlementsEmptyGenuine,

  /// الرقم مسجّل على حساب حقيقي تاني — `conflicts > 0`.
  ///
  /// السيرفر بيرمي 422 من `LinkProviderCustomersToPlatformUserAction`
  /// قبل ما يربط أي حاجة. لازم نص لوحده مش «حصل خطأ».
  phoneClaimConflict,

  // ── السياسات ────────────────────────────────────────────────────────
  /// الخمس حقول مليانة ونصهم طويل.
  policiesFull,

  /// كلهم فاضيين — لازم مايظهرش أي صندوق فاضي.
  policiesNone,

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
    MockScenario.waitingNoEstimate => 'في الانتظار · من غير تقدير',
    MockScenario.inService => 'في الخدمة',
    MockScenario.slotLostAtConfirm => 'الميعاد راح وإحنا بنأكد',
    MockScenario.waitlistReviewing => 'ميعاد فضي — الفرع بيراجع',
    MockScenario.waitlistOffered => 'عرض بعدّاد 5 دقايق',
    MockScenario.waitlistHistory => 'قايمة الانتظار · كل الحالات',
    MockScenario.waitlistExpired => 'الحجز المؤقت عدّى',
    MockScenario.completedUnrated => 'مكتمل · من غير تقييم',
    MockScenario.completedPartiallyRated => 'مكتمل · تقييم جزئي',
    MockScenario.cancelledBooking => 'ملغي',
    MockScenario.noShow => 'لم يحضر',
    MockScenario.discountedCustomer => 'عميل عليه خصم',
    MockScenario.packageMultiSession => 'باقة · 4 من 8 جلسات',
    MockScenario.packageUsageBased => 'باقة بالوحدات · 120 دقيقة',
    MockScenario.packageExpiringSoon => 'باقة تنتهي بعد 5 أيام',
    MockScenario.packageExpired => 'باقة انتهت وفيها جلسات',
    MockScenario.packageMultiplePurchases => 'بركة من 3 شراءات',
    MockScenario.followUpFree => 'متابعة مجانية · نفس الأخصائي',
    MockScenario.followUpDiscounted => 'متابعة بخصم 50%',
    MockScenario.followUpEmployeeLeft => 'متابعة · الأخصائي مشي',
    MockScenario.entitlementsEmptyUnlinked => 'فاضي · الرقم مش مأكّد',
    MockScenario.entitlementsEmptyGenuine => 'فاضي · مفيش باقات فعلاً',
    MockScenario.phoneClaimConflict => 'الرقم على حساب تاني',
    MockScenario.policiesFull => 'سياسات كاملة · نص طويل',
    MockScenario.policiesNone => 'مفيش أي سياسة',
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
    MockScenario.branchClosedToday =>
      'الفرق بين «مقفول» و«محجوز بالكامل» بيوصل؟',
    // من غير `**` — المبدّل بيعرض النص خام، والنجوم بتطلع على الشاشة.
    MockScenario.cancelWindowClosed => 'العميل فاهم ليه مش قادر يلغي؟',
    MockScenario.manyBookings => 'القايمة الطويلة بتفضل قابلة للاستعمال؟',
    MockScenario.arrivedInBranch => '«إنت لسه داخل المحل — ده بيقولك إيه؟»',
    MockScenario.waitingInBranch =>
      'التقدير بالشخص والوقت بيتصدّق أكتر من رقم الدور؟',
    MockScenario.waitingNoEstimate =>
      'من غير رقم — الشاشة لسه بتطمّن ولا بقت فاضية؟ (قرار BE-17)',
    MockScenario.inService => 'محتاج يبقى فيه أي حاجة هنا أصلاً؟',
    MockScenario.slotLostAtConfirm =>
      'الفشل بيحس إنه غلطته ولا غلطة الأبلكيشن؟',
    MockScenario.waitlistReviewing =>
      '«فيه ميعاد بس مش مضمون ليك» — بتطمّن ولا بتوتّر؟',
    MockScenario.waitlistOffered => '5 دقايق كفاية؟ وبيحاولوا يقبلوا بنفسهم؟',
    MockScenario.waitlistHistory =>
      'العميل فاهم الفرق بين الحالات؟ وعارف اللي خلص من اللي شغّال؟',
    MockScenario.waitlistExpired => 'ضياع الميعاد مقبول ولا محبط؟',
    MockScenario.completedUnrated => 'فاهمين إن التقييم لكل خدمة؟',
    MockScenario.completedPartiallyRated => '«قيد المراجعة» بتطمّن ولا بتقلق؟',
    MockScenario.cancelledBooking => 'معرفة السبب بتغيّر رد الفعل؟',
    MockScenario.noShow => 'متوقعين يعملوا إيه من الشاشة دي؟',
    MockScenario.discountedCustomer => 'الخصم بيتلاحظ من غير لابل؟',
    MockScenario.packageMultiSession =>
      'العميلة فاهمة إن الجلسة المحجوزة مش متاحة؟',
    MockScenario.packageUsageBased =>
      'الوحدات بتتفهم من غير ما حد يفسّرها؟ وعارفة تصرفها على إيه؟',
    MockScenario.packageExpiringSoon => 'التحذير بيحرّك ولا بيتقري زخرفة؟',
    MockScenario.packageExpired =>
      'ضياع جلسات مدفوعة — الشاشة بتشرح ولا بتلوم؟',
    MockScenario.packageMultiplePurchases =>
      'رقم واحد لبركة من 3 تواريخ انتهاء — بيلخبط ولا بيبسّط؟',
    MockScenario.followUpFree => 'واضح إنها مجانية ومربوطة بأخصائي معيّن؟',
    MockScenario.followUpDiscounted => 'الخصم على المتابعة بيتلاحظ؟',
    MockScenario.followUpEmployeeLeft =>
      'من غير أخصائي — نرخّيها لأي حد ولا نوجّه للفرع؟ (قرار BE-A5)',
    MockScenario.entitlementsEmptyUnlinked =>
      'الفاضي ده بيتقري كدعوة لتأكيد الرقم ولا كنهاية طريق؟',
    MockScenario.entitlementsEmptyGenuine =>
      'متميّز عن [entitlementsEmptyUnlinked] ولا الاتنين شكلهم واحد؟',
    MockScenario.phoneClaimConflict =>
      'العميلة فاهمة إن المشكلة في الرقم مش في الشبكة؟',
    MockScenario.policiesFull => 'النص الطويل بيتقري ولا بيتلف؟',
    MockScenario.policiesNone =>
      'الشاشة من غير سياسات شكلها كامل ولا فيها فراغ مكسور؟',
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
      this == MockScenario.waitingNoEstimate ||
      this == MockScenario.inService;
}
