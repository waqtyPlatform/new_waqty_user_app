import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_summary_widget.dart';

/// **خطوة الملخص** — الشاشة اللي العميل بيوافق منها.
///
/// السلة بتتبنى بـ`CreateBookingCubit.seeded` بدل ما نشغّل فلو الحجز كله:
/// الفلو بيحمّل على مراحل وبيشغّل مؤقت مهلة، فـ`pumpAndSettle` عمره ما
/// بيرجع في بيئة الاختبار. الـ `seeded` بياخد السلة جاهزة، وكل الحساب
/// اللي بعدها (الأسعار · الزيارات · الفواصل) هو الكود الحقيقي.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  final provider = MockProviders.all.first;
  final services = MockServices.ofProvider(
    provider.uuid,
  ).where((s) => !s.isCategory).toList();

  /// عنصر سلة بميعاد محدد.
  ///
  /// [dayOffset] عشان نبني حجز على أكتر من يوم (زيارتين)، و[hour] عشان
  /// نتحكم في الفارق بين خدمتين في نفس اليوم (ده اللي بيقرر الفاصل).
  BookingDraftItem scheduled(
    ServiceUiModel service, {
    required int index,
    int dayOffset = 0,
    int hour = 10,
  }) {
    // تاريخ ثابت — مفيش `DateTime.now()` عشان الاختبار مايتغيّرش باليوم.
    final start = DateTime(2026, 9, 3 + dayOffset, hour);
    final end = start.add(Duration(minutes: service.durationMinutes));

    return BookingDraftItem(
      key: 'seed-$index',
      service: service,
      currentMonth: DateTime(start.year, start.month),
      employee: EmployeeUiModel.anyAvailable,
      selectedDate: DateTime(start.year, start.month, start.day),
      selectedSlot: SlotUiModel(
        startAt: start,
        endAt: end,
        price: service.price,
      ),
    );
  }

  CreateBookingCubit singleService() => CreateBookingCubit.seeded(
    providerUuid: provider.uuid,
    providerName: provider.name,
    draft: [scheduled(services.first, index: 0)],
  );

  /// تلات خدمات على يومين — بيغطي عنوان الزيارة، وفاصل نفس اليوم،
  /// وعدّاد الخدمات جنب الإجمالي.
  CreateBookingCubit multiService() => CreateBookingCubit.seeded(
    providerUuid: provider.uuid,
    providerName: provider.name,
    draft: [
      scheduled(services[0], index: 0, hour: 10),
      // نفس اليوم وبينهم ساعات — بيولّد `VisitBoundary`.
      scheduled(services[1 % services.length], index: 1, hour: 17),
      scheduled(services[2 % services.length], index: 2, dayOffset: 2),
    ],
  );

  Future<void> pump(
    WidgetTester tester,
    CreateBookingCubit cubit, {
    required Brightness brightness,
    required double textScale,
  }) async {
    AppSemanticColors.apply(brightness);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: ListView(
                  padding: AppSpacing.page,
                  children: [CreateBookingSummaryWidget(cubit: cubit)],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      group('$brightness عند مقياس خط $scale', () {
        testWidgets('ملخص خدمة واحدة', (tester) async {
          await pump(
            tester,
            singleService(),
            brightness: brightness,
            textScale: scale,
          );

          expect(find.text('الإجمالي'), findsOneWidget);
          expect(find.text(provider.name), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('ملخص تلات خدمات على يومين', (tester) async {
          await pump(
            tester,
            multiService(),
            brightness: brightness,
            textScale: scale,
          );

          expect(find.text('الإجمالي'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      });
    }
  }

  /// **سطر الإجمالي `Wrap` مش `Row`** — عشان عند مقياس خط كبير السعر ينزل
  /// سطر تحت اللابل بدل ما يفيض. بس الـ `Wrap` جوه `Column` كروس-ألاينمنت
  /// `start` بياخد قيد مرن وبيتلم على محتواه، فـ`spaceBetween` مالهاش فراغ
  /// توزّعه واللابل والسعر بيلزقوا في بعض. الاختبار ده بيمسك الرجعة دي.
  group('سطر الإجمالي', () {
    testWidgets('اللابل والسعر على طرفي السطر', (tester) async {
      final cubit = singleService();
      await pump(tester, cubit, brightness: Brightness.light, textScale: 1.0);

      final block = tester.getRect(find.byType(CreateBookingSummaryWidget));
      final label = tester.getRect(find.text('الإجمالي'));
      // الإجمالي بقى [AppAmountWidget] — الرقم والعملة نصّين منفصلين
      // بمقاسين مختلفين. الحدود بتتاخد من الـwidget كله مش من نص فيهم.
      final price = tester.getRect(find.byType(AppAmountWidget));

      // عربي: اللابل على اليمين والسعر على الشمال.
      expect(label.right, closeTo(block.right, 1));
      expect(price.left, closeTo(block.left, 1));
    });

    /// عند ١٫٣ اللابل والسعر لازم **الاتنين يبانوا كاملين** — مش يتقص
    /// حد فيهم ولا يفيض. الـ`Wrap` هو اللي بيضمن ده: لو ما كفوش سطر
    /// واحد بينزّل التاني تحته بدل ما الصف يفيض عرضًا.
    ///
    /// ⚠ **الاختبار مابيدّعيش إنهم بينزلوا سطرين.** كان بيدّعي كده، وكان
    /// صح لما هامش الصفحة كان ٢٤ وحشوة الكارت ١٦. الكيت نزّلهم لـ١٦ و١٢،
    /// يعني الصف بقى أعرض بـ٢٠ نقطة والاتنين بيكفوا سطر واحد عند ١٫٣.
    ///
    /// اللي كان بيتحمى مش اللفّة نفسها — هو إن **محدش يتقص**. فالاختبار
    /// بيقيس ده مباشرة: الاتنين جوه الكتلة، ومفيش استثناء تخطيط.
    testWidgets('عند مقياس خط كبير محدش بيتقص ولا بيفيض', (tester) async {
      final cubit = singleService();
      await pump(
        tester,
        cubit,
        brightness: Brightness.light,
        textScale: AppSpacing.maxTextScale,
      );

      final block = tester.getRect(find.byType(CreateBookingSummaryWidget));
      final label = tester.getRect(find.text('الإجمالي'));
      // الإجمالي بقى [AppAmountWidget] — الرقم والعملة نصّين منفصلين
      // بمقاسين مختلفين. الحدود بتتاخد من الـwidget كله مش من نص فيهم.
      final price = tester.getRect(find.byType(AppAmountWidget));

      // الاتنين جوه الكتلة أفقيًا — مافيش حاجة خارجة من الحافة.
      expect(label.left, greaterThanOrEqualTo(block.left - 0.5));
      expect(label.right, lessThanOrEqualTo(block.right + 0.5));
      expect(price.left, greaterThanOrEqualTo(block.left - 0.5));
      expect(price.right, lessThanOrEqualTo(block.right + 0.5));

      // ومابيتراكبوش على بعض — يا سطر واحد جنب بعض، يا سطرين.
      final sameLine = price.top < label.bottom && label.top < price.bottom;
      if (sameLine) {
        expect(
          price.right <= label.left + 0.5 || label.right <= price.left + 0.5,
          isTrue,
          reason: 'على نفس السطر لازم يبقوا مفصولين مش فوق بعض',
        );
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('التكرار اللي اتشال', () {
    /// **الفرع كان مكتوب مرتين.**
    ///
    /// «المكان: صالون كابتن» و«الفرع: فرع المعادي» — وشارة الهيدر فوقيهم
    /// بتقول الفرع أصلاً. الملخص دلوقتي بيقول اسم المحل مرة، والفرع
    /// سايبه للشارة.
    testWidgets('اسم المحل مرة واحدة ومفيش لابل «المكان»', (tester) async {
      await pump(
        tester,
        singleService(),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      expect(find.text(provider.name), findsOneWidget);
      expect(find.text('المكان'), findsNothing);
      expect(find.text('الفرع'), findsNothing);
    });

    /// **خدمة واحدة = سعر واحد جوه الملخص.**
    ///
    /// سعر السطر كان بيساوي الإجمالي بالظبط، فالرقم كان بيتعرض مرتين في
    /// نفس الكتلة (وتالتة في الفوتر المثبّت برّه الـ widget ده).
    testWidgets('خدمة واحدة: السعر مايتكررش', (tester) async {
      final cubit = singleService();
      await pump(tester, cubit, brightness: Brightness.light, textScale: 1.0);

      // الرقم من غير عملة — [AppAmountWidget] بيرسمهم منفصلين.
      expect(
        find.text(AppFormat.money(cubit.totalPrice, withCurrency: false)),
        findsOneWidget,
      );
      expect(find.byType(AppAmountWidget), findsOneWidget);
    });

    /// أكتر من خدمة: أسعار السطور **بتفضل**، لأنها مش نفس الإجمالي.
    testWidgets('أكتر من خدمة: سعر كل خدمة بيبان', (tester) async {
      final cubit = multiService();
      await pump(tester, cubit, brightness: Brightness.light, textScale: 1.0);

      // عدّاد الخدمات جنب الإجمالي بيظهر في الحالة دي بس.
      expect(find.textContaining('خدمات ·'), findsOneWidget);

      for (final item in cubit.items) {
        expect(
          find.text(AppFormat.money(item.price)),
          findsWidgets,
          reason: 'سعر «${item.service.name}» مش ظاهر',
        );
      }
    });
  });
}
