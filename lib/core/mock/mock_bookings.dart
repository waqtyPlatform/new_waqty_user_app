import 'package:waqty_user_application/core/models/booking_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /api/user/bookings
///
/// كل المواعيد نسبة للنهاردة عشان القايمة ما تبقاش كلها ماضي بعد أسبوع.
class MockBookings {
  MockBookings._();

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
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
      serviceName: 'قص شعر',
      employeeName: 'أحمد محمود',
      imagePath: '',
      startAt: _today.add(const Duration(hours: 18)),
      endAt: _today.add(const Duration(hours: 18, minutes: 45)),
      price: 250,
      status: BookingStatus.confirmed,
      canCancel: false, // النهاردة — الإلغاء مش مسموح
    ),
    BookingUiModel(
      uuid: 'bkg-2',
      reference: 'WQ-10455',
      providerName: 'كوافير نور',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مدينة نصر، القاهرة',
      serviceName: 'سشوار',
      employeeName: 'سارة عادل',
      imagePath: '',
      startAt: _today.add(const Duration(days: 3, hours: 11)),
      endAt: _today.add(const Duration(days: 3, hours: 11, minutes: 45)),
      price: 300,
      status: BookingStatus.confirmed,
      canCancel: true,
      notes: 'لو ينفع أخصائية ست يبقى أحسن',
    ),
    BookingUiModel(
      uuid: 'bkg-3',
      reference: 'WQ-10461',
      providerName: 'باربر شوب الحرية',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، مصر الجديدة، القاهرة',
      serviceName: 'قص شعر + ذقن',
      employeeName: 'مصطفى خالد',
      imagePath: '',
      startAt: _today.add(const Duration(days: 6, hours: 19)),
      endAt: _today.add(const Duration(days: 6, hours: 20)),
      price: 330,
      status: BookingStatus.pending, // لسه المحل ما أكّدش
      canCancel: true,
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
      serviceName: 'قص شعر',
      employeeName: 'محمد سيد',
      imagePath: '',
      startAt: _today.subtract(const Duration(days: 12, hours: -17)),
      endAt: _today.subtract(const Duration(days: 12, hours: -18)),
      price: 250,
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      myRating: 0, // لسه ما قيّمش — الشاشة هتطلبه منه
    ),
    BookingUiModel(
      uuid: 'bkg-5',
      reference: 'WQ-10221',
      providerName: 'مركز ريلاكس',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، الدقي، القاهرة',
      serviceName: 'مساج استرخاء',
      employeeName: 'كريم فؤاد',
      imagePath: '',
      startAt: _today.subtract(const Duration(days: 25, hours: -14)),
      endAt: _today.subtract(const Duration(days: 25, hours: -15, minutes: 30)),
      price: 500,
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      myRating: 5,
    ),
    BookingUiModel(
      uuid: 'bkg-6',
      reference: 'WQ-10190',
      providerName: 'استوديو جمال',
      branchName: 'الفرع الرئيسي',
      branchAddress: 'شارع الجمهورية، المهندسين، القاهرة',
      serviceName: 'تنظيف بشرة عميق',
      employeeName: 'نهى سمير',
      imagePath: '',
      startAt: _today.subtract(const Duration(days: 40, hours: -12)),
      endAt: _today.subtract(const Duration(days: 40, hours: -13)),
      price: 450,
      status: BookingStatus.cancelledByProvider,
      cancellationReason: 'الأخصائية كانت مجازة',
    ),
  ];

  static BookingUiModel byUuid(String uuid) => <BookingUiModel>[
    ...upcoming,
    ...past,
  ].firstWhere((b) => b.uuid == uuid, orElse: () => upcoming.first);
}
