import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';

/// MOCK — يتشال عند ربط:
///   GET /api/public/bookings/available-dates
///   GET /api/public/bookings/available-slots
///
/// الملف ده الوحيد اللي فيه منطق حقيقي. باقي ملفات الـ mock ليستة ثابتة،
/// ده لأ — لازم يولّد **نسبة للنهاردة**، وإلا التقويم هيبقى كله ماضي بعد
/// أسبوع وهنفضل نصلّحه كل يومين.
///
/// وكله deterministic (الـ seed من رقم اليوم) — عشان نفس اليوم يدي نفس
/// المواعيد في كل rebuild. لو استخدمنا عشوائي حقيقي الليستة هتتقلب قدام
/// العميل وهو بيبص عليها.
/// حالة يوم في شريط التواريخ.
enum DayAvailability {
  open,

  /// الفرع مقفول — حقيقة، بتقفل الكلام.
  closed,

  /// مفتوح بس مفيش مكان — **مدخل قائمة الانتظار**.
  fullyBooked,

  /// النهاردة وخلصت مواعيده.
  passed,
}

extension DayAvailabilityLabel on DayAvailability {
  /// اللابل تحت رقم اليوم. فاضي = مفيش لابل (اليوم المتاح مايحتاجش شرح).
  String get label => switch (this) {
    DayAvailability.open => '',
    DayAvailability.closed => 'مقفول',
    DayAvailability.fullyBooked => 'مليان',
    DayAvailability.passed => 'عدّى',
  };

  bool get isBookable => this == DayAvailability.open;

  /// المليان بس هو اللي بيودّي لقائمة الانتظار — المقفول مالوش طلب
  /// يتسجّل، والعدّى مالوش لزمة.
  bool get offersWaitlist => this == DayAvailability.fullyBooked;
}

class MockSlots {
  MockSlots._();

  static const int _openHour = 9;
  static const int _closeHour = 21;
  static const int _stepMinutes = 15;

  /// أقصى مدى للحجز المقدّم — **من `MockConfig` مش رقم مكتوب هنا**.
  ///
  /// كان ٦٠ يوم ثابتة، فمكانش ينفع نجرّب فرع بيقبل حجز أسبوع بس قدام،
  /// وهي حاجة السيرفر بيسمح بيها لكل فرع.
  static int get _horizonDays => MockConfig.maxAdvanceDays;

  /// الأيام اللي فيها مواعيد، من النهاردة لحد ٦٠ يوم.
  ///
  /// اليوم بيتشال لو:
  ///   • من أيام القفل (`MockConfig.emptySlotsDays`)
  ///   • أو هو النهاردة وكل مواعيده عدّت
  /// [durationMinutes] **مش اختياري في المعنى** حتى لو ليه قيمة افتراضية.
  ///
  /// كانت الدالة دي بتنده `slotsFor(date: day)` من غير أي arguments، فبتقع
  /// على الافتراضي ٤٥ دقيقة — بينما اللي بيرسم المواعيد الفعلية بيبعت مدة
  /// الخدمة الحقيقية. النتيجة: التقويم بيقول إن اليوم فاضي وهو مش فاضي
  /// لخدمة ١٨٠ دقيقة، والعميل بيدوس على اليوم ويلاقيه مقفول.
  ///
  /// الفرق ده حقيقي: «بروتين» ١٢٠ دقيقة ليها أيام أقل بكتير من «حلاقة
  /// ذقن» ٢٠ دقيقة، وده اللي السيرفر بيحسبه فعلاً.
  static List<DateTime> availableDates({
    required DateTime month,
    int durationMinutes = 45,
  }) {
    final today = _dateOnly(DateTime.now());
    final result = <DateTime>[];

    for (var i = 0; i <= _horizonDays; i++) {
      final day = today.add(Duration(days: i));
      if (day.month != month.month || day.year != month.year) continue;
      if (slotsFor(date: day, durationMinutes: durationMinutes).isEmpty) {
        continue;
      }
      result.add(day);
    }

    return result;
  }

  /// أقرب يوم فيه مواعيد — الـ sheet بيفتح عليه على طول عشان يبقى مفيد
  /// من أول ثانية بدل ما العميل يدوّر.
  static DateTime? firstAvailableDate({int durationMinutes = 45}) {
    final today = _dateOnly(DateTime.now());
    for (var i = 0; i <= _horizonDays; i++) {
      final day = today.add(Duration(days: i));
      if (slotsFor(date: day, durationMinutes: durationMinutes).isNotEmpty) {
        return day;
      }
    }
    return null;
  }

  /// مواعيد يوم واحد.
  ///
  /// [anyAvailable] يعني العميل سايب «أي أخصائي متاح» — وساعتها السعر
  /// بيختلف من ميعاد للتاني حسب **مين اللي فاضي**، مش حسب الساعة.
  static List<SlotUiModel> slotsFor({
    required DateTime date,
    int durationMinutes = 45,
    double basePrice = 250,
    bool anyAvailable = false,
  }) {
    final day = _dateOnly(date);

    // يوم قفل — مفيش مواعيد خالص.
    if (_isClosed(day)) {
      return const <SlotUiModel>[];
    }

    final now = DateTime.now();
    final isToday = _isSameDay(day, now);
    final seed = day.day + day.month * 31;
    final slots = <SlotUiModel>[];

    var index = 0;
    for (
      var minutes = _openHour * 60;
      minutes + durationMinutes <= _closeHour * 60;
      minutes += _stepMinutes
    ) {
      final startAt = day.add(Duration(minutes: minutes));

      // المواعيد اللي فاتت متتعرضش. دي بالذات بتكشف باجات التوقيت بدري.
      if (isToday && startAt.isBefore(now)) {
        index++;
        continue;
      }

      // بعض المواعيد محجوزة — عشان اليوم ما يبقاش فاضي بالكامل وشكله مش
      // طبيعي. الاختيار deterministic من الـ seed.
      if ((seed + index) % 3 == 0) {
        index++;
        continue;
      }

      // **السعر بيختلف بمين، مش بإمتى.**
      //
      // كان فيه `+50` على ميعاد من كل ٤ — تسعير حسب الساعة. وده مالوش
      // وجود في السيرفر خالص: السعر بيتحدد من سلسلة الأخصائي/الخدمة/الفرع
      // (`PriceResolverService`) وبعدين خصم مجموعة العميل، ومفيش بُعد
      // زمني في أي خطوة. فالتجربة كانت بتقيس سلوك تسعير الشركة مالهاش.
      //
      // بس فرق السعر **نفسه حقيقي** — أحمد بـ٣٠٠ ومحمد ومصطفى بـ٢٥٠،
      // والـ API بيرجّع `effective_price` مختلف لكل أخصائي. فلما العميل
      // سايب «أي أخصائي متاح»، الميعاد اللي أحمد هو الفاضي فيه بيغلى
      // فعلاً. ده السبب اللي يستاهل يتعرض على الشيب.
      //
      // أخصائي محدد؟ السعر ثابت — هو نفس الشخص في كل المواعيد.
      slots.add(
        SlotUiModel(
          startAt: startAt,
          endAt: startAt.add(Duration(minutes: durationMinutes)),
          price: anyAvailable
              ? basePrice + MockEmployees.priceDeltaForSlot(index)
              : basePrice,
          employeeName: MockEmployees.nameForSlot(index),
        ),
      );

      index++;
    }

    return slots;
  }

  /// **حالة اليوم — «مقفول» غير «مليان» غير «عدّى».**
  ///
  /// التلاتة كانوا شكل واحد: يوم مشخوط. ومعناهم مختلف تمامًا:
  ///
  ///  • **مقفول** حقيقة عن المحل. بتقفل الكلام — مفيش حاجة تتعمل.
  ///  • **مليان** طلب قابل قدامه عرض فاضي. ده **أحسن مدخل لقائمة
  ///    الانتظار في المنتج كله**، وكان متعرض كطريق مسدود.
  ///  • **عدّى** — النهاردة وخلص ميعاده. لا مقفول ولا مليان.
  static DayAvailability dayStatus(DateTime date, {int durationMinutes = 45}) {
    final day = _dateOnly(date);

    if (_isClosed(day)) return DayAvailability.closed;

    if (slotsFor(date: day, durationMinutes: durationMinutes).isNotEmpty) {
      return DayAvailability.open;
    }

    // فاضي والفرع مفتوح: يا النهاردة عدّى، يا محجوز بالكامل.
    final now = DateTime.now();
    if (_isSameDay(day, now) && now.hour >= _closeHour) {
      return DayAvailability.passed;
    }
    return DayAvailability.fullyBooked;
  }

  /// **أحسن ٤–٦ مواعيد عبر كذا يوم** — بديل شبكة الـ٣٠ شيب.
  ///
  /// ## ليه ده أهم تغيير تفاعل في الخطة
  ///
  /// خدمة ٤٥ دقيقة في يوم مفتوح بتطلّع ٣٠+ ميعاد. ومعظم العملاء عندهم
  /// **نافذتين أو تلاتة مقبولين**، مش حد ١٥ دقيقة مفضّل. الشبكة القديمة
  /// كانت بتحمّل العميل عبء البحث: يفتح يوم، يمسح بعينه، مايلاقيش،
  /// يفتح اليوم اللي بعده، ويكرر.
  ///
  /// القلب بيخلي الأبلكيشن هو اللي يبحث: **إنت عايز إمتى تقريبًا؟** وبعدين
  /// «أهو أقرب ٦ مواعيد مناسبين». الشبكة الكاملة بتفضل على بُعد ضغطة.
  ///
  /// **موزّعين على أيام مش مكوّمين في يوم.** أقصى ميعادين في اليوم
  /// الواحد — عشان الاقتراحات تجاوب على «إمتى ينفع» مش «إيه المتاح
  /// النهاردة».
  static List<SlotUiModel> proposals({
    int durationMinutes = 45,
    double basePrice = 250,
    bool anyAvailable = false,
    Set<SlotPeriod> periods = const <SlotPeriod>{},
    int limit = 6,
    int scanDays = 21,
  }) {
    final today = _dateOnly(DateTime.now());
    final result = <SlotUiModel>[];

    for (var i = 0; i <= scanDays && result.length < limit; i++) {
      final day = today.add(Duration(days: i));
      final slots = slotsFor(
        date: day,
        durationMinutes: durationMinutes,
        basePrice: basePrice,
        anyAvailable: anyAvailable,
      );
      if (slots.isEmpty) continue;

      final wanted = periods.isEmpty
          ? slots
          : slots.where((s) => periods.contains(s.period)).toList();
      if (wanted.isEmpty) continue;

      // أقرب ميعاد في كل نافذة مطلوبة — بحد أقصى اتنين في اليوم.
      final perDay = <SlotUiModel>[];
      for (final period in SlotPeriod.values) {
        if (perDay.length >= 2) break;
        final match = wanted.where((s) => s.period == period);
        if (match.isEmpty) continue;
        perDay.add(match.first);
      }

      for (final slot in perDay) {
        if (result.length >= limit) break;
        result.add(slot);
      }
    }

    return result;
  }

  /// اليوم ده مقفول؟
  ///
  /// **«مقفول» غير «محجوز بالكامل»** — الاتنين شكلهم واحد دلوقتي ومعناهم
  /// عكس بعض. مقفول حقيقة وبتقفل الكلام؛ محجوز بالكامل طلب قابل قدامه
  /// عرض فاضي، وهو أحسن مدخل لقائمة الانتظار في المنتج كله. الفصل ده
  /// بند مستقل (4.2)، والدالة دي هي المكان اللي هيتفرّع منه.
  static bool _isClosed(DateTime day) {
    if (MockConfig.scenario == MockScenario.branchClosedToday &&
        _isSameDay(day, DateTime.now())) {
      return true;
    }
    return MockConfig.emptySlotsDays.contains(day.weekday);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
