import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
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
class MockSlots {
  MockSlots._();

  static const int _openHour = 9;
  static const int _closeHour = 21;
  static const int _stepMinutes = 15;
  static const int _horizonDays = 60;

  /// الأيام اللي فيها مواعيد، من النهاردة لحد ٦٠ يوم.
  ///
  /// اليوم بيتشال لو:
  ///   • من أيام القفل (`MockConfig.emptySlotsDays`)
  ///   • أو هو النهاردة وكل مواعيده عدّت
  static List<DateTime> availableDates({required DateTime month}) {
    final today = _dateOnly(DateTime.now());
    final result = <DateTime>[];

    for (var i = 0; i <= _horizonDays; i++) {
      final day = today.add(Duration(days: i));
      if (day.month != month.month || day.year != month.year) continue;
      if (slotsFor(date: day).isEmpty) continue;
      result.add(day);
    }

    return result;
  }

  /// أقرب يوم فيه مواعيد — الـ sheet بيفتح عليه على طول عشان يبقى مفيد
  /// من أول ثانية بدل ما العميل يدوّر.
  static DateTime? firstAvailableDate() {
    final today = _dateOnly(DateTime.now());
    for (var i = 0; i <= _horizonDays; i++) {
      final day = today.add(Duration(days: i));
      if (slotsFor(date: day).isNotEmpty) return day;
    }
    return null;
  }

  /// مواعيد يوم واحد.
  static List<SlotUiModel> slotsFor({
    required DateTime date,
    int durationMinutes = 45,
    double basePrice = 250,
  }) {
    final day = _dateOnly(date);

    // يوم قفل — مفيش مواعيد خالص.
    if (MockConfig.emptySlotsDays.contains(day.weekday)) {
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

      // ميعاد من كل ٤ سعره أعلى — عشان نتأكد إن فرق السعر بيظهر على
      // الشيب صح، ومبيظهرش لما السعر زي الباقي.
      final hasSurcharge = (seed + index) % 4 == 0;

      slots.add(
        SlotUiModel(
          startAt: startAt,
          endAt: startAt.add(Duration(minutes: durationMinutes)),
          price: hasSurcharge ? basePrice + 50 : basePrice,
          employeeName: MockEmployees.nameForSlot(index),
        ),
      );

      index++;
    }

    return slots;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
