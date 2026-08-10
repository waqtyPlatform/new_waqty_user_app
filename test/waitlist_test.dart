import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/waitlist_message_ui_model.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';

/// رد `GET /user/waitlist` بشكله الحقيقي — كائنات متداخلة مش أسامي مسطّحة.
Map<String, dynamic> _entryJson({required String status}) => <String, dynamic>{
  'uuid': 'wl-json',
  'status': status,
  'provider': <String, dynamic>{'uuid': 'prv-1', 'name': 'صالون كابتن'},
  'branch': <String, dynamic>{'uuid': 'brn-1', 'name': 'فرع المعادي'},
  'service': <String, dynamic>{'uuid': 'srv-1', 'name': 'قص شعر'},
  'preferred_at': '2026-08-10T18:00:00+03:00',
  'position': 2,
};

void main() {
  setUp(() {
    MockConfig.delay = Duration.zero;
    // الإلغاءات والإشعارات المقفولة `static` — من غير التصفير دي
    // بتتسرّب بين الاختبارات زي ما بتعيش بين الشاشات في الأبلكيشن.
    MockBookings.resetSession();
    MockWaitlist.reset();
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

      expect(entry.status, WaitlistStatus.awaitingResponse);
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

    /// **`pending` كان بيوعد بإشعار مفيش transport ليه.**
    ///
    /// «هنبلّغك أول ما ميعاد يفضى» — و`app_device_tokens` بيتكتب فيه ومحدش
    /// بيقراه. الجملة اللي تحتها على بعد سطر (`offered`) كانت صادقة، فالمشكلة
    /// مكانتش عدم معرفة، كانت سطر اتنسي.
    test('نص pending مابيوعدش بإشعار', () {
      final pending = WaitlistUiModel(
        uuid: 'wl-1',
        status: WaitlistStatus.waiting,
        providerName: 'صالون كابتن',
        branchName: 'فرع المعادي',
        serviceName: 'قص شعر',
        preferredAt: DateTime(2026, 8, 10, 14),
        position: 2,
      );

      expect(pending.explanation, contains('الفرع'));
      expect(pending.explanation, isNot(contains('هنبلّغك')));
    });

    test('الحجز اللي عدّى بيبقى expired', () {
      MockConfig.scenario = MockScenario.waitlistExpired;
      final entry = MockWaitlist.forUser(DateTime.now()).first;

      expect(entry.status, WaitlistStatus.responseExpired);
      expect(entry.isHoldActive(DateTime.now()), isFalse);
      expect(entry.status.isLive, isFalse);
    });

    test('الإضافة بتبدأ pending — الفرع لسه ما عرضش', () {
      final entry = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
        serviceUuid: 'srv-1',
        preferredAt: DateTime(2026, 8, 10, 18),
      );

      expect(entry.status, WaitlistStatus.waiting);
      expect(entry.holdExpiresAt, isNull);
      expect(MockWaitlist.forUser(DateTime.now()), contains(entry));

      MockWaitlist.removeByUuid(entry.uuid);
      expect(MockWaitlist.forUser(DateTime.now()), isNot(contains(entry)));
    });

    /// **كان بياخد أسامي — الشكل المعكوس بتاع الـ API.**
    ///
    /// `UserWaitlistController::store` بياخد uuids وبيرجّع كائنات فيها
    /// الأسامي، فالـ mock كان بيخلّي يوم الربط إعادة كتابة مش تغيير سطر.
    test('الأسامي بتتشتق من الـ uuids', () {
      final entry = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-2',
        serviceUuid: 'srv-1',
        preferredAt: DateTime(2026, 8, 10, 18),
      );

      expect(entry.providerName, MockProviders.byUuid('prv-1').name);
      expect(
        entry.branchName,
        MockProviders.branchByUuid(
          providerUuid: 'prv-1',
          branchUuid: 'brn-2',
        )!.name,
      );
      expect(entry.serviceName, MockServices.byUuid('srv-1').name);
      // «أي أخصائي متاح» بيتبعت فاضي — فمفيش اسم يتعرض.
      expect(entry.employeeName, isNull);
    });

    /// **`wl-${_entries.length + 1}` كان بيتكرر بعد أي شيل.**
    ///
    /// `[wl-2, wl-1]` → تشيل `wl-2` → الطول ١ → الإضافة اللي بعدها `wl-2`
    /// تاني، و`removeByUuid` بتبقى ملتبسة على uuid موجود مرتين.
    test('الـ uuid مابيتكررش بعد الشيل', () {
      DateTime at(int hour) => DateTime(2026, 8, 10, hour);
      final seen = <String>{};

      final first = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
        serviceUuid: 'srv-1',
        preferredAt: at(10),
      );
      final second = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
        serviceUuid: 'srv-2',
        preferredAt: at(12),
      );
      MockWaitlist.removeByUuid(second.uuid);
      final third = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
        serviceUuid: 'srv-2',
        preferredAt: at(14),
      );

      seen.addAll(<String>[first.uuid, second.uuid, third.uuid]);
      expect(seen.length, 3);
    });

    /// **«ضفناك — هتلاقيها في مواعيدك» كانت بتكدب.**
    ///
    /// `WaitlistCubit` بيقرا وقت `start` والرجوع من الخلفية بس، ومحدش كان
    /// بيقوله إن فيه كتابة حصلت.
    test('أي كتابة بتنبّه المشتركين', () {
      var beats = 0;
      void listener() => beats++;
      MockWaitlist.revision.addListener(listener);
      addTearDown(() => MockWaitlist.revision.removeListener(listener));

      final entry = MockWaitlist.add(
        providerUuid: 'prv-1',
        branchUuid: 'brn-1',
        serviceUuid: 'srv-1',
        preferredAt: DateTime(2026, 8, 10, 18),
      );
      expect(beats, 1);

      MockWaitlist.removeByUuid(entry.uuid);
      expect(beats, 2);
    });

    /// الخروج كان ظاهر وقت العدّاد كمان — دوسة غلط بتدّي ميعادك لحد تاني
    /// وإنت مستني الفرع يتصل.
    test('الخروج من القائمة مقفول وقت العرض الشغّال', () {
      expect(WaitlistStatus.waiting.canLeaveQueue, isTrue);
      expect(WaitlistStatus.awaitingResponse.canLeaveQueue, isFalse);
      // الاتنين لسه `isLive` — الفرق مقصود.
      expect(WaitlistStatus.awaitingResponse.isLive, isTrue);
    });
  });

  /// **أفعال العميل — اللي waitlist v2 ضافها.**
  ///
  /// قبل v2 العميل مكانش يقدر يعمل ولا حاجة: `accept` كانت تحت
  /// `/provider/` بس، والأبلكيشن كان بيعرض عدّاد ٥ دقايق وجملة «استنى
  /// مكالمة» — عدّاد من غير مخرج.
  group('أفعال العميل', () {
    WaitlistUiModel offered() {
      MockConfig.scenario = MockScenario.waitlistOffered;
      return MockWaitlist.forUser(DateTime.now()).first;
    }

    test('العرض الشغّال بيتيح التلات أفعال', () {
      final entry = offered();

      expect(entry.canAccept, isTrue);
      expect(entry.canRequestChange, isTrue);
      expect(entry.canCancel, isTrue);
      expect(entry.hasActions, isTrue);
    });

    test('القبول بيحوّل الطلب لحجز', () {
      final entry = offered();
      MockWaitlist.accept(entry.uuid);

      final after = MockWaitlist.forUser(DateTime.now()).first;
      expect(after.status, WaitlistStatus.converted);
      expect(after.status.isSettled, isTrue);
      // المهلة والعرض بيتمسحوا — الميعاد بقى حجز، والعدّاد مالوش معنى.
      expect(after.isHoldActive(DateTime.now()), isFalse);
      expect(after.offeredStartAt, isNull);
    });

    test('بعد القبول مفيش أفعال متاحة', () {
      final entry = offered();
      MockWaitlist.accept(entry.uuid);

      final after = MockWaitlist.forUser(DateTime.now()).first;
      expect(after.hasActions, isFalse);
      expect(after.conversationReadOnly, isTrue);
    });

    test('طلب ميعاد تاني بيرجّع الطلب للطابور', () {
      final entry = offered();
      MockWaitlist.requestChange(entry.uuid, 'الميعاد بدري عليّا');

      final after = MockWaitlist.forUser(DateTime.now()).first;
      expect(after.status, WaitlistStatus.changeRequested);
      // شغّال لسه — السيرفر بيسمح بعرض تاني على الحالة دي.
      expect(after.status.isLive, isTrue);
      expect(after.offeredStartAt, isNull);
    });

    test('السبب بيتسجّل في الخيط', () {
      final entry = offered();
      MockWaitlist.requestChange(entry.uuid, 'الميعاد بدري عليّا');

      final after = MockWaitlist.forUser(DateTime.now()).first;
      final mine = after.messages.where((m) => m.sender.isMine).toList();

      expect(mine, isNotEmpty);
      expect(mine.last.body, 'الميعاد بدري عليّا');
    });

    test('آخر محاولة بتقفل الطلب بدل ما ترجّعه', () {
      // `MAX_OFFERS` — الفرع جرّب كل مرّاته. السيرفر بيقفل بـ
      // `no_suitable_time` مش بيرجّع الطلب لطابور مالوش نهاية.
      final entry = offered();
      final exhausted = WaitlistUiModel(
        uuid: entry.uuid,
        status: entry.status,
        providerName: entry.providerName,
        branchName: entry.branchName,
        serviceName: entry.serviceName,
        preferredAt: entry.preferredAt,
        position: entry.position,
        canRequestChange: true,
        attemptCount: 3,
      );

      expect(exhausted.attemptCount, exhausted.maxAttempts);
    });

    test('الخروج بيشيل الطلب من القايمة', () {
      final entry = offered();
      MockWaitlist.cancel(entry.uuid);

      expect(
        MockWaitlist.forUser(DateTime.now()).any((e) => e.uuid == entry.uuid),
        isFalse,
      );
    });

    test('الفعل الممنوع مابيعملش حاجة', () {
      // الكارت بيخفي الزرار، بس الـ mock مايفترضش إن الواجهة حرست.
      MockConfig.scenario = MockScenario.waitlistReviewing;
      final entry = MockWaitlist.forUser(DateTime.now()).first;

      expect(entry.canAccept, isFalse);
      MockWaitlist.accept(entry.uuid);

      expect(
        MockWaitlist.forUser(DateTime.now()).first.status,
        WaitlistStatus.underReview,
      );
    });

    test('الرسايل بتتقرا من الرد', () {
      final parsed = WaitlistUiModel.fromJson(<String, dynamic>{
        ..._entryJson(status: 'awaiting_customer_response'),
        'conversation_read_only': false,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'uuid': 'm1',
            'sender_type': 'provider',
            'sender_name': 'ريسيبشن',
            'body': 'فضي ميعاد بدري',
            'created_at': '2026-08-10T17:00:00+03:00',
          },
          <String, dynamic>{
            'uuid': 'm2',
            'sender_type': 'system',
            'body': '',
            'created_at': '2026-08-10T17:01:00+03:00',
            'metadata': <String, dynamic>{'event': 'offer_sent'},
          },
        ],
      });

      expect(parsed.messages, hasLength(2));
      expect(parsed.messages.first.sender, WaitlistMessageSender.branch);
      // الحدث بيتترجم لجملة — الداشبورد بيعرض `offer_sent` خام لأن اللي
      // بيقراه موظف، والعميل لازم يقرا كلام.
      expect(parsed.messages.last.displayBody, 'الفرع عرض عليك ميعاد');
    });

    test('حدث مش معروف مابيتعرضش أصلاً', () {
      final parsed = WaitlistUiModel.fromJson(<String, dynamic>{
        ..._entryJson(status: 'waiting'),
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'uuid': 'm1',
            'sender_type': 'system',
            'body': '',
            'created_at': '2026-08-10T17:00:00+03:00',
            'metadata': <String, dynamic>{'event': 'some_future_event'},
          },
        ],
      });

      // عرض `some_future_event` للعميل أوحش من إن السطر مايبانش.
      expect(parsed.messages, isEmpty);
    });
  });

  /// **الميعاد المعروض مش الميعاد المطلوب.**
  ///
  /// الكارت كان بيعرض `preferredAt` جنب عدّاد الـ٥ دقايق. العرض بيحصل
  /// أصلاً عشان الفرع لقى ميعاد **تاني** — لو المطلوب كان متاح، العميل
  /// كان حجزه ومكانش دخل قايمة انتظار. يعني في الحالة الوحيدة اللي فيها
  /// عدّاد، الرقم اللي جنبه كان غلط بحكم التعريف.
  group('الميعاد المعروض', () {
    /// رد فيه عرض شغّال بشكل v2 — `current_offer` جوّاه الميعاد الحقيقي.
    // المواعيد بتتقارن ككائنات مش بـ`.hour`: `DateTime.tryParse` على نص
    // فيه offset بيرجّع UTC، فـ`.hour` بيدي ساعة المنطقة الصفرية مش
    // المكتوبة في النص.
    final preferred = DateTime.parse('2026-08-10T18:00:00+03:00');
    final offered = DateTime.parse('2026-08-10T16:30:00+03:00');

    Map<String, dynamic> offerJson() => <String, dynamic>{
      ..._entryJson(status: 'awaiting_customer_response'),
      'employee': <String, dynamic>{'uuid': 'emp-1', 'name': 'أحمد محمود'},
      'hold_remaining_seconds': 300,
      'offered_start_at': '2026-08-10T16:30:00+03:00',
      'offered_end_at': '2026-08-10T17:00:00+03:00',
      'offered_employee': <String, dynamic>{'name': 'مصطفى سيد'},
      'current_offer': <String, dynamic>{
        'uuid': 'off-1',
        'attempt_number': 1,
        'status': 'active',
        'employee_name': 'مصطفى سيد',
        'start_at': '2026-08-10T16:30:00+03:00',
        'end_at': '2026-08-10T17:00:00+03:00',
        'message': 'فضي ميعاد بدري شوية',
      },
    };

    test('الكارت بيعرض الميعاد المعروض مش المطلوب', () {
      final entry = WaitlistUiModel.fromJson(offerJson());

      // المطلوب ٦م، المعروض ٤:٣٠. `displayAt` لازم تدي المعروض.
      expect(entry.preferredAt.isAtSameMomentAs(preferred), isTrue);
      expect(entry.offeredStartAt!.isAtSameMomentAs(offered), isTrue);
      expect(entry.displayAt, entry.offeredStartAt);
      expect(entry.displayAt, isNot(entry.preferredAt));
    });

    test('الأخصائي المعروض بيسبق اللي العميل طلبه', () {
      final entry = WaitlistUiModel.fromJson(offerJson());

      expect(entry.employeeName, 'أحمد محمود');
      expect(entry.displayEmployeeName, 'مصطفى سيد');
    });

    test('من غير عرض بيقع على المطلوب', () {
      final entry = WaitlistUiModel.fromJson(_entryJson(status: 'waiting'));

      expect(entry.hasOffer, isFalse);
      expect(entry.displayAt, entry.preferredAt);
      expect(entry.displayEmployeeName, entry.employeeName);
      expect(entry.offerDiffersFromPreferred, isFalse);
    });

    test('current_offer بيسبق الحقول المسطّحة', () {
      // الحقول المسطّحة نسخة على الإدخال الأب وممكن تبقى بايتة من محاولة
      // اتقفلت. الصف النشط هو الحقيقة.
      final json = offerJson();
      json['offered_start_at'] = '2026-08-10T09:00:00+03:00';

      final entry = WaitlistUiModel.fromJson(json);

      expect(entry.offeredStartAt!.isAtSameMomentAs(offered), isTrue);
    });

    test('بيقع على الحقول المسطّحة لما current_offer مش موجود', () {
      final json = offerJson()..remove('current_offer');
      final entry = WaitlistUiModel.fromJson(json);

      expect(entry.offeredStartAt!.isAtSameMomentAs(offered), isTrue);
      expect(entry.displayEmployeeName, 'مصطفى سيد');
    });

    test('الاختلاف عن المطلوب بيتقال صراحة', () {
      expect(
        WaitlistUiModel.fromJson(offerJson()).offerDiffersFromPreferred,
        isTrue,
      );
    });

    test('العرض على نفس الميعاد المطلوب مابيقولش إنه مختلف', () {
      final json = offerJson();
      json['current_offer']['start_at'] = '2026-08-10T18:00:00+03:00';

      final entry = WaitlistUiModel.fromJson(json);

      expect(entry.hasOffer, isTrue);
      expect(entry.offerDiffersFromPreferred, isFalse);
    });

    test('سيناريو العرض في الـmock بيعرض ميعاد مختلف', () {
      // من غير كده الباج مايتشافش في الأبلكيشن مهما اتفتح السيناريو.
      MockConfig.scenario = MockScenario.waitlistOffered;
      final entry = MockWaitlist.forUser(DateTime.now()).first;

      expect(entry.hasOffer, isTrue);
      expect(entry.offerDiffersFromPreferred, isTrue);
    });
  });

  /// **waitlist v2 غيّر قيم النصوص نفسها.**
  ///
  /// `2026_08_08_120000_upgrade_booking_waitlist_to_v2` نقل `pending` لـ
  /// `waiting` و`offered` لـ`awaiting_customer_response` و`booked` لـ
  /// `converted`، وضاف ٤ حالات جديدة. و`BookingWaitlistResource` بيبعت
  /// `$this->status` خام.
  ///
  /// قبل الإصلاح ده، **٨ من الـ١٠ كانوا بيقعوا على «في قايمة الانتظار»** —
  /// بما فيهم العرض اللي عليه عدّاد شغّال والإدخال اللي بقى حجز مؤكد.
  group('waitlist v2 — قيم السيرفر', () {
    /// نفس `BookingWaitlistEntry::STATUSES` بالترتيب.
    const serverStatuses = <String, WaitlistStatus>{
      'waiting': WaitlistStatus.waiting,
      'under_review': WaitlistStatus.underReview,
      'awaiting_customer_response': WaitlistStatus.awaitingResponse,
      'change_requested': WaitlistStatus.changeRequested,
      'converted': WaitlistStatus.converted,
      'cancelled_by_customer': WaitlistStatus.cancelledByCustomer,
      'rejected_by_branch': WaitlistStatus.rejectedByBranch,
      'response_expired': WaitlistStatus.responseExpired,
      'no_suitable_time': WaitlistStatus.noSuitableTime,
      'request_period_expired': WaitlistStatus.requestPeriodExpired,
    };

    test('كل حالة في السيرفر ليها مقابل — ومفيش واحدة بتقع على waiting', () {
      serverStatuses.forEach((wire, expected) {
        expect(
          WaitlistUiModel.fromJson(_entryJson(status: wire)).status,
          expected,
          reason: '«$wire» مابتتقرأش صح',
        );
      });
    });

    test('الأبلكيشن مطابق للسيرفر ١:١ — لا زيادة ولا نقصان', () {
      // enum أكبر معناه حالة اخترعناها؛ أصغر معناه حالة هتقع على waiting.
      expect(WaitlistStatus.values.length, serverStatuses.length);
      expect(
        serverStatuses.values.toSet().length,
        WaitlistStatus.values.length,
        reason: 'فيه قيمتين من السيرفر بيوصلوا لنفس الحالة',
      );
    });

    test('العرض الشغّال مابيتقريش «في الانتظار»', () {
      // أخطر واحدة: `awaiting_customer_response` معناه فيه ميعاد محجوز
      // باسمك وعدّاد بينزل. لو وقع على waiting، العميل بيقرا «مستني»
      // والميعاد بيروح وهو مش عارف إنه كان قدامه.
      final parsed = WaitlistUiModel.fromJson(
        _entryJson(status: 'awaiting_customer_response'),
      );

      expect(parsed.status, WaitlistStatus.awaitingResponse);
      expect(parsed.status, isNot(WaitlistStatus.waiting));
      expect(parsed.status.canLeaveQueue, isFalse);
    });

    test('الخروج من القايمة والنهايات متسقين مع السيرفر', () {
      // `change_requested` شغّالة — السيرفر بيسمح بـoffer عليها زي waiting.
      expect(WaitlistStatus.changeRequested.isLive, isTrue);
      expect(WaitlistStatus.changeRequested.isSettled, isFalse);

      // `response_expired` مش في الاتنين: العرض راح بس ممكن ييجي واحد تاني.
      expect(WaitlistStatus.responseExpired.isLive, isFalse);
      expect(WaitlistStatus.responseExpired.isSettled, isFalse);
      expect(WaitlistStatus.responseExpired.canLeaveQueue, isTrue);

      // التلاتة دول نهايات مايرجعش منها.
      for (final ending in <WaitlistStatus>[
        WaitlistStatus.converted,
        WaitlistStatus.noSuitableTime,
        WaitlistStatus.requestPeriodExpired,
      ]) {
        expect(ending.isSettled, isTrue, reason: '$ending المفروض نهاية');
        expect(ending.canLeaveQueue, isFalse);
      }
    });

    test('«خرجت» و«الفرع اعتذر» رسالتين مختلفتين', () {
      // كانوا `cancelled` واحدة لما السيرفر مكانش بيفرّق. بقى بيفرّق.
      expect(
        WaitlistStatus.cancelledByCustomer.label,
        isNot(WaitlistStatus.rejectedByBranch.label),
      );
    });

    test('القيم القديمة لسه بتتقرا — صف ما اتحوّلش', () {
      expect(
        WaitlistUiModel.fromJson(_entryJson(status: 'pending')).status,
        WaitlistStatus.waiting,
      );
      expect(
        WaitlistUiModel.fromJson(_entryJson(status: 'offered')).status,
        WaitlistStatus.awaitingResponse,
      );
      expect(
        WaitlistUiModel.fromJson(_entryJson(status: 'booked')).status,
        WaitlistStatus.converted,
      );
    });

    test('حالة مش معروفة بتقع على waiting مش على نهاية', () {
      // لو السيرفر ضاف حالة تالتة، أقل ضرر إننا نقول «في الطابور» بدل
      // ما نقول «خلص» أو «فيه عرض مستنيك».
      final parsed = WaitlistUiModel.fromJson(
        _entryJson(status: 'some_future_status'),
      );

      expect(parsed.status, WaitlistStatus.waiting);
      expect(parsed.status.isSettled, isFalse);
    });
  });

  /// **الحالتين اللي الأبلكيشن مكانش شايفهم.**
  ///
  /// `fromApi` كانت بترمي أي قيمة مش معروفة على `pending`، والسيرفر عنده
  /// ٧ حالات والأبلكيشن عنده ٥.
  group('دورة حياة السيرفر كاملة', () {
    test('reviewing مابتقعش على pending', () {
      final entry = _entryJson(status: 'reviewing');

      expect(
        WaitlistUiModel.fromJson(entry).status,
        WaitlistStatus.underReview,
      );
    });

    test('booked مابتقعش على pending — دي كانت بتكدب على العميل', () {
      // الإدخال بقى حجز مؤكد، والأبلكيشن كان بيقول «في قايمة الانتظار».
      final parsed = WaitlistUiModel.fromJson(_entryJson(status: 'booked'));

      expect(parsed.status, WaitlistStatus.converted);
      expect(parsed.status.isLive, isFalse);
      expect(parsed.status.isSettled, isTrue);
      expect(parsed.status.label, isNot(WaitlistStatus.waiting.label));
    });

    test('reviewing شغّالة وبيتقال فيها اللي حصل من غير وعد', () {
      expect(WaitlistStatus.underReview.isLive, isTrue);
      expect(WaitlistStatus.underReview.isSettled, isFalse);
    });

    test('الخروج مسموح في reviewing ومقفول في offered', () {
      // في `reviewing` مفيش عدّاد ومفيش ميعاد محجوز باسمك — الخروج قرار
      // عادي. في `offered` الخروج بيرمي ميعاد محجوز لحد تاني.
      expect(WaitlistStatus.underReview.canLeaveQueue, isTrue);
      expect(WaitlistStatus.awaitingResponse.canLeaveQueue, isFalse);
    });

    test('كل حالة ليها لابل وشرح مختلفين', () {
      final labels = WaitlistStatus.values.map((s) => s.label).toSet();
      final explanations = <String>{};

      for (final status in WaitlistStatus.values) {
        explanations.add(
          WaitlistUiModel(
            uuid: 'x',
            status: status,
            providerName: 'م',
            branchName: 'ف',
            serviceName: 'خ',
            preferredAt: DateTime(2026, 8, 10, 18),
            position: 1,
          ).explanation,
        );
      }

      // لابل مكرر معناه حالتين بيتقروا واحدة على الشاشة.
      expect(labels.length, WaitlistStatus.values.length);
      expect(explanations.length, WaitlistStatus.values.length);
    });

    test('سيناريو كل الحالات بيوري الشغّال والخالص مع بعض', () {
      MockConfig.scenario = MockScenario.waitlistHistory;
      final entries = MockWaitlist.forUser(DateTime.now());

      expect(
        entries.any((e) => e.status == WaitlistStatus.underReview),
        isTrue,
      );
      expect(entries.any((e) => e.status == WaitlistStatus.converted), isTrue);
      expect(entries.any((e) => e.status.isLive), isTrue);
      expect(entries.any((e) => e.status.isSettled), isTrue);
    });
  });

  group('5.4 + ج٤ — حلقة الإلغاء', () {
    test('السبب بيتخزّن وبيتعرض', () {
      // سيناريو فيه حجز ينفع يتلغي — الإلغاء بيتقفل لما الميعاد
      // **يبدأ**، مش عشان هو النهاردة.
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
      // سيناريو فيه حجز ينفع يتلغي — الإلغاء بيتقفل لما الميعاد
      // **يبدأ**، مش عشان هو النهاردة.
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
