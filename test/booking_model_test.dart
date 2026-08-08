import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';

/// اختبارات طبقة الموديل.
///
/// **الغرض منها يوم الربط مش النهاردة.** الـ `fromJson` اتكتبت عشان
/// تمتص شكل الرد الحقيقي — أسعار كنصوص، مفاتيح `snake_case`، وشكلين
/// مختلفين للمواعيد. اللي مش متغطى باختبار هنا هو اللي هيقع ساعتها.
void main() {
  group('BookingUiModel.fromJson', () {
    test('بيقرا السعر وهو نص — السيرفر بيبعت "150.00" مش 150.0', () {
      final booking = BookingUiModel.fromJson(_bookingJson());

      // `decimal:2` في Laravel بيرجّع نص. `as double` عليه بيرمي TypeError
      // على شاشة ليستة الحجوزات — أول شاشة أي حد بيفتحها.
      expect(booking.items.first.price, 150.0);
      expect(booking.items.last.price, 300.0);
      // الإجمالي **مجموع العناصر** مش سعر أول واحد.
      expect(booking.price, 450.0);
    });

    test('بياخد العناصر من visits[].items[] ومعاها visit_uuid', () {
      final booking = BookingUiModel.fromJson(_bookingJson());

      expect(booking.items.length, 2);
      expect(booking.items.first.visitUuid, 'vst-1');
      expect(booking.items.last.visitUuid, 'vst-2');
      // زيارتين مش واحدة — التجميع من `visit_uuid` مش من التاريخ.
      expect(booking.visits.length, 2);
    });

    test('بيقع على items المسطّحة لما visits مش موجودة', () {
      // `GET /user/bookings` (الليستة) مابيحمّلش `visits` — الحقل مش
      // موجود في الرد أصلاً، مش فاضي.
      final json = _bookingJson()..remove('visits');
      json['items'] = <Map<String, dynamic>>[
        _itemJson(uuid: 'itm-9', price: '99.50'),
      ];

      final booking = BookingUiModel.fromJson(json);

      expect(booking.items.length, 1);
      expect(booking.items.first.price, 99.5);
    });

    test('reference أول ٨ حروف من الـ ULID من غير #', () {
      final booking = BookingUiModel.fromJson(_bookingJson());

      // الداشبورد بيعرض `substr($booking->uuid, 0, 8)` من غير أي بادئة.
      // أي `#` هنا بيخلي العميل يقرا حاجة الموظف مش شايفها.
      expect(booking.reference, '01K1M9Q4');
      expect(booking.reference.contains('#'), isFalse);
    });

    test('بيحوّل حالات السيرفر لحالات الأبلكيشن', () {
      for (final entry in <String, BookingStatus>{
        'confirmed': BookingStatus.confirmed,
        'arrived': BookingStatus.arrived,
        'waiting': BookingStatus.waiting,
        'in_progress': BookingStatus.inProgress,
        'completed': BookingStatus.completed,
        'cancelled': BookingStatus.cancelled,
        'no_show': BookingStatus.noShow,
      }.entries) {
        final json = _bookingJson()..['status'] = entry.key;
        expect(BookingUiModel.fromJson(json).status, entry.value);
      }
    });

    test('pending و scheduled القديمين بيتحوّلوا confirmed', () {
      // السيرفر نفسه عمل migration نقلهم، و`STATUS_PENDING` بقى alias
      // لـ `confirmed` و`@deprecated`. بنعمل نفس الحاجة بدل ما نطلّع
      // حالة تانية العميل مايشوفهاش أبدًا.
      for (final legacy in <String>['pending', 'scheduled', 'whatever']) {
        final json = _bookingJson()..['status'] = legacy;
        expect(BookingUiModel.fromJson(json).status, BookingStatus.confirmed);
      }
    });

    test('بيجمّع سعر ما قبل الخصم من العناصر', () {
      final json = _bookingJson();
      final visits = json['visits'] as List<Map<String, dynamic>>;
      (visits.first['items'] as List<Map<String, dynamic>>).first['original_price'] =
          '200.00';

      final booking = BookingUiModel.fromJson(json);

      expect(booking.hasDiscount, isTrue);
      // ٢٠٠ (قبل الخصم) + ٣٠٠ (من غير خصم) = ٥٠٠
      expect(booking.originalPrice, 500.0);
      expect(booking.price, 450.0);
    });

    test('من غير خصم بيرجّع null مش نفس السعر', () {
      final booking = BookingUiModel.fromJson(_bookingJson());

      expect(booking.hasDiscount, isFalse);
      expect(booking.originalPrice, isNull);
    });
  });

  group('SlotUiModel.fromJson — الشكلين', () {
    test('أخصائي محدد: فيه price و effective_price واسم', () {
      final slot = SlotUiModel.fromJson(<String, dynamic>{
        'start_at': '2026-08-10T18:00:00+03:00',
        'end_at': '2026-08-10T18:45:00+03:00',
        'duration_minutes': 45,
        'price': '250.00',
        'effective_price': '250.00',
        'currency': 'EGP',
        'employee': <String, dynamic>{'uuid': 'emp-1', 'name': 'أحمد محمود'},
      });

      expect(slot.price, 250.0);
      expect(slot.employeeName, 'أحمد محمود');
      expect(slot.availableEmployeesCount, isNull);
    });

    test('أي أخصائي: **مفيش مفتاح price خالص** — لازم يعدّي', () {
      // ده المسار الافتراضي في الأبلكيشن، يعني ده اللي كان هيقع أول
      // ما يتربط لو الموديل بيقرا `price` مباشرة.
      final slot = SlotUiModel.fromJson(<String, dynamic>{
        'start_at': '2026-08-10T18:00:00+03:00',
        'duration_minutes': 45,
        'effective_price': '250.00',
        'currency': 'EGP',
        'available_employees_count': 3,
        'employees': <Map<String, dynamic>>[
          <String, dynamic>{'uuid': 'emp-1', 'name': 'أحمد محمود'},
          <String, dynamic>{'uuid': 'emp-2', 'name': 'محمد سيد'},
          <String, dynamic>{'uuid': 'emp-3', 'name': 'مصطفى خالد'},
        ],
      });

      expect(slot.price, 250.0);
      expect(slot.availableEmployeesCount, 3);
      // **مفيش اسم** — التوزيع بيحصل وقت الحفظ، وأي اسم هنا تخمين.
      expect(slot.employeeName, isEmpty);
    });

    test('بيحسب end_at من المدة لما مش موجودة', () {
      final slot = SlotUiModel.fromJson(<String, dynamic>{
        'start_at': '2026-08-10T18:00:00+03:00',
        'duration_minutes': 45,
        'effective_price': 250,
      });

      expect(slot.durationMinutes, 45);
    });

    test('بيحتفظ بنص start_at الخام للـ payload', () {
      const raw = '2026-08-10T18:00:00+03:00';
      final slot = SlotUiModel.fromJson(<String, dynamic>{
        'start_at': raw,
        'duration_minutes': 45,
        'effective_price': 250,
      });

      // إعادة بناء التاريخ بتخاطر بإزاحة بين توقيت الفرع وتوقيت الجهاز.
      expect(slot.startAtPayload, raw);
    });
  });

  group('التقييم لكل خدمة', () {
    test('حجز بتلات خدمات = تلات تقييمات مستقلة', () {
      MockConfig.scenario = MockScenario.completedUnrated;
      final booking = MockBookings.past.first;

      expect(booking.items.length, 3);
      expect(booking.rateableItems.length, 3);
      expect(booking.hasPendingRatings, isTrue);
    });

    test('تقييم خدمة واحدة بيسيب الباقي قابل للتقييم', () {
      MockConfig.scenario = MockScenario.completedUnrated;
      final booking = MockBookings.past.first;

      booking.items.first
        ..rating = 5
        ..ratingStatus = RatingStatus.pending;

      // ده بالظبط اللي `myRating` القديمة كانت بتكسره: أول تقييم كان
      // بيخفي الزرار والاتنين التانيين مايتقيّموش أبدًا.
      expect(booking.rateableItems.length, 2);
      expect(booking.hasPendingRatings, isTrue);
    });

    test('pending مش بيتحسب قابل لإعادة التقييم', () {
      MockConfig.scenario = MockScenario.completedPartiallyRated;
      final booking = MockBookings.past.first;

      expect(booking.items.length, 2);
      expect(booking.rateableItems, isEmpty);
      expect(booking.hasPendingRatings, isFalse);
    });

    test('حجز مش مكتمل مالوش تقييم أصلاً', () {
      MockConfig.scenario = MockScenario.happyPath;
      final booking = MockBookings.upcoming.first;

      expect(booking.status.canRate, isFalse);
      expect(booking.rateableItems, isEmpty);
    });

    /// **الأبلكيشن كان بيسأل العميل يكتب رأيه وبيرميه.**
    ///
    /// `rateCommentController` كان بيتعمل وبيتمسح وبيتربط في الشاشة
    /// وبيتـ dispose — وولا سطر بيقرا `.text`.
    group('تعليق التقييم', () {
      test('بيتقرا من الرد', () {
        final item = BookingItemUiModel.fromJson(<String, dynamic>{
          'uuid': 'itm-1',
          'visit_uuid': 'v1',
          'service': <String, dynamic>{'uuid': 'srv-1', 'name': 'قص شعر'},
          'employee': <String, dynamic>{'name': 'أحمد'},
          'start_at': '2026-08-01 14:00:00',
          'duration_minutes': 45,
          'booked_price': 250,
          'rating': <String, dynamic>{
            'rating': 5,
            'status': 'published',
            'comment': 'ممتاز',
          },
        });

        expect(item.rating, 5);
        expect(item.ratingComment, 'ممتاز');
      });

      test('مفيش تعليق = نص فاضي مش null', () {
        final item = BookingItemUiModel.fromJson(<String, dynamic>{
          'uuid': 'itm-2',
          'visit_uuid': 'v1',
          'service': <String, dynamic>{'uuid': 'srv-1', 'name': 'قص شعر'},
          'employee': <String, dynamic>{'name': 'أحمد'},
          'start_at': '2026-08-01 14:00:00',
          'duration_minutes': 45,
          'booked_price': 250,
        });

        expect(item.ratingComment, isEmpty);
      });

      test('الفيكستشر المنشورة عليها تعليق يتعرض', () {
        MockConfig.scenario = MockScenario.completedPartiallyRated;
        final booking = MockBookings.past.first;

        final published = booking.items.firstWhere(
          (i) => i.ratingStatus == RatingStatus.published,
        );
        expect(published.ratingComment, isNotEmpty);
      });
    });
  });

  group('السيناريوهات', () {
    tearDown(() => MockConfig.scenario = MockScenario.happyPath);

    test('حالات الفرع بتطلّع حجز النهاردة بالحالة الصح', () {
      for (final entry in <MockScenario, BookingStatus>{
        MockScenario.arrivedInBranch: BookingStatus.arrived,
        MockScenario.waitingInBranch: BookingStatus.waiting,
        MockScenario.inService: BookingStatus.inProgress,
      }.entries) {
        MockConfig.scenario = entry.key;
        final booking = MockBookings.upcoming.single;

        expect(booking.status, entry.value);
        expect(booking.status.isInBranch, isTrue);
        expect(booking.status.isUpcoming, isTrue);
      }
    });

    test('السيناريو بيضيّق الليستة على الحالة المعروضة', () {
      MockConfig.scenario = MockScenario.multiVisitTwoDays;
      final booking = MockBookings.upcoming.single;

      expect(booking.visits.length, 2);
      expect(booking.isMultiService, isTrue);
    });

    test('byUuid بيلاقي الحجز حتى لو السيناريو مخبّيه', () {
      MockConfig.scenario = MockScenario.happyPath;
      final hidden = MockScenario.noShow;

      MockConfig.scenario = hidden;
      // بعد 6.2 «اللي ما حضرش» بقى إشعار مش صف في «السابقة».
      final target = MockBookings.notices.single;

      MockConfig.scenario = MockScenario.happyPath;
      // الشاشة بتتفتح بـ uuid — لو الدوران بيتم في الليستة المفلترة
      // كانت هتوقع على أول حاجة في القايمة وتعرض حجز تاني خالص.
      expect(MockBookings.byUuid(target.uuid).uuid, target.uuid);
      expect(MockBookings.byUuid(target.uuid).status, BookingStatus.noShow);
    });

    test('networkError و slowNetwork بيوصلوا للقيم الفعلية', () {
      MockConfig.scenario = MockScenario.networkError;
      expect(MockConfig.isErrorForced, isTrue);

      MockConfig.scenario = MockScenario.slowNetwork;
      expect(MockConfig.isErrorForced, isFalse);
      expect(MockConfig.effectiveDelay.inSeconds, 3);
    });

    test('السويتشات اليدوية بتفضل شغالة فوق أي سيناريو', () {
      // متعامدة مش بديلة — لازم ينفع نشغّل `arrivedInBranch` مع خطأ.
      MockConfig.scenario = MockScenario.arrivedInBranch;
      MockConfig.forceError = true;

      expect(MockConfig.isErrorForced, isTrue);

      MockConfig.forceError = false;
    });
  });
}

Map<String, dynamic> _bookingJson() => <String, dynamic>{
  'uuid': '01K1M9Q4T7B8XC2VF6ND3RGZPW',
  'status': 'confirmed',
  'payment_status': 'unpaid',
  'currency': 'EGP',
  'can_cancel': true,
  'notes': '',
  'cancellation_reason': '',
  'provider': <String, dynamic>{'uuid': 'prv-1', 'name': 'صالون كابتن'},
  'branch': <String, dynamic>{
    'uuid': 'brn-1',
    'name': 'فرع المعادي',
    'address': '١٢ شارع ٩',
  },
  'visits': <Map<String, dynamic>>[
    <String, dynamic>{
      'uuid': 'vst-1',
      'items': <Map<String, dynamic>>[_itemJson(uuid: 'itm-1', price: '150.00')],
    },
    <String, dynamic>{
      'uuid': 'vst-2',
      'items': <Map<String, dynamic>>[_itemJson(uuid: 'itm-2', price: '300.00')],
    },
  ],
};

Map<String, dynamic> _itemJson({required String uuid, required String price}) =>
    <String, dynamic>{
      'uuid': uuid,
      'start_at': '2026-08-10T18:00:00+03:00',
      'duration_minutes': 45,
      'booked_price': price,
      'service': <String, dynamic>{'uuid': 'srv-1', 'name': 'قص شعر'},
      'employee': <String, dynamic>{'uuid': 'emp-1', 'name': 'أحمد محمود'},
    };
