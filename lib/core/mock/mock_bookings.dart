import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/bookings
///
/// كل المواعيد نسبة للنهاردة عشان القايمة ما تبقاش كلها ماضي بعد أسبوع.
///
/// **العيّنات مقصودة**: فيها حجز بخدمة واحدة، وحجز بتلات خدمات في يوم
/// واحد مع أخصائيين مختلفين، وحجز بزيارتين في يومين، وحجز عليه خصم
/// مجموعة، وحجز مكتمل من غير تقييم وواحد بتقييم جزئي. من غير دول
/// شاشات العرض بتتجرب على الحالة السهلة بس وبتقع أول ما تشوف حجز حقيقي.
class MockBookings {
  MockBookings._();

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// ULID بـ٢٦ حرف من بادئة ثابتة.
  ///
  /// **الأرقام ثابتة بالقصد.** رقم الحجز اللي العميل بيقوله في التليفون
  /// هو أول ٨ حروف من ده، فلو اتولّد عشوائي كل تشغيل، لقطات الشاشة
  /// وتقارير الباجات تبقى مش قابلة للتكرار. و[seed] بيقع جوه أول ٨ حروف
  /// عشان كل حجز يبقى ليه رقم مختلف.
  ///
  /// الحروف من Crockford base32 زي الـ ULID الحقيقي (من غير I و L و O و U).
  static String _ulid(String seed) =>
      '01K1$seed'.padRight(26, '0').substring(0, 26);

  /// اختصار لبناء عنصر بالساعة والدقيقة والمدة.
  ///
  /// [visitUuid] بيحدد العنصر تابع لأنهي رحلة. العناصر اللي في نفس
  /// الرحلة بتاخد نفس القيمة — **مش بالضرورة نفس اليوم يعني نفس الرحلة**.
  /// (`v1`/`v2` مقروءة بالقصد؛ التجميع بيحصل جوه الحجز الواحد بس فمفيش
  /// تصادم بين الحجوزات.)
  static BookingItemUiModel _item({
    required String seed,
    String visitUuid = 'v1',
    required String serviceUuid,
    required String serviceName,
    required String employeeName,
    required int inDays,
    required int atHour,
    int atMinute = 0,
    required int durationMinutes,
    required double price,
    double? originalPrice,
    int? rating,
    RatingStatus ratingStatus = RatingStatus.none,
    String ratingComment = '',
    int? minutesFromNow,
  }) {
    // **إزاحة من دلوقتي، مش من نص الليل.**
    //
    // الحساب العادي بيبني الميعاد من `_today` + ساعات، فحالة زي «الميعاد
    // بدأ من نص ساعة» بتبقى صح أو غلط على حسب الساعة اللي التستر فاتح
    // فيها الأبلكيشن. الإزاحة النسبية بتدّي نفس الحالة في أي وقت.
    final startAt = minutesFromNow != null
        ? DateTime.now().add(Duration(minutes: minutesFromNow))
        : _today.add(
            Duration(days: inDays, hours: atHour, minutes: atMinute),
          );
    return BookingItemUiModel(
      uuid: _ulid(seed),
      visitUuid: visitUuid,
      serviceUuid: serviceUuid,
      serviceName: serviceName,
      employeeName: employeeName,
      startAt: startAt,
      endAt: startAt.add(Duration(minutes: durationMinutes)),
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      ratingStatus: ratingStatus,
      ratingComment: ratingComment,
    );
  }

  /// الحجوزات القادمة — **حسب السيناريو الشغال**.
  ///
  /// السيناريو بيضيّق العيّنة على الحالة اللي بنعرضها بدل ما يخفيها جوه
  /// ليستة. لما مفيش سيناريو مخصوص، بترجّع الليستة الكاملة.
  /// **الملغي بيخرج من «القادمة» على طول.**
  ///
  /// من غير ده الحجز اللي العميل لغاه بيفضل ظاهر تحت القادمة والقايمة
  /// بتكدب عليه. الـ `where` بتشيله والـ `past` تحت بتستقبله.
  static List<BookingUiModel> get upcoming => _applyCancellations(_upcomingSource)
      .where((b) => b.status.isUpcoming)
      .toList();

  static List<BookingUiModel> get _upcomingSource => switch (MockConfig.scenario) {
    MockScenario.arrivedInBranch => <BookingUiModel>[
      _inBranch(BookingStatus.arrived),
    ],
    MockScenario.waitingInBranch => <BookingUiModel>[
      _inBranch(BookingStatus.waiting),
    ],
    // **نفس الحجز بالظبط** — الفرق كله في `MockInBranch` اللي بيرجّع
    // تقدير فاضي. لازم يفضلوا متطابقين عشان جلسة الاختبار تقارن الشاشتين
    // ومفيش متغيّر تاني بيتحرّك معاهم.
    MockScenario.waitingNoEstimate => <BookingUiModel>[
      _inBranch(BookingStatus.waiting),
    ],
    MockScenario.inService => <BookingUiModel>[
      _inBranch(BookingStatus.inProgress),
    ],
    MockScenario.happyPath => <BookingUiModel>[_singleService],
    MockScenario.multiServiceOneVisit => <BookingUiModel>[_threeServices],
    MockScenario.discountedCustomer => <BookingUiModel>[_discounted],
    MockScenario.multiVisitTwoDays => <BookingUiModel>[_twoVisitsTwoDays],
    MockScenario.multiVisitSameDay => <BookingUiModel>[_twoVisitsSameDay],
    MockScenario.manyBookings => _many,
    MockScenario.twoBranches => _sameProviderTwoBranches,
    MockScenario.twoBranchesDifferentPricing => _secondBranchPricing,
    MockScenario.cancelWindowClosed => <BookingUiModel>[_cancelWindowClosed],
    MockScenario.branchClosedToday => <BookingUiModel>[_afterClosedDay],
    // **فاضي بالقصد.** التلاتة دول بيعيشوا في فلو الحجز وفي كارت قائمة
    // الانتظار، مش في ليستة المواعيد. لو حطينا حجوزات فوقهم، التستر
    // بيدوس على السيناريو ويشوف نفس الخمس حجوزات — فيفتكر إن المبدّل
    // مش شغال، وهو أصلاً كان بيفتكر كده.
    MockScenario.slotLostAtConfirm ||
    MockScenario.waitlistOffered ||
    MockScenario.waitlistExpired => const <BookingUiModel>[],
    // النهايات وحالات النظام — الليستة الكاملة، عشان التبويب القادمة
    // مايبقاش فاضي وإحنا بنجرّب حاجة في تبويب تاني.
    _ => _allUpcoming,
  };

  /// **«السابقة» = مكتملة بس.**
  ///
  /// كانت بتجمّع المكتمل والملغي واللي ما حضرش — تلات نهايات مختلفة
  /// عاطفيًا وكل واحدة ليها نية تانية بعدها. ومحدش عايز أرشيف دايم
  /// لإلغاءاته. الملغي واللي ما حضرش بقوا **إشعارات تتقفل** ([notices])
  /// فوق القايمة، والتبويب بقى بيخدم الغرض الوحيد اللي بيستاهل: تكرار
  /// الحجز.
  static List<BookingUiModel> get past =>
      _terminal.where((b) => b.status == BookingStatus.completed).toList();

  /// التبويب اللي الـ cubit طالبه — **بيرجّع القايمة كاملة، مش صفحة**.
  ///
  /// التقطيع بيقعد في `MockSource.fetchPage` عشان حساب الترقيم يفضل في
  /// مكان واحد. وهنا بيقعد **التبويب** عشان الـ cubit مايفضلش بيقرا حالته
  /// من getter بيقرا حقل بيتغيّر تحته وسط الـ `await` — وده كان بيخلي صفحة
  /// من تبويب تتلحق على تبويب تاني.
  static List<BookingUiModel> forTab({required bool upcoming}) =>
      upcoming ? MockBookings.upcoming : past;

  /// النهايات اللي مش مكتملة — بتتعرض كإشعار يتقفل مش كصف دايم.
  static List<BookingUiModel> get notices => _terminal
      .where((b) => b.status != BookingStatus.completed)
      .where((b) => !_dismissedNotices.contains(b.uuid))
      .toList();

  static final Set<String> _dismissedNotices = <String>{};

  static void dismissNotice(String uuid) => _dismissedNotices.add(uuid);

  /// كل اللي خلص — من العيّنات ومن إلغاءات الجلسة.
  static List<BookingUiModel> get _terminal => <BookingUiModel>[
    // اللي اتلغى في الجلسة دي بيظهر فوق — هو أحدث حاجة حصلت.
    ..._applyCancellations(_upcomingSource).where((b) => !b.status.isUpcoming),
    ..._applyCancellations(_pastSource),
  ];

  static List<BookingUiModel> get _pastSource => switch (MockConfig.scenario) {
    MockScenario.completedUnrated => <BookingUiModel>[_completedUnrated],
    MockScenario.completedPartiallyRated => <BookingUiModel>[_partiallyRated],
    MockScenario.cancelledBooking => <BookingUiModel>[_cancelled],
    MockScenario.noShow => <BookingUiModel>[_noShow],
    // عميل قديم — طبيعي يبقى عنده إلغاء ومرة ما حضرش في تاريخه.
    MockScenario.manyBookings => _allPast,
    // **الباقي بياخد المكتمل بس.**
    //
    // `_allPast` فيه ملغي وواحد ما حضرش، والاتنين دول بيطلعوا **إشعارات
    // فوق تبويب القادمة** ([notices]). يعني كل سيناريو، مهما كان بيجرّب
    // إيه، كان بيفتح على نفس الكارتين الحمرا فوق المحتوى الحقيقي —
    // فالشاشة تبان زي بعضها والتستر يفتكر إن السيناريو ما اتغيّرش.
    //
    // النهايات ليها سيناريوهاتها فوق، فمحدش بيخسر تغطية.
    _ => _completedOnly,
  };

  /// ٤٠ حجز — **الشكل اللي الأبلكيشن عمره ما شافه**.
  ///
  /// `GET /user/bookings` مقسّم لصفحات بافتراضي ١٥، فالعميل ده بيوصله
  /// تلات نداءات. من غير العيّنة دي، كود الترقيم مالوش طريق يتنفّذ فيه
  /// أصلاً — أكبر تاب في الـ fixtures التانية فيه خمس حجوزات.
  static List<BookingUiModel> get _many => <BookingUiModel>[
    for (var i = 0; i < 40; i++)
      BookingUiModel(
        uuid: _ulid('P${i.toString().padLeft(3, '0')}'),
        providerUuid: 'prv-1',
        providerName: 'صالون كابتن',
        branchUuid: 'brn-1',
        branchName: 'فرع المعادي',
        branchAddress: '12 شارع 9، المعادي، القاهرة',
        imagePath: '',
        status: BookingStatus.confirmed,
        // **كان `i > 0`** — يعني أول حجز (النهاردة) مقفول الإلغاء، نفس
        // سوء الفهم بتاع «النهاردة = ممنوع». وكان **بيعتمد على الساعة**
        // كمان: الحجز ده ١٠ص، فقبل العاشرة كان مايبدأش والفيكستشر بتقول
        // إنه بدأ.
        //
        // السيناريو ده سؤاله الترقيم، مش الإلغاء. حالة «الإلغاء مقفول»
        // ليها `cancelWindowClosed`.
        canCancel: true,
        items: <BookingItemUiModel>[
          _item(
            seed: 'P${i.toString().padLeft(3, '0')}A',
            serviceUuid: 'srv-1',
            serviceName: 'قص شعر',
            employeeName: 'أحمد محمود',
            // من **بكرة** — عشان مفيش واحد فيهم يكون بدأ وقت التجربة.
            inDays: i + 1,
            atHour: 10 + (i % 8),
            durationMinutes: 45,
            price: 250,
          ),
        ],
      ),
  ];

  /// نفس حجز النهاردة بحالة مختلفة — بيغطي رحلة الفرع كلها.
  ///
  /// التلات حالات دول (`arrived`, `waiting`, `in_progress`) بيطلعوا من
  /// الداشبورد كل يوم من زرار «وصل»، والأبلكيشن عمره ما رسمهم. وهما
  /// موجودين في `BookingStatus::lifecycleCases()` بالحرف.
  static BookingUiModel _inBranch(BookingStatus status) => BookingUiModel(
    uuid: _ulid('M9Q4'),
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
    branchAddress: '12 شارع 9، المعادي، القاهرة',
    imagePath: '',
    status: status,
    canCancel: false,
    items: <BookingItemUiModel>[
      _item(
        seed: 'M9Q4A1',
        serviceUuid: 'srv-1',
        serviceName: 'قص شعر',
        employeeName: 'أحمد محمود',
        inDays: 0,
        atHour: 18,
        durationMinutes: 45,
        price: 250,
      ),
    ],
  );

  /// الليستة الكاملة.
  ///
  /// فيها واحد **النهاردة** بالقصد — بس `canCancel: true`، لأن الميعاد
  /// لسه ما بدأش. حالة «الإلغاء مقفول» ليها سيناريو لوحدها دلوقتي
  /// ([MockScenario.cancelWindowClosed]).
  static List<BookingUiModel> get _allUpcoming => <BookingUiModel>[
    _singleService,
    _threeServices,
    _twoVisitsTwoDays,
    _twoVisitsSameDay,
    _blowDry,
  ];

  static BookingUiModel get _singleService => BookingUiModel(
      uuid: _ulid('M9Q4'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-1',
      branchName: 'فرع المعادي',
      branchAddress: '12 شارع 9، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      // **كان `false` بتعليق «النهاردة — الإلغاء مش مسموح».**
      //
      // الفيكستشر كانت مشفّرة نفس سوء الفهم بتاع النص: القاعدة في
      // `Booking::getCanCancelAttribute()` إن الميعاد **يعدّي**، مش إنه في
      // نفس اليوم. حجز النهاردة ٦م وإنت بتبصّ ٢ظ `can_cancel: true`.
      //
      // ولو سبناها غلط، أول واحد يقرا الداتا هيعيد استنتاج النص الغلط.
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'M9Q4A1',
          serviceUuid: 'srv-1',
          serviceName: 'قص شعر',
          employeeName: 'أحمد محمود',
          inDays: 0,
          atHour: 18,
          durationMinutes: 45,
          price: 250,
        ),
      ],
    );

  /// تلات خدمات · يوم واحد · أخصائيين · وعليه خصم مجموعة.
  ///
  /// ده اللي بيكشف إن الصف المختصر بيقول «و٢ غيرها» وإن الإجمالي مجموع
  /// مش سعر أول خدمة. والخصم عليه عشان معالجة «كان ٢٥٠ · بقى ٢٠٠»
  /// تتجرب على حجز حقيقي مش على رقم واحد.
  static BookingUiModel get _threeServices => BookingUiModel(
      uuid: _ulid('MB2X'),
      providerUuid: 'prv-3',
      providerName: 'باربر شوب الحرية',
      branchUuid: 'brn-prv-3',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مصر الجديدة، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'MB2XA1',
          serviceUuid: 'srv-1',
          serviceName: 'قص شعر',
          employeeName: 'مصطفى خالد',
          inDays: 6,
          atHour: 19,
          durationMinutes: 45,
          price: 200,
          originalPrice: 250,
        ),
        _item(
          seed: 'MB2XA2',
          serviceUuid: 'srv-2',
          serviceName: 'حلاقة ذقن',
          employeeName: 'مصطفى خالد',
          inDays: 6,
          atHour: 19,
          atMinute: 45,
          durationMinutes: 30,
          price: 96,
          originalPrice: 120,
        ),
        _item(
          seed: 'MB2XA3',
          serviceUuid: 'srv-8',
          serviceName: 'غسيل وتصفيف',
          employeeName: 'يوسف عادل',
          inDays: 6,
          atHour: 20,
          atMinute: 15,
          durationMinutes: 20,
          price: 64,
          originalPrice: 80,
        ),
      ],
    );

  /// زيارتين · يومين مختلفين — الحالة اللي التصميم القديم مكانش بيقدر
  /// يعرضها خالص.
  static BookingUiModel get _twoVisitsTwoDays => BookingUiModel(
      uuid: _ulid('MC7R'),
      providerUuid: 'prv-2',
      providerName: 'كوافير نور',
      branchUuid: 'brn-prv-2',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      notes: 'لو ينفع أخصائية ست يبقى أحسن',
      // الزيارتين لسه قدام — الخريطة هنا **صريحة عن قصد** رغم إنها نفس
      // حالة الحجز. الـ fixture ده هو اللي بيثبت إن زيارة متأخرة عن
      // التانية بأسبوع مابتاخدش حالة الفرع بدري.
      visitStatuses: const <String, BookingStatus>{
        'v1': BookingStatus.confirmed,
        'v2': BookingStatus.confirmed,
      },
      items: <BookingItemUiModel>[
        _item(
          seed: 'MC7RA1',
          serviceUuid: 'srv-9',
          serviceName: 'صبغة',
          employeeName: 'سارة عادل',
          inDays: 3,
          atHour: 11,
          durationMinutes: 90,
          price: 600,
        ),
        _item(
          seed: 'MC7RA2',
          visitUuid: 'v2',
          serviceUuid: 'srv-7',
          serviceName: 'بروتين',
          employeeName: 'سارة عادل',
          inDays: 10,
          atHour: 13,
          durationMinutes: 120,
          price: 900,
        ),
      ],
    );

  /// رحلتين في **نفس اليوم** — والزيارة الأولى شغّالة دلوقتي.
  ///
  /// الحالة اللي التجميع باليوم كان بيكسرها: العميل بيجي الصبح ويمشي،
  /// ويرجع بالليل. لو اتعرضوا زيارة واحدة، الفرع بيعمل check-in الساعة
  /// ١٠ والعميل يفضل «واصل» لحد بالليل.
  ///
  /// ⚠ **الـ fixture كان `inDays: 5` فالحالة دي مكانش ينفع تتشاف أصلاً.**
  /// التعليق فوق بيوصف موقف بيحصل **النهاردة** — عميل واقف في الفرع
  /// دلوقتي وليه زيارة تانية بالليل. بميعاد بعد خمس أيام، الحجز كان
  /// بيقعد في «القادمة» ساكت ومحدش شاف الباج اللي السيناريو معمول عشانه.
  ///
  /// دلوقتي: زيارة ١ بدأت من ٢٠ دقيقة و`in_progress`، زيارة ٢ بالليل
  /// و`confirmed`. الحجز الأب `in_progress` زي ما السيرفر هيلمّه. الكود
  /// القديم بيوري «إنت في الفرع» على الاتنين طول اليوم.
  static BookingUiModel get _twoVisitsSameDay => BookingUiModel(
      uuid: _ulid('MDJ5'),
      providerUuid: 'prv-5',
      providerName: 'استوديو جمال',
      branchUuid: 'brn-prv-5',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، المهندسين، القاهرة',
      imagePath: '',
      status: BookingStatus.inProgress,
      // **`true` رغم إن الحجز `in_progress`** — ودي مش سهوة.
      // `Booking::getCanCancelAttribute()` بيبص على **نهاية أي عنصر**:
      // طول ما فيه عنصر لسه ما خلصش، الإلغاء مفتوح. زيارة ٢ بعد ٦ ساعات،
      // فالسيرفر هيقول `can_cancel: true` وإحنا بنعكس السيرفر مش بنحسب.
      canCancel: true,
      visitStatuses: const <String, BookingStatus>{
        'v1': BookingStatus.inProgress,
        'v2': BookingStatus.confirmed,
      },
      items: <BookingItemUiModel>[
        _item(
          seed: 'MDJ5A1',
          serviceUuid: 'srv-9',
          serviceName: 'صبغة',
          employeeName: 'نهى سمير',
          inDays: 0,
          atHour: 0,
          minutesFromNow: -20,
          durationMinutes: 90,
          price: 600,
        ),
        _item(
          seed: 'MDJ5A2',
          visitUuid: 'v2',
          serviceUuid: 'srv-5',
          serviceName: 'حمام كريم',
          employeeName: 'نهى سمير',
          // ٦ ساعات بعد الزيارة الأولى — الفجوة اللي الباج بيعيش فيها.
          inDays: 0,
          atHour: 0,
          minutesFromNow: 360,
          durationMinutes: 30,
          price: 180,
        ),
      ],
    );

  /// كان `pending` — وهي حالة **مالهاش وجود** في السيرفر (`STATUS_PENDING`
  /// = `'confirmed'` و`@deprecated`، وفيه migration نقل كل الصفوف).
  /// الحجز بيتعمل مؤكد على طول.
  static BookingUiModel get _blowDry => BookingUiModel(
      uuid: _ulid('MEW9'),
      providerUuid: 'prv-2',
      providerName: 'كوافير نور',
      branchUuid: 'brn-prv-2',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'MEW9A1',
          serviceUuid: 'srv-6',
          serviceName: 'سشوار',
          employeeName: 'سارة عادل',
          inDays: 4,
          atHour: 11,
          durationMinutes: 45,
          price: 300,
        ),
      ],
    );

  /// **نفس المحل · فرعين مختلفين** — سؤال السيناريو بالحرف.
  ///
  /// الحجزين ورا بعض في القايمة والاسم فوقهم واحد («صالون كابتن»)، فالحاجة
  /// الوحيدة اللي بتفرّقهم هي سطر الفرع. لو التستر خبط في الاتنين، يبقى
  /// السطر ده مش شغال والسؤال اتجاوب.
  ///
  /// الفرعين دول موجودين فعلاً في [MockProviders.branchesOf] لـ`prv-1`،
  /// مش متخترعين هنا — فالضغط على أي واحد بيوصل لفرع حقيقي.
  static List<BookingUiModel> get _sameProviderTwoBranches => <BookingUiModel>[
    BookingUiModel(
      uuid: _ulid('T2B1'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-1',
      branchName: 'فرع المعادي',
      branchAddress: '12 شارع 9، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'T2B1A1',
          serviceUuid: 'srv-1',
          serviceName: 'قص شعر',
          employeeName: 'أحمد محمود',
          inDays: 2,
          atHour: 17,
          durationMinutes: 45,
          price: 250,
        ),
      ],
    ),
    BookingUiModel(
      uuid: _ulid('T2B2'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-2',
      branchName: 'فرع مدينة نصر',
      branchAddress: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'T2B2A1',
          serviceUuid: 'srv-3',
          serviceName: 'قص شعر + ذقن',
          // أخصائي تاني — الفرع التاني فريق تاني، ودي حاجة العميل
          // بيتفاجأ بيها لو ماحدش قالهاله.
          employeeName: 'مصطفى خالد',
          inDays: 3,
          atHour: 20,
          durationMinutes: 60,
          price: 330,
        ),
      ],
    ),
  ];

  /// **الميعاد بدأ من نص ساعة والإلغاء اتقفل.**
  ///
  /// الحالة دي مكانش ليها fixture خالص — يعني النص اللي بيتعرض فيها
  /// («حجز النهاردة مش هينفع يتلغي») **عمره ما اتشاف في سياقه**، وعشان
  /// كده فضل غلط كل الوقت ده.
  ///
  /// لسه `confirmed` مش `inProgress`: الفرع ما علّمش الوصول، وده اللي
  /// بيحصل فعلاً كتير. الحجز بيفضل تحت «القادمة» فالعميل بيلاقيه ويدوس.
  static BookingUiModel get _cancelWindowClosed => BookingUiModel(
    uuid: _ulid('CWC1'),
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-1',
    branchName: 'فرع المعادي',
    branchAddress: '12 شارع 9، المعادي، القاهرة',
    imagePath: '',
    status: BookingStatus.confirmed,
    // بقاعدة السيرفر: الميعاد عدّى، فالإلغاء اتقفل.
    canCancel: false,
    items: <BookingItemUiModel>[
      _item(
        seed: 'CWC1A1',
        serviceUuid: 'srv-1',
        serviceName: 'قص شعر',
        employeeName: 'أحمد محمود',
        // مالهمش لازمة مع `minutesFromNow` — بس الـ helper بيطلبهم.
        inDays: 0,
        atHour: 0,
        durationMinutes: 45,
        price: 250,
        minutesFromNow: -30,
      ),
    ],
  );

  /// **نفس الخدمة في الفرعين بسعرين** — دي حجة السيناريو كلها.
  ///
  /// الحجزين على **نفس الخدمة** (`srv-1` قص شعر) في فرعين، بـ٢٥٠ و٢٩٠.
  /// الفرق مش مصادفة: هو `MockServices` بيحسبه بمعامل الفرع، فالقايمة
  /// بتقول نفس اللي صفحة المحل هتقوله لما التستر يغيّر الفرع.
  ///
  /// ليه فيكستشر لوحدها بدل ما ترجّع فاضي: `regression_test` بيطلب إن كل
  /// سيناريو تكون بصمته مختلفة، والفاضي بيتصادم مع تلات سيناريوهات تانية
  /// بتستخدمه.
  static List<BookingUiModel> get _secondBranchPricing => <BookingUiModel>[
    BookingUiModel(
      uuid: _ulid('BPR1'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-1',
      branchName: 'فرع المعادي',
      branchAddress: '12 شارع 9، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'BPR1A1',
          serviceUuid: 'srv-1',
          serviceName: 'قص شعر',
          employeeName: 'أحمد محمود',
          inDays: 2,
          atHour: 12,
          durationMinutes: 45,
          price: 250,
        ),
      ],
    ),
    BookingUiModel(
      uuid: _ulid('BPR2'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-2',
      branchName: 'فرع مدينة نصر',
      branchAddress: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          seed: 'BPR2A1',
          serviceUuid: 'srv-1',
          // نفس الخدمة بالحرف — والفرق في السعر بس.
          serviceName: 'قص شعر',
          // وأحمد مش هنا أصلاً، فالحجز مع حد تاني.
          employeeName: 'محمد سيد',
          inDays: 4,
          atHour: 19,
          durationMinutes: 45,
          // ٢٥٠ × ١٫١٥ مقرّبة لأقرب ٥ — نفس حساب `MockServices._pricedAt`.
          price: 290,
        ),
      ],
    ),
  ];

  /// اليوم مقفول فالعميل حجز في **أول يوم شغل بعده**.
  ///
  /// الحجز في فرع مدينة نصر عشان يبان إنه اختيار تاني مش الافتراضي،
  /// والملاحظة مكتوبة بصوت العميل نفسه — دي أقرب حاجة لسبب حقيقي.
  static BookingUiModel get _afterClosedDay => BookingUiModel(
    uuid: _ulid('CL5D'),
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-2',
    branchName: 'فرع مدينة نصر',
    branchAddress: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
    imagePath: '',
    status: BookingStatus.confirmed,
    canCancel: true,
    notes: 'كنت عايز النهاردة بس الفرع مقفول',
    items: <BookingItemUiModel>[
      _item(
        seed: 'CL5DA1',
        serviceUuid: 'srv-1',
        serviceName: 'قص شعر',
        employeeName: 'مصطفى خالد',
        inDays: 2,
        atHour: 12,
        durationMinutes: 45,
        price: 250,
      ),
    ],
  );

  /// خصم على **كل** خدمة — سؤاله «الخصم بيتلاحظ من غير لابل؟».
  ///
  /// كان بيشارك `_threeServices` مع سيناريو «تلات خدمات»، فالاتنين كانوا
  /// بيعرضوا نفس الشاشة بالحرف — يعني اللي بيبدّل بينهم مش بيشوف فرق
  /// ومايقدرش يجاوب أي سؤال من الاتنين.
  ///
  /// الفرق هنا **مقصود يبقى أكبر**: خصم ٢٥٪ على مبالغ كبيرة (١٢٠٠ → ٩٠٠)
  /// عشان لو الشطب مابيتلاحظش هنا، يبقى مش هيتلاحظ في أي مكان.
  static BookingUiModel get _discounted => BookingUiModel(
    uuid: _ulid('D8C0'),
    providerUuid: 'prv-2',
    providerName: 'كوافير نور',
    branchUuid: 'brn-prv-2',
    branchName: 'الفرع الرئيسي',
    branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
    imagePath: '',
    status: BookingStatus.confirmed,
    canCancel: true,
    items: <BookingItemUiModel>[
      _item(
        seed: 'D8C0A1',
        serviceUuid: 'srv-7',
        serviceName: 'فرد بروتين',
        employeeName: 'سارة عادل',
        inDays: 4,
        atHour: 12,
        durationMinutes: 180,
        price: 900,
        originalPrice: 1200,
      ),
      _item(
        seed: 'D8C0A2',
        serviceUuid: 'srv-6',
        serviceName: 'سشوار',
        employeeName: 'سارة عادل',
        inDays: 4,
        atHour: 15,
        durationMinutes: 45,
        price: 225,
        originalPrice: 300,
      ),
    ],
  );

  /// الليستة الكاملة للسابقة.
  ///
  /// **التقييم على العنصر مش على الحجز** — فالعيّنات لازم تغطي: حجز
  /// بتلات خدمات محدش قيّمها، وحجز بتقييم **جزئي** فيه واحدة منشورة
  /// وواحدة لسه تحت المراجعة، وحجز ملغي، وحجز ما حضرش.
  static List<BookingUiModel> get _allPast => <BookingUiModel>[
    ..._completedOnly,
    _cancelled,
    _noShow,
  ];

  /// المكتمل بس — من غير الإشعارات اللي بتقعد فوق تبويب القادمة.
  ///
  /// بيفضل مليان بالقصد: كارت «احجز تاني» في الرئيسية بيقرا من هنا
  /// (`home_cubit.dart:58`)، ولو رجّعنا فاضي كل السيناريوهات تخسر
  /// الكارت ده من غير ما يبقى ده الغرض.
  static List<BookingUiModel> get _completedOnly => <BookingUiModel>[
    _completedUnrated,
    _partiallyRated,
  ];

  /// تلات خدمات · ولا واحدة اتقيّمت — بيكشف إن التقييم لكل خدمة.
  static BookingUiModel get _completedUnrated => BookingUiModel(
      uuid: _ulid('H3P8'),
      providerUuid: 'prv-1',
      providerName: 'صالون كابتن',
      branchUuid: 'brn-1',
      branchName: 'فرع المعادي',
      branchAddress: '12 شارع 9، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      items: <BookingItemUiModel>[
        _item(
          seed: 'H3P8A1',
          serviceUuid: 'srv-1',
          serviceName: 'قص شعر',
          employeeName: 'محمد سيد',
          inDays: -12,
          atHour: 17,
          durationMinutes: 60,
          price: 250,
        ),
        _item(
          seed: 'H3P8A2',
          serviceUuid: 'srv-2',
          serviceName: 'حلاقة ذقن',
          employeeName: 'محمد سيد',
          inDays: -12,
          atHour: 18,
          durationMinutes: 30,
          price: 120,
        ),
        _item(
          seed: 'H3P8A3',
          serviceUuid: 'srv-8',
          serviceName: 'غسيل وتصفيف',
          employeeName: 'أحمد محمود',
          inDays: -12,
          atHour: 18,
          atMinute: 30,
          durationMinutes: 20,
          price: 80,
        ),
      ],
    );

  /// تقييم جزئي — واحدة منشورة وواحدة **تحت المراجعة**.
  ///
  /// السيرفر بيعمل التقييم `active: false` فبيفضل مخفي لحد المراجعة،
  /// والعميل اللي بيقيّم وبيشوف لا شيء بيفتكر إنه ما اتسجّلش.
  static BookingUiModel get _partiallyRated => BookingUiModel(
      uuid: _ulid('F7S2'),
      providerUuid: 'prv-4',
      providerName: 'مركز ريلاكس',
      branchUuid: 'brn-prv-4',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، الدقي، القاهرة',
      imagePath: '',
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      items: <BookingItemUiModel>[
        _item(
          seed: 'F7S2A1',
          serviceUuid: 'srv-11',
          serviceName: 'مساج استرخاء',
          employeeName: 'كريم فؤاد',
          inDays: -25,
          atHour: 14,
          durationMinutes: 90,
          price: 500,
          rating: 5,
          ratingStatus: RatingStatus.published,
          // عشان طريق عرض التعليق يبقى عليه داتا من غير ما حد يقعد يكتب
          // في التقييم كل جلسة تجربة.
          ratingComment: 'كريم محترم والمكان هادي، هرجع تاني أكيد',
        ),
        _item(
          seed: 'F7S2A2',
          serviceUuid: 'srv-10',
          serviceName: 'تنظيف بشرة عميق',
          employeeName: 'كريم فؤاد',
          inDays: -25,
          atHour: 15,
          atMinute: 30,
          durationMinutes: 60,
          price: 450,
          rating: 4,
          ratingStatus: RatingStatus.pending,
        ),
      ],
    );

  /// كان `cancelledByProvider` — والسيرفر بيسجّل `cancelled` واحدة
  /// ومفيش عمود `cancelled_by`. السبب **بيتكشف** فعلاً في
  /// `UserBookingResource`، فالنص شغال والإسناد هو اللي مش موجود.
  static BookingUiModel get _cancelled => BookingUiModel(
      uuid: _ulid('CZ6M'),
      providerUuid: 'prv-5',
      providerName: 'استوديو جمال',
      branchUuid: 'brn-prv-5',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، المهندسين، القاهرة',
      imagePath: '',
      status: BookingStatus.cancelled,
      cancellationReason: 'الأخصائية كانت مجازة',
      items: <BookingItemUiModel>[
        _item(
          seed: 'CZ6MA1',
          serviceUuid: 'srv-10',
          serviceName: 'تنظيف بشرة عميق',
          employeeName: 'نهى سمير',
          inDays: -40,
          atHour: 12,
          durationMinutes: 60,
          price: 450,
        ),
      ],
    );

  /// الحالة اللي محدش صممها.
  ///
  /// `no_show` حالة حقيقية في `BookingStatus::lifecycleCases()` والفرع
  /// بيحطها بإيده لما العميل مايجيش. الأبلكيشن عمره ما عرضها، ومحدش
  /// يعرف العميل متوقع يعمل إيه لما يشوفها — وده بالظبط سؤال الجلسة.
  static BookingUiModel get _noShow => BookingUiModel(
    uuid: _ulid('B4T7'),
    providerUuid: 'prv-1',
    providerName: 'صالون كابتن',
    branchUuid: 'brn-2',
    branchName: 'فرع مدينة نصر',
    branchAddress: '45 شارع مصطفى النحاس، مدينة نصر، القاهرة',
    imagePath: '',
    status: BookingStatus.noShow,
    items: <BookingItemUiModel>[
      _item(
        seed: 'B4T7A1',
        serviceUuid: 'srv-1',
        serviceName: 'قص شعر',
        employeeName: 'أحمد محمود',
        inDays: -18,
        atHour: 16,
        durationMinutes: 45,
        price: 250,
      ),
    ],
  );

  /// الحجوزات اللي اتلغت في الجلسة دي — `uuid` → سبب الإلغاء.
  ///
  /// `static` عشان الإلغاء يفضل بعد ما الشاشة تتقفل. يوم الربط ده بيبقى
  /// `PATCH /user/bookings/{uuid}/cancel` والخريطة دي بتتشال.
  static final Map<String, String> _cancelledInSession = <String, String>{};

  static void markCancelled(String uuid, {required String reason}) =>
      _cancelledInSession[uuid] = reason;

  /// بيطبّق الإلغاءات على أي ليستة.
  static List<BookingUiModel> _applyCancellations(
    List<BookingUiModel> source,
  ) => source
      .map((b) => _cancelledInSession.containsKey(b.uuid) ? _asCancelled(b) : b)
      .toList();

  static BookingUiModel _asCancelled(BookingUiModel b) => BookingUiModel(
    uuid: b.uuid,
    providerUuid: b.providerUuid,
    providerName: b.providerName,
    branchUuid: b.branchUuid,
    branchName: b.branchName,
    branchAddress: b.branchAddress,
    imagePath: b.imagePath,
    items: b.items,
    status: BookingStatus.cancelled,
    paymentStatus: b.paymentStatus,
    currency: b.currency,
    notes: b.notes,
    cancellationReason: _cancelledInSession[b.uuid] ?? '',
    canCancel: false,
  );

  /// **السيناريو الشغال بيتشاف الأول.**
  ///
  /// حالتين بتكسرا لو دوّرنا في الليستة الكاملة على طول:
  ///
  /// **١. حالات الفرع.** `_inBranch` بيستخدم **نفس الـ uuid** بتاع
  /// `_singleService` بحالة مختلفة — ده مقصود، هو نفس الحجز. لو البحث
  /// راح للكاملة الأول، سيناريو «وصل الفرع» كان بيفتح التفاصيل على
  /// «مؤكد» ويبوّظ بالظبط الحالة اللي السيناريو معمول عشانها.
  ///
  /// **٢. `manyBookings`.** الأربعين حجز مش في `_allUpcoming` خالص، فأي
  /// صف فيهم كان بيفتح على أول حجز في القايمة.
  ///
  /// والليستة الكاملة بتفضل fallback عشان حجز ظاهر في شاشة وسيناريو
  /// اتغيّر بعدها مايوقعش على لا شيء.
  static BookingUiModel byUuid(String uuid) {
    for (final booking in <BookingUiModel>[...upcoming, ...past, ...notices]) {
      if (booking.uuid == uuid) return booking;
    }

    // **الإلغاءات بتتطبّق على الاحتياطي كمان.**
    //
    // بعد 6.2، الحجز الملغي مابقاش في `upcoming` (اتشال) ولا في `past`
    // (مكتملة بس) — وبيبقى في `notices` لحد ما العميل يقفله. من غير
    // السطر ده، حجز اتلغى واتقفل إشعاره كان بيرجع من الاحتياطي **بحالته
    // القديمة**، فصفحة التفاصيل تعرضه «مؤكد» بعد ما اتلغى.
    final all = _applyCancellations(<BookingUiModel>[
      ..._allUpcoming,
      ..._allPast,
    ]);
    return all.firstWhere((b) => b.uuid == uuid, orElse: () => all.first);
  }

  /// بيرجّع الـ mock لحالته الأولى — **للاختبارات بس**.
  ///
  /// الإلغاءات والإشعارات المقفولة `static` عشان تعيش بعد ما الشاشة
  /// تتقفل، فبين اختبار والتاني بتتسرّب. تشغيل الأبلكيشن من جديد بيعمل
  /// نفس الحاجة دي بالظبط.
  static void resetSession() {
    _cancelledInSession.clear();
    _dismissedNotices.clear();
  }
}
