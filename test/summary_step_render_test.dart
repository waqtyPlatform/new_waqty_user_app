import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/config/themes/app_theme.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
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
  final services = MockServices.ofProvider(provider.uuid)
      .where((s) => !s.isCategory)
      .toList();

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
      final price = tester.getRect(find.text(AppFormat.money(cubit.totalPrice)));

      // عربي: اللابل على اليمين والسعر على الشمال.
      expect(label.right, closeTo(block.right, 1));
      expect(price.left, closeTo(block.left, 1));
    });

    /// عند ١٫٣ الاتنين مش بيكفوا سطر واحد — المفروض السعر ينزل تحت،
    /// **مش** يتقص ولا يفيض.
    testWidgets('عند مقياس خط كبير السعر بينزل سطر لوحده', (tester) async {
      final cubit = singleService();
      await pump(
        tester,
        cubit,
        brightness: Brightness.light,
        textScale: AppSpacing.maxTextScale,
      );

      final label = tester.getRect(find.text('الإجمالي'));
      final price = tester.getRect(find.text(AppFormat.money(cubit.totalPrice)));

      expect(price.top, greaterThanOrEqualTo(label.bottom));
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
      await pump(
        tester,
        cubit,
        brightness: Brightness.light,
        textScale: 1.0,
      );

      expect(find.text(AppFormat.money(cubit.totalPrice)), findsOneWidget);
    });

    /// أكتر من خدمة: أسعار السطور **بتفضل**، لأنها مش نفس الإجمالي.
    testWidgets('أكتر من خدمة: سعر كل خدمة بيبان', (tester) async {
      final cubit = multiService();
      await pump(
        tester,
        cubit,
        brightness: Brightness.light,
        textScale: 1.0,
      );

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
