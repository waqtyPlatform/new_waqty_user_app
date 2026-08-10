import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_state.dart';

/// الـ payload لازم يطابق `StoreBookingRequest` في السيرفر بالحرف:
///
/// ```php
/// 'visits'                          => ['array','min:1','max:20'],
/// 'visits.*.items'                  => ['required','array','min:1','max:50'],
/// 'visits.*.items.*.service_uuid'   => ['required','exists:services,uuid'],
/// 'visits.*.items.*.employee_uuid'  => ['nullable','exists:employees,uuid'],
/// 'visits.*.items.*.start_at'       => ['required','date_format:Y-m-d\TH:i:sP'],
/// ```
///
/// التستات دي بتقفل على الحتة اللي `flutter analyze` مايقدرش يشوفها:
/// الشكل بيفضل صح شكليًا لحد ما الـ API يترتبط وساعتها بيرجع 422.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// صيغة `Y-m-d\TH:i:sP` — بالثواني وبإزاحة المنطقة الزمنية.
  final startAtFormat = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$',
  );

  CreateBookingCubit buildCubit() =>
      CreateBookingCubit(providerUuid: 'prv-1', providerName: 'صالون كابتن');

  /// بيحط ميعاد في عنصر من غير ما يعدّي على التحميل غير المتزامن.
  void schedule(
    CreateBookingCubit cubit,
    String serviceUuid, {
    required int inDays,
    required int atHour,
    int atMinute = 0,
    EmployeeUiModel? employee,
  }) {
    final item = cubit.items.firstWhere((i) => i.service.uuid == serviceUuid);
    final now = DateTime.now();
    final startAt = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: inDays, hours: atHour, minutes: atMinute));

    if (employee != null) item.employee = employee;
    item.selectedSlot = SlotUiModel(
      startAt: startAt,
      endAt: startAt.add(Duration(minutes: item.service.durationMinutes)),
      price: item.service.price,
      employeeName: 'أحمد محمود',
    );
  }

  group('buildPayload', () {
    test('خدمة واحدة تطلع زيارة واحدة بعنصر واحد', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);

      final payload = cubit.buildPayload();
      final visits = payload['visits'] as List;

      expect(visits, hasLength(1));
      expect((visits.first as Map)['items'], hasLength(1));
      expect(payload['branch_uuid'], isNotNull);
    });

    test('«أي أخصائي متاح» بيشيل employee_uuid خالص مش بيبعته فاضي', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);

      final visits = cubit.buildPayload()['visits'] as List;
      final item = ((visits.first as Map)['items'] as List).first as Map;

      // لو بعتنا `''` السيرفر بيرفضها في `exists:employees,uuid`.
      expect(item.containsKey('employee_uuid'), isFalse);
    });

    test('أخصائي محدد بيتبعت بالـ uuid بتاعه', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      schedule(
        cubit,
        'srv-1',
        inDays: 2,
        atHour: 18,
        employee: const EmployeeUiModel(
          uuid: 'emp-9',
          name: 'أحمد محمود',
          imagePath: '',
          price: 300,
          durationMinutes: 45,
        ),
      );

      final visits = cubit.buildPayload()['visits'] as List;
      final item = ((visits.first as Map)['items'] as List).first as Map;

      expect(item['employee_uuid'], 'emp-9');
    });

    test('تلات خدمات في يوم واحد = زيارة واحدة بتلات عناصر مرتبة بالوقت', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));
      cubit.toggleService(MockServices.byUuid('srv-5'));

      // بالقصد مش بالترتيب — التجميع لازم يرتّبهم.
      schedule(cubit, 'srv-5', inDays: 4, atHour: 20);
      schedule(cubit, 'srv-1', inDays: 4, atHour: 18);
      schedule(cubit, 'srv-2', inDays: 4, atHour: 19);

      final visits = cubit.buildPayload()['visits'] as List;
      expect(visits, hasLength(1));

      final items = (visits.first as Map)['items'] as List;
      expect(items, hasLength(3));
      expect(items.map((i) => (i as Map)['service_uuid']).toList(), <String>[
        'srv-1',
        'srv-2',
        'srv-5',
      ]);
    });

    test('خدمتين في يومين = زيارتين مرتبتين بالتاريخ', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-2', inDays: 9, atHour: 13);
      schedule(cubit, 'srv-1', inDays: 3, atHour: 11);

      final visits = cubit.buildPayload()['visits'] as List;
      expect(visits, hasLength(2));

      expect(
        ((visits[0] as Map)['items'] as List).first,
        containsPair('service_uuid', 'srv-1'),
      );
      expect(
        ((visits[1] as Map)['items'] as List).first,
        containsPair('service_uuid', 'srv-2'),
      );
    });

    test('start_at بصيغة Y-m-d\\TH:i:sP بالثواني والإزاحة', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);

      final visits = cubit.buildPayload()['visits'] as List;
      final item = ((visits.first as Map)['items'] as List).first as Map;

      expect(item['start_at'] as String, matches(startAtFormat));
    });

    test('scheduled_start_at مش بتتبعت — السيرفر بيحسبها', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);

      final visits = cubit.buildPayload()['visits'] as List;
      expect((visits.first as Map).containsKey('scheduled_start_at'), isFalse);
    });

    test('الخدمات من غير ميعاد مابتدخلش الـ payload', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));
      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);

      final visits = cubit.buildPayload()['visits'] as List;
      expect(visits, hasLength(1));
      expect((visits.first as Map)['items'], hasLength(1));
    });
  });

  // الزيارة = رحلة للمحل، مش يوم. اليوم الواحد ممكن يكون رحلتين، والسيرفر
  // بياخد التجميع زي ما بيتبعت من غير ما يراجعه — و`checkInVisit` بيسجّل
  // وصول واحد للزيارة كلها، فدمج غلط بيخلي العميل «واصل» عشر ساعات.
  group('تجميع الزيارات', () {
    test('فارق صغير في نفس اليوم = رحلة واحدة', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1')); // ٤٥ دقيقة
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10); // بتخلص ١٠:٤٥
      schedule(cubit, 'srv-2', inDays: 2, atHour: 11); // فارق ١٥ دقيقة

      expect(cubit.visits, hasLength(1));
      expect((cubit.buildPayload()['visits'] as List), hasLength(1));
    });

    test('فارق أكتر من ساعتين في نفس اليوم = رحلتين', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10); // بتخلص ١٠:٤٥
      schedule(cubit, 'srv-2', inDays: 2, atHour: 20); // فارق ٩ ساعات وربع

      expect(cubit.visits, hasLength(2));

      final visits = cubit.buildPayload()['visits'] as List;
      expect(visits, hasLength(2));
      expect((visits[0] as Map)['items'], hasLength(1));
      expect((visits[1] as Map)['items'], hasLength(1));
    });

    test('ساعتين بالظبط لسه رحلة واحدة — الحد صارم', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10); // بتخلص ١٠:٤٥
      schedule(cubit, 'srv-2', inDays: 2, atHour: 12, atMinute: 45);

      expect(cubit.visits, hasLength(1));
    });

    test('العميل يقدر يدمج رحلتين اتفصلوا تلقائيًا', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10);
      schedule(cubit, 'srv-2', inDays: 2, atHour: 20);
      expect(cubit.visits, hasLength(2));

      final second = cubit.items.firstWhere((i) => i.service.uuid == 'srv-2');
      cubit.toggleBoundary(second.key);

      expect(cubit.visits, hasLength(1));
      expect((cubit.buildPayload()['visits'] as List), hasLength(1));
    });

    test('العميل يقدر يفصل رحلة واحدة لاتنين', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10);
      schedule(cubit, 'srv-2', inDays: 2, atHour: 11);
      expect(cubit.visits, hasLength(1));

      final second = cubit.items.firstWhere((i) => i.service.uuid == 'srv-2');
      cubit.toggleBoundary(second.key);

      expect(cubit.visits, hasLength(2));
    });

    test('يومين مختلفين رحلتين دايمًا — والدمج مالوش تأثير', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);
      schedule(cubit, 'srv-2', inDays: 3, atHour: 18);

      expect(cubit.visits, hasLength(2));

      final second = cubit.items.firstWhere((i) => i.service.uuid == 'srv-2');
      cubit.toggleBoundary(second.key);

      // مفيش رحلة واحدة بتمتد على يومين.
      expect(cubit.visits, hasLength(2));
      expect(cubit.boundaryBefore(second), isNull);
    });

    test('تغيير الميعاد بيلغي التعديل اليدوي', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      schedule(cubit, 'srv-1', inDays: 2, atHour: 10);
      schedule(cubit, 'srv-2', inDays: 2, atHour: 11);

      final second = cubit.items.firstWhere((i) => i.service.uuid == 'srv-2');
      cubit.toggleBoundary(second.key); // فصل يدوي
      expect(cubit.visits, hasLength(2));

      // الوقت اتغيّر — التعديل كان جواب على أوقات بعينها فبيسقط.
      final now = DateTime.now();
      final startAt = DateTime(now.year, now.month, now.day + 2, 11, 30);
      cubit.selectSlot(
        second.key,
        SlotUiModel(
          startAt: startAt,
          endAt: startAt.add(const Duration(minutes: 20)),
          price: 120,
        ),
      );

      expect(cubit.visits, hasLength(1));
    });

    test('الفارق الصغير مالوش زرار — والكبير ليه', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      // ١٥ دقيقة — الإجابة واضحة، الزرار ضوضاء.
      schedule(cubit, 'srv-1', inDays: 2, atHour: 10);
      schedule(cubit, 'srv-2', inDays: 2, atHour: 11);
      final second = cubit.items.firstWhere((i) => i.service.uuid == 'srv-2');
      expect(cubit.boundaryBefore(second), isNull);

      // ساعة وربع — يستاهل سؤال.
      schedule(cubit, 'srv-2', inDays: 2, atHour: 12);
      final boundary = cubit.boundaryBefore(second);
      expect(boundary, isNotNull);
      expect(boundary!.isBreak, isFalse);
      expect(boundary.gap, const Duration(hours: 1, minutes: 15));
    });

    test('العناصر جوه الرحلة مرتبة زمنيًا والرحلات مرتبة كمان', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));
      cubit.toggleService(MockServices.byUuid('srv-5'));

      schedule(cubit, 'srv-5', inDays: 2, atHour: 20); // رحلة تانية
      schedule(cubit, 'srv-2', inDays: 2, atHour: 11); // رحلة أولى
      schedule(cubit, 'srv-1', inDays: 2, atHour: 10); // رحلة أولى

      final visits = cubit.visits;
      expect(visits, hasLength(2));
      expect(visits[0].map((i) => i.service.uuid).toList(), <String>[
        'srv-1',
        'srv-2',
      ]);
      expect(visits[1].single.service.uuid, 'srv-5');
    });
  });

  group('السلة', () {
    test('toggle بيضيف ويشيل', () {
      final cubit = buildCubit();
      final service = MockServices.byUuid('srv-1');

      cubit.toggleService(service);
      expect(cubit.isServiceSelected('srv-1'), isTrue);

      cubit.toggleService(service);
      expect(cubit.isServiceSelected('srv-1'), isFalse);
      expect(cubit.items, isEmpty);
    });

    test('الإجمالي مجموع الخدمات مش سعر أول واحدة', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1')); // ٢٥٠
      cubit.toggleService(MockServices.byUuid('srv-2')); // ١٢٠

      expect(cubit.totalPrice, 370);
      expect(cubit.totalDuration, 65);
    });

    test('اختيار ميعاد بيقفل الكارت ويفتح اللي بعده', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      final first = cubit.items[0];
      final second = cubit.items[1];

      final now = DateTime.now();
      final startAt = DateTime(now.year, now.month, now.day + 2, 18);
      cubit.selectSlot(
        first.key,
        SlotUiModel(
          startAt: startAt,
          endAt: startAt.add(const Duration(minutes: 45)),
          price: 250,
        ),
      );

      expect(first.isExpanded, isFalse);
      expect(second.isExpanded, isTrue);
    });

    // انحدار حصل فعلاً: `_expandNextUnscheduled` بينده `_ensureLoaded` اللي
    // بيعمل الـ emit بتاع التحميل بشكل متزامن، واللي نداه كان بيعمل
    // `emit(OnSelectionChangedState)` بعديها فبيدهسها. النتيجة إن الكارت
    // بيتفتح على حالة فاضية بدل الـ skeleton.
    //
    // بعد Phase 4 التحميل الافتراضي بقى **اقتراحات** مش تواريخ — التقويم
    // مابيتحمّلش غير لما العميل يفتح «كل المواعيد».
    test('فتح كارت بيسيب حالة التحميل تعيش مش يدهسها', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));

      cubit.enterDateTimeStep();

      expect(cubit.state, isA<LoadingSlotsState>());
      expect((cubit.state as LoadingSlotsState).itemKey, cubit.items.first.key);
    });

    test('حالة التحميل بتخص الكارت المفتوح بس', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));

      cubit.expandItem(cubit.items[1].key);

      // من غير الـ itemKey كان الـ skeleton هيظهر في كل كروت السلة.
      expect((cubit.state as LoadingSlotsState).itemKey, cubit.items[1].key);
    });

    test('canGoNext في خطوة المواعيد بيستنى كل الخدمات تتحدد', () {
      final cubit = buildCubit();
      cubit.toggleService(MockServices.byUuid('srv-1'));
      cubit.toggleService(MockServices.byUuid('srv-2'));
      cubit.goToStep(BookingStep.dateTime);

      schedule(cubit, 'srv-1', inDays: 2, atHour: 18);
      expect(cubit.canGoNext, isFalse);

      schedule(cubit, 'srv-2', inDays: 2, atHour: 19);
      expect(cubit.canGoNext, isTrue);
    });
  });
}
