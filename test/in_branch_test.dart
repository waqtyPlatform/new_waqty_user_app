import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';

/// اختبارات رحلة الفرع — بديل الطابور.
///
/// **الغرض إن الفرق مايضيعش.** القديم كان بيعرض رقم دور من endpoint مش
/// موجود؛ الجديد بيعرض الشخص والوقت، والحالة نفسها بتيجي من عمود حقيقي.
/// الاختبارات دي بتثبّت الفرق ده عشان محدش يرجّع رقم الدور بالغلط.
void main() {
  tearDown(() => MockConfig.scenario = MockScenario.happyPath);

  BookingUiModel bookingFor(MockScenario scenario) {
    MockConfig.scenario = scenario;
    return MockBookings.upcoming.single;
  }

  group('MockInBranch.forBooking', () {
    test('بيرجّع null لما الحجز مش في الفرع', () {
      final booking = bookingFor(MockScenario.happyPath);

      expect(booking.status, BookingStatus.confirmed);
      expect(booking.status.isInBranch, isFalse);
      expect(MockInBranch.forBooking(booking, DateTime.now()), isNull);
    });

    test('وصل: مفيش تقدير — لسه ما دخلش الدور', () {
      final booking = bookingFor(MockScenario.arrivedInBranch);
      final data = MockInBranch.forBooking(booking, DateTime.now())!;

      expect(data.headline, 'وصلت');
      expect(data.subline, 'استنى شوية، هننده عليك');
      expect(data.estimateLow, isNull);
      expect(data.hasLiveEstimate, isFalse);
    });

    test('مستني: العنوان بالشخص مش برقم الدور', () {
      final booking = bookingFor(MockScenario.waitingInBranch);
      final data = MockInBranch.forBooking(booking, DateTime.now())!;

      // ده جوهر التغيير: الشخص بدل «٣ قدامك».
      //
      // الجملة اتقسمت بعد ما طلعت مقصوصة على الجهاز («أحمد محمود لسه
      // م…» عند ٤٠sp): **الاسم** بقى العنوان و**«لسه مع عميل»** نزلت
      // للسطر اللي تحت مع التقدير. الاختبار بيتأكد إن الجزئين موجودين
      // كل واحد في مكانه — لأن اللي اتكسر كان المعنى مش الترتيب.
      expect(data.headline, booking.items.first.employeeName);
      expect(data.headline, isNot(contains('قدامك')));
      expect(data.subline, contains('لسه مع عميل'));
      expect(data.subline, contains(data.estimateLabel));
      expect(data.hasLiveEstimate, isTrue);
    });

    group('من غير تقدير — B8 · قرار BE-17', () {
      test('السطر بيقف عند الحقيقة ومابيسيبش فاصل معلّق', () {
        final booking = bookingFor(MockScenario.waitingNoEstimate);
        final data = MockInBranch.forBooking(booking, DateTime.now())!;

        // الباج القديم: `estimateLabel` كانت بترجّع «دقايق» لما مفيش
        // تقدير، فالسطر يطلع «لسه مع عميل · دقايق» — وحدة قياس معلّقة
        // ورا رقم اتمسح.
        expect(data.subline, 'لسه مع عميل');
        expect(data.subline, isNot(contains('·')));
        expect(data.subline, isNot(contains('دقايق')));
      });

      test('التقدير فاضي والحالة بتفضل صادقة', () {
        final booking = bookingFor(MockScenario.waitingNoEstimate);
        final data = MockInBranch.forBooking(booking, DateTime.now())!;

        expect(data.estimateLow, isNull);
        expect(data.estimateHigh, isNull);
        expect(data.estimateLabel, isEmpty);
        expect(data.hasLiveEstimate, isFalse);
      });

      test('الأجزاء الحقيقية بتفضل شغّالة — الاسم والنداء', () {
        final booking = bookingFor(MockScenario.waitingNoEstimate);
        final data = MockInBranch.forBooking(booking, DateTime.now())!;

        // دي اللي كانت حقيقية من الأول: الحالة عمود في السيرفر والاسم
        // من عناصر الحجز. اللي اتشال هو **المخترع** بس.
        expect(data.headline, booking.items.first.employeeName);
        expect(data.label, BookingStatus.waiting.label);
        expect(data.announcement, isNotEmpty);
        expect(data.bannerLabel, isNotEmpty);
      });

      test('مفيش تنبيه بيقطع على العميل من غير رقم يبرّره', () {
        final booking = bookingFor(MockScenario.waitingNoEstimate);
        final data = MockInBranch.forBooking(booking, DateTime.now())!;

        // `needsAttention` لـ`waiting` مبنية على «التقدير بقى ٥ دقايق أو
        // أقل». من غير تقدير مفيش لحظة اسمها «قرب» — فالتنبيه مايتقالش.
        expect(data.needsAttention, isFalse);
      });

      test('السيناريوهين بيعرضوا نفس الحجز — المتغيّر واحد بس', () {
        // ده شرط المقارنة اللي بيقرر BE-17: لو الحجزين اختلفوا، الجلسة
        // بتقيس فرقين مش فرق واحد والنتيجة مابتجاوبش على السؤال.
        final withEstimate = bookingFor(MockScenario.waitingInBranch);
        final without = bookingFor(MockScenario.waitingNoEstimate);

        expect(without.uuid, withEstimate.uuid);
        expect(
          without.items.first.employeeName,
          withEstimate.items.first.employeeName,
        );
      });
    });

    test('العنوان قصير كفاية للسطر الواحد', () {
      // البؤرة `displayXl` (٤٠sp) و`maxLines: 1`. سطر بالعرض ده سعته
      // حوالي ١٢ حرف عربي على شاشة ٣٧٥ — أي عنوان أطول بيتقص، والقصّة
      // بتاكل آخر الجملة اللي هي غالبًا المعنى.
      for (final scenario in <MockScenario>[
        MockScenario.arrivedInBranch,
        MockScenario.waitingInBranch,
        MockScenario.inService,
      ]) {
        final booking = bookingFor(scenario);
        final data = MockInBranch.forBooking(booking, DateTime.now())!;
        expect(
          data.headline.length,
          lessThanOrEqualTo(14),
          reason: '${scenario.title}: «${data.headline}»',
        );
      }
    });

    test('في الخدمة: متوقع تخلص إمتى، ومفيش تقدير انتظار', () {
      final booking = bookingFor(MockScenario.inService);
      final data = MockInBranch.forBooking(booking, DateTime.now())!;

      expect(data.headline, 'الخدمة بدأت');
      expect(data.expectedFinishAt, booking.items.first.endAt);
      expect(data.subline, contains('متوقع تخلص'));
      expect(data.hasLiveEstimate, isFalse);
    });
  });

  group('التقدير', () {
    test('**مدى مش رقم واحد** — القاعدة اللي اتنقلت من الطابور القديم', () {
      final booking = bookingFor(MockScenario.waitingInBranch);

      // بنجرّب كل لحظة في الدورة عشان مفيش حالة بتطلّع رقم مفرد.
      for (var minute = 0; minute < 60; minute++) {
        final data = MockInBranch.forBooking(
          booking,
          DateTime(2026, 8, 2, 14, minute),
        )!;

        final label = data.estimateLabel;
        // يا «تقريبًا ١٠–٢٠ دقيقة» يا «أقل من ٨ دقيقة» — الاتنين
        // بيعترفوا بعدم اليقين. «باقي ٢٧ دقيقة» بيتكسر مرة والعميل
        // بيبطّل يصدّق أي رقم بعدها.
        expect(
          label.contains('–') || label.startsWith('أقل من'),
          isTrue,
          reason: 'التقدير طلع رقم مفرد عند الدقيقة $minute: $label',
        );
      }
    });

    test('أعلى تقدير دايمًا أكبر من أقله', () {
      final booking = bookingFor(MockScenario.waitingInBranch);
      final data = MockInBranch.forBooking(booking, DateTime.now())!;

      expect(data.estimateHigh!.inMinutes, greaterThan(data.estimateLow!.inMinutes));
    });
  });

  group('التنبيه — بديل الـ push', () {
    test('كل حالة ليها رسالتها', () {
      expect(
        MockInBranch.forBooking(
          bookingFor(MockScenario.arrivedInBranch),
          DateTime.now(),
        )!.announcement,
        'سجّلنا وصولك — هننده عليك',
      );

      expect(
        MockInBranch.forBooking(
          bookingFor(MockScenario.inService),
          DateTime.now(),
        )!.announcement,
        'الكرسي جاهز — اتفضل',
      );
    });

    test('«في الخدمة» بيستاهل تنبيه و«وصل» لأ', () {
      final arrived = MockInBranch.forBooking(
        bookingFor(MockScenario.arrivedInBranch),
        DateTime.now(),
      )!;
      final inService = MockInBranch.forBooking(
        bookingFor(MockScenario.inService),
        DateTime.now(),
      )!;

      // «وصلت» العميل عارفها — هو اللي دخل. «الكرسي جاهز» هي اللي
      // تستاهل تقطع عليه.
      expect(arrived.needsAttention, isFalse);
      expect(inService.needsAttention, isTrue);
    });

    test('«مستني» بيستاهل تنبيه لما يقرب بس', () {
      final booking = bookingFor(MockScenario.waitingInBranch);

      var sawQuiet = false;
      var sawAlert = false;
      for (var minute = 0; minute < 60; minute++) {
        final data = MockInBranch.forBooking(
          booking,
          DateTime(2026, 8, 2, 14, minute),
        )!;
        if (data.needsAttention) {
          sawAlert = true;
          expect(data.estimateLow!.inMinutes, lessThanOrEqualTo(5));
        } else {
          sawQuiet = true;
        }
      }

      expect(sawQuiet, isTrue, reason: 'لازم يفضل ساكت وهو لسه بعيد');
      expect(sawAlert, isTrue, reason: 'لازم ينبّه لما يقرب');
    });
  });

  group('الألفاظ', () {
    test('اللابل من ألفاظ السيرفر بالحرف', () {
      // نفس الكلمة اللي الريسيبشن شايفها على الداشبورد — من
      // `backend/lang/ar/status.php`. لو اختلفوا، المكالمة بتفشل.
      expect(
        MockInBranch.forBooking(
          bookingFor(MockScenario.arrivedInBranch),
          DateTime.now(),
        )!.label,
        'في انتظار بدء الخدمة',
      );

      expect(
        MockInBranch.forBooking(
          bookingFor(MockScenario.waitingInBranch),
          DateTime.now(),
        )!.label,
        'في الانتظار',
      );

      expect(
        MockInBranch.forBooking(
          bookingFor(MockScenario.inService),
          DateTime.now(),
        )!.label,
        'في الخدمة',
      );
    });

    test('وقت آخر تحديث بيتقال بالعامية', () {
      final booking = bookingFor(MockScenario.waitingInBranch);
      final now = DateTime(2026, 8, 2, 14, 30);
      final data = MockInBranch.forBooking(booking, now)!;

      expect(data.freshnessLabel(now), 'آخر تحديث: دلوقتي');
      expect(
        data.freshnessLabel(now.add(const Duration(minutes: 1))),
        'آخر تحديث: من دقيقة',
      );
      expect(
        data.freshnessLabel(now.add(const Duration(minutes: 2))),
        'آخر تحديث: من دقيقتين',
      );
      expect(
        data.freshnessLabel(now.add(const Duration(minutes: 5))),
        'آخر تحديث: من 5 دقايق',
      );
    });
  });
}
