import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';

/// Phase 4 — قرار الميعاد.
void main() {
  tearDown(() => MockConfig.scenario = MockScenario.happyPath);

  group('4.1 — الاقتراحات', () {
    test('بترجّع ٦ على الأكتر — مش شبكة الـ٣٠ شيب', () {
      final result = MockSlots.proposals();

      expect(result.length, lessThanOrEqualTo(6));
      expect(result, isNotEmpty);
    });

    test('**موزّعة على أيام مش مكوّمة في يوم**', () {
      final result = MockSlots.proposals();
      final days = result
          .map((s) => DateTime(s.startAt.year, s.startAt.month, s.startAt.day))
          .toSet();

      // ده جوهر التغيير: الاقتراحات بتجاوب «إمتى ينفع» مش «إيه المتاح
      // النهاردة». أقصى ميعادين في اليوم.
      expect(days.length, greaterThan(1));
      for (final day in days) {
        final perDay = result.where(
          (s) =>
              s.startAt.year == day.year &&
              s.startAt.month == day.month &&
              s.startAt.day == day.day,
        );
        expect(perDay.length, lessThanOrEqualTo(2));
      }
    });

    test('النوافذ بتفلتر — والاختيار متعدد', () {
      final morning = MockSlots.proposals(
        periods: <SlotPeriod>{SlotPeriod.morning},
      );
      expect(morning, isNotEmpty);
      expect(morning.every((s) => s.period == SlotPeriod.morning), isTrue);

      // «الصبح أو بالليل بس مش الضهر» — جملة طبيعية، ولازم تشتغل.
      final both = MockSlots.proposals(
        periods: <SlotPeriod>{SlotPeriod.morning, SlotPeriod.evening},
      );
      expect(
        both.every(
          (s) =>
              s.period == SlotPeriod.morning || s.period == SlotPeriod.evening,
        ),
        isTrue,
      );
      expect(both.any((s) => s.period == SlotPeriod.evening), isTrue);
    });

    test('نوافذ فاضية = أي وقت', () {
      final any = MockSlots.proposals();
      final periods = any.map((s) => s.period).toSet();

      expect(periods.length, greaterThan(1));
    });

    test('مدة الخدمة بتأثّر على الاقتراحات', () {
      final short = MockSlots.proposals(durationMinutes: 20);
      final long = MockSlots.proposals(durationMinutes: 13 * 60);

      expect(short, isNotEmpty);
      // أطول من يوم العمل — مفيش اقتراحات خالص.
      expect(long, isEmpty);
    });

    test('مرتبة زمنيًا — الأقرب الأول', () {
      final result = MockSlots.proposals();

      for (var i = 1; i < result.length; i++) {
        expect(
          result[i].startAt.isAfter(result[i - 1].startAt),
          isTrue,
          reason: 'الاقتراح $i مش بعد اللي قبله',
        );
      }
    });
  });

  group('twoBranches — سيناريو كان مالوش أثر', () {
    test('من غير السيناريو: محل واحد بس ليه فرعين', () {
      MockConfig.scenario = MockScenario.happyPath;

      expect(MockProviders.branchesOf('prv-1').length, 2);
      expect(MockProviders.branchesOf('prv-3').length, 1);
    });

    test('مع السيناريو: كل المحلات ليها فرعين', () {
      MockConfig.scenario = MockScenario.twoBranches;

      // كان السيناريو تعليمة شفهية («افتح صالون كابتن») — يعني اسم في
      // القايمة مالوش أثر، وهو نفس العيب اللي شيلنا عشانه الحالات
      // المستحيلة من الـ enums.
      for (final uuid in <String>['prv-1', 'prv-2', 'prv-3', 'prv-5']) {
        expect(MockProviders.branchesOf(uuid).length, 2, reason: uuid);
      }
    });

    test('الفروع المولّدة مالهاش uuid متكرر بين المحلات', () {
      MockConfig.scenario = MockScenario.twoBranches;

      final uuids = <String>[
        for (final p in <String>['prv-2', 'prv-3', 'prv-5'])
          ...MockProviders.branchesOf(p).map((b) => b.uuid),
      ];

      expect(uuids.toSet().length, uuids.length);
    });
  });

  group('4.2 — «مقفول» ≠ «مليان»', () {
    test('الجمعة مقفولة — بتقفل الكلام', () {
      // ٥ = الجمعة في ترتيب Dart، وهي اليوم الوحيد المقفول.
      final friday = _nextWeekday(DateTime.now(), 5);
      final status = MockSlots.dayStatus(friday);

      expect(status, DayAvailability.closed);
      expect(status.label, 'مقفول');
      expect(status.isBookable, isFalse);
      // **مفيش قائمة انتظار ليوم مقفول** — مفيش طلب يتسجّل أصلاً.
      expect(status.offersWaitlist, isFalse);
    });

    test('اليوم المليان بيودّي لقائمة الانتظار', () {
      // خدمة أطول من يوم العمل بتخلي أي يوم مفتوح «مليان».
      final openDay = _nextWeekday(DateTime.now(), 1);
      final status = MockSlots.dayStatus(openDay, durationMinutes: 13 * 60);

      expect(status, DayAvailability.fullyBooked);
      expect(status.label, 'مليان');
      expect(status.isBookable, isFalse);
      // ده أحسن مدخل لقائمة الانتظار في المنتج، وكان طريق مسدود.
      expect(status.offersWaitlist, isTrue);
    });

    test('اليوم المفتوح مالوش لابل', () {
      final openDay = _nextWeekday(DateTime.now(), 1);
      final status = MockSlots.dayStatus(openDay);

      expect(status, DayAvailability.open);
      expect(status.label, isEmpty);
      expect(status.isBookable, isTrue);
    });

    test('السيناريو بيقفل النهاردة', () {
      MockConfig.scenario = MockScenario.branchClosedToday;
      expect(MockSlots.dayStatus(DateTime.now()), DayAvailability.closed);
    });

    test('التلات حالات ليها ألفاظ مختلفة', () {
      // لو اتنين اتساوا، الفرق اللي البند كله عنه بيضيع.
      final labels = <String>{
        DayAvailability.closed.label,
        DayAvailability.fullyBooked.label,
        DayAvailability.passed.label,
      };
      expect(labels.length, 3);
    });
  });
}

/// أقرب يوم قدام بترتيب أسبوع Dart المطلوب (١ = الاثنين … ٧ = الأحد).
DateTime _nextWeekday(DateTime from, int weekday) {
  var day = DateTime(from.year, from.month, from.day);
  // بنبدأ من بكرة عشان مانقعش على النهاردة وهي نصها عدّى.
  do {
    day = day.add(const Duration(days: 1));
  } while (day.weekday != weekday);
  return day;
}
