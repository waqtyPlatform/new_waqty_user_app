import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/bookings
///
/// كل المواعيد نسبة للنهاردة عشان القايمة ما تبقاش كلها ماضي بعد أسبوع.
///
/// **العيّنات مقصودة**: فيها حجز بخدمة واحدة، وحجز بتلات خدمات في يوم
/// واحد مع أخصائيين مختلفين، وحجز بزيارتين في يومين. من غير التلاتة دول
/// شاشات العرض بتتجرب على الحالة السهلة بس وبتقع أول ما تشوف حجز حقيقي.
class MockBookings {
  MockBookings._();

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// اختصار لبناء عنصر بالساعة والدقيقة والمدة.
  ///
  /// [visitUuid] بيحدد العنصر تابع لأنهي رحلة. العناصر اللي في نفس
  /// الرحلة بتاخد نفس القيمة — **مش بالضرورة نفس اليوم يعني نفس الرحلة**.
  static BookingItemUiModel _item({
    String visitUuid = 'v1',
    required String serviceName,
    required String employeeName,
    required int inDays,
    required int atHour,
    int atMinute = 0,
    required int durationMinutes,
    required double price,
  }) {
    final startAt = _today.add(
      Duration(days: inDays, hours: atHour, minutes: atMinute),
    );
    return BookingItemUiModel(
      visitUuid: visitUuid,
      serviceName: serviceName,
      employeeName: employeeName,
      startAt: startAt,
      endAt: startAt.add(Duration(minutes: durationMinutes)),
      price: price,
    );
  }

  /// الحجوزات القادمة.
  ///
  /// فيها واحد **النهاردة** بالقصد — عشان نتأكد إن زرار الإلغاء بيتخفي
  /// (`canCancel: false`)، ودي القاعدة اللي السيرفر فارضها ومحدش كان
  /// بيقولها للعميل.
  static List<BookingUiModel> get upcoming => <BookingUiModel>[
    BookingUiModel(
      uuid: 'bkg-1',
      reference: 'WQ-10428',
      providerName: 'صالون كابتن',
      branchName: 'فرع المعادي',
      branchAddress: '١٢ شارع ٩، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: false, // النهاردة — الإلغاء مش مسموح
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'قص شعر',
          employeeName: 'أحمد محمود',
          inDays: 0,
          atHour: 18,
          durationMinutes: 45,
          price: 250,
        ),
      ],
    ),

    // ── تلات خدمات · يوم واحد · أخصائيين ──────────────────────────────
    // زيارة واحدة، تلات عناصر ورا بعض. ده اللي بيكشف إن الصف المختصر
    // بيقول «و٢ غيرها» وإن الإجمالي مجموع مش سعر أول خدمة.
    BookingUiModel(
      uuid: 'bkg-3',
      reference: 'WQ-10461',
      providerName: 'باربر شوب الحرية',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مصر الجديدة، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'قص شعر',
          employeeName: 'مصطفى خالد',
          inDays: 6,
          atHour: 19,
          durationMinutes: 45,
          price: 250,
        ),
        _item(
          serviceName: 'حلاقة ذقن',
          employeeName: 'مصطفى خالد',
          inDays: 6,
          atHour: 19,
          atMinute: 45,
          durationMinutes: 30,
          price: 120,
        ),
        _item(
          serviceName: 'غسيل وتصفيف',
          employeeName: 'يوسف عادل',
          inDays: 6,
          atHour: 20,
          atMinute: 15,
          durationMinutes: 20,
          price: 80,
        ),
      ],
    ),

    // ── زيارتين · يومين مختلفين ───────────────────────────────────────
    // الحالة اللي التصميم القديم مكانش بيقدر يعرضها خالص.
    BookingUiModel(
      uuid: 'bkg-7',
      reference: 'WQ-10473',
      providerName: 'كوافير نور',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      notes: 'لو ينفع أخصائية ست يبقى أحسن',
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'صبغة',
          employeeName: 'سارة عادل',
          inDays: 3,
          atHour: 11,
          durationMinutes: 90,
          price: 600,
        ),
        _item(
          visitUuid: 'v2',
          serviceName: 'بروتين',
          employeeName: 'سارة عادل',
          inDays: 10,
          atHour: 13,
          durationMinutes: 120,
          price: 900,
        ),
      ],
    ),

    // ── رحلتين في **نفس اليوم** ────────────────────────────────────────
    // الحالة اللي التجميع باليوم كان بيكسرها: العميل بيجي الصبح ويمشي،
    // ويرجع بالليل. لو اتعرضوا زيارة واحدة، الفرع بيعمل check-in الساعة
    // ١٠ والعميل يفضل «واصل» لحد بالليل.
    BookingUiModel(
      uuid: 'bkg-8',
      reference: 'WQ-10488',
      providerName: 'استوديو جمال',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، المهندسين، القاهرة',
      imagePath: '',
      status: BookingStatus.confirmed,
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'صبغة',
          employeeName: 'نهى سمير',
          inDays: 5,
          atHour: 10,
          durationMinutes: 90,
          price: 600,
        ),
        _item(
          visitUuid: 'v2',
          serviceName: 'حمام كريم',
          employeeName: 'نهى سمير',
          inDays: 5,
          atHour: 20,
          durationMinutes: 30,
          price: 180,
        ),
      ],
    ),

    BookingUiModel(
      uuid: 'bkg-2',
      reference: 'WQ-10455',
      providerName: 'كوافير نور',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
      imagePath: '',
      status: BookingStatus.pending, // لسه المحل ما أكّدش
      canCancel: true,
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'سشوار',
          employeeName: 'سارة عادل',
          inDays: 4,
          atHour: 11,
          durationMinutes: 45,
          price: 300,
        ),
      ],
    ),
  ];

  /// الحجوزات السابقة — فيها حالة منتهية بتقييم وحالة من غير تقييم
  /// وحالة ملغاة من المحل، عشان نجرّب الأشكال المختلفة.
  static List<BookingUiModel> get past => <BookingUiModel>[
    BookingUiModel(
      uuid: 'bkg-4',
      reference: 'WQ-10310',
      providerName: 'صالون كابتن',
      branchName: 'فرع المعادي',
      branchAddress: '١٢ شارع ٩، المعادي، القاهرة',
      imagePath: '',
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      myRating: 0, // لسه ما قيّمش — الشاشة هتطلبه منه
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'قص شعر',
          employeeName: 'محمد سيد',
          inDays: -12,
          atHour: 17,
          durationMinutes: 60,
          price: 250,
        ),
      ],
    ),
    BookingUiModel(
      uuid: 'bkg-5',
      reference: 'WQ-10221',
      providerName: 'مركز ريلاكس',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، الدقي، القاهرة',
      imagePath: '',
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      myRating: 5,
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'مساج استرخاء',
          employeeName: 'كريم فؤاد',
          inDays: -25,
          atHour: 14,
          durationMinutes: 90,
          price: 500,
        ),
      ],
    ),
    BookingUiModel(
      uuid: 'bkg-6',
      reference: 'WQ-10190',
      providerName: 'استوديو جمال',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، المهندسين، القاهرة',
      imagePath: '',
      status: BookingStatus.cancelledByProvider,
      cancellationReason: 'الأخصائية كانت مجازة',
      items: <BookingItemUiModel>[
        _item(
          serviceName: 'تنظيف بشرة عميق',
          employeeName: 'نهى سمير',
          inDays: -40,
          atHour: 12,
          durationMinutes: 60,
          price: 450,
        ),
      ],
    ),
  ];

  static BookingUiModel byUuid(String uuid) => <BookingUiModel>[
    ...upcoming,
    ...past,
  ].firstWhere((b) => b.uuid == uuid, orElse: () => upcoming.first);
}
