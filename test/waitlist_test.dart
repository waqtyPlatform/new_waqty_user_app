import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';

void main() {
  setUp(() {
    MockConfig.delay = Duration.zero;
    // الإلغاءات والإشعارات المقفولة `static` — من غير التصفير دي
    // بتتسرّب بين الاختبارات زي ما بتعيش بين الشاشات في الأبلكيشن.
    MockBookings.resetSession();
  });
  tearDown(() {
    MockConfig.scenario = MockScenario.happyPath;
    MockConfig.delay = const Duration(milliseconds: 600);
  });

  group('5.1أ — قائمة الانتظار', () {
    test('العرض بيبدأ بـ٥ دقايق كاملة — نفس رقم السيرفر', () {
      MockConfig.scenario = MockScenario.waitlistOffered;
      final now = DateTime(2026, 8, 2, 14);
      final entry = MockWaitlist.forUser(now).first;

      expect(entry.status, WaitlistStatus.offered);
      expect(MockWaitlist.holdMinutes, 5);
      expect(entry.remainingSeconds(now), 5 * 60);
      expect(entry.isHoldActive(now), isTrue);
    });

    test('العدّاد بينزل والحجز بيقع بعد ٥ دقايق', () {
      MockConfig.scenario = MockScenario.waitlistOffered;
      final now = DateTime(2026, 8, 2, 14);
      final entry = MockWaitlist.forUser(now).first;

      expect(entry.remainingSeconds(now.add(const Duration(minutes: 2))), 180);
      expect(entry.isHoldActive(now.add(const Duration(minutes: 5))), isFalse);
      // مابينفعش يبقى سالب — العدّاد بيقف عند صفر.
      expect(entry.remainingSeconds(now.add(const Duration(hours: 1))), 0);
    });

    test('العدّاد بيتكتب دقايق:ثواني بخانتين', () {
      MockConfig.scenario = MockScenario.waitlistOffered;
      final now = DateTime(2026, 8, 2, 14);
      final entry = MockWaitlist.forUser(now).first;

      expect(entry.countdownLabel(now), '5:00');
      // «4:5» بتتقرا غلط — الثواني لازم خانتين.
      expect(
        entry.countdownLabel(now.add(const Duration(seconds: 55))),
        '4:05',
      );
      expect(
        entry.countdownLabel(now.add(const Duration(seconds: 30))),
        '4:30',
      );
    });

    test('**العميل مايقدرش يقبل** — النص بيقول إن الفرع هو اللي بيأكّد', () {
      MockConfig.scenario = MockScenario.waitlistOffered;
      final entry = MockWaitlist.forUser(DateTime.now()).first;

      // `accept` تحت `/provider/` مش `/user/`. النص لازم يفضل صادق لحد
      // ما يبقى فيه endpoint للعميل — أي «أكّد» هنا بيكدب.
      expect(entry.explanation, contains('الفرع'));
      expect(entry.explanation, isNot(contains('أكّد دلوقتي')));
    });

    test('الحجز اللي عدّى بيبقى expired', () {
      MockConfig.scenario = MockScenario.waitlistExpired;
      final entry = MockWaitlist.forUser(DateTime.now()).first;

      expect(entry.status, WaitlistStatus.expired);
      expect(entry.isHoldActive(DateTime.now()), isFalse);
      expect(entry.status.isLive, isFalse);
    });

    test('الإضافة بتبدأ pending — الفرع لسه ما عرضش', () {
      final entry = MockWaitlist.add(
        providerName: 'صالون كابتن',
        branchName: 'فرع المعادي',
        serviceName: 'قص شعر',
        preferredAt: DateTime(2026, 8, 10, 18),
      );

      expect(entry.status, WaitlistStatus.pending);
      expect(entry.holdExpiresAt, isNull);
      expect(MockWaitlist.forUser(DateTime.now()), contains(entry));

      MockWaitlist.removeByUuid(entry.uuid);
      expect(MockWaitlist.forUser(DateTime.now()), isNot(contains(entry)));
    });
  });

  group('5.4 + ج٤ — حلقة الإلغاء', () {
    test('السبب بيتخزّن وبيتعرض', () {
      // حجز النهاردة `canCancel: false` بقاعدة السيرفر، فبنستخدم
      // سيناريو فيه حجز بعيد ينفع يتلغي.
      MockConfig.scenario = MockScenario.multiServiceOneVisit;
      final target = MockBookings.upcoming.firstWhere((b) => b.canCancel);
      MockBookings.markCancelled(target.uuid, reason: 'ظروف طارئة');

      final after = MockBookings.byUuid(target.uuid);
      expect(after.status, BookingStatus.cancelled);
      // كان بيتطلب من العميل وبيترمي — والسيرفر بيكشفه أصلاً في
      // `UserBookingResource`.
      expect(after.cancellationReason, 'ظروف طارئة');
    });

    test('الملغي بيخرج من «القادمة» على طول', () {
      // حجز النهاردة `canCancel: false` بقاعدة السيرفر، فبنستخدم
      // سيناريو فيه حجز بعيد ينفع يتلغي.
      MockConfig.scenario = MockScenario.multiServiceOneVisit;
      final target = MockBookings.upcoming.firstWhere((b) => b.canCancel);
      MockBookings.markCancelled(target.uuid, reason: '');

      expect(
        MockBookings.upcoming.map((b) => b.uuid),
        isNot(contains(target.uuid)),
      );
    });
  });

  group('6.2 — «السابقة» = مكتملة بس', () {
    test('الملغي واللي ما حضرش مش في القايمة', () {
      expect(
        MockBookings.past.every((b) => b.status == BookingStatus.completed),
        isTrue,
      );
    });

    test('بيظهروا كإشعارات بدل الأرشيف', () {
      MockConfig.scenario = MockScenario.cancelledBooking;
      final notices = MockBookings.notices;

      expect(notices, isNotEmpty);
      expect(notices.first.status, BookingStatus.cancelled);
      expect(MockBookings.past, isEmpty);
    });

    test('الإشعار بيتقفل ومابيرجعش', () {
      MockConfig.scenario = MockScenario.noShow;
      final notice = MockBookings.notices.first;

      expect(notice.status, BookingStatus.noShow);
      MockBookings.dismissNotice(notice.uuid);

      expect(
        MockBookings.notices.map((b) => b.uuid),
        isNot(contains(notice.uuid)),
      );
    });
  });

  group('6.1 — «زي المرة اللي فاتت»', () {
    test('بيتاخد من آخر حجز مكتمل — مش ملغي ولا ما حضرش', () {
      MockConfig.scenario = MockScenario.happyPath;
      final candidates = MockBookings.past
          .where((b) => b.status == BookingStatus.completed)
          .toList();

      expect(candidates, isNotEmpty);
      // كل اللي في «السابقة» مكتمل، فأي واحد فيهم صالح كمصدر للكارت.
      final source = candidates.first;
      expect(source.providerUuid, isNotEmpty);
      expect(source.branchUuid, isNotEmpty);
      // الخدمة بتتنقل للـ wizard — محتاجة `serviceUuid` على العنصر.
      expect(source.items.first.serviceUuid, isNotEmpty);
    });
  });
}
