import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_date_strip_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_proposals_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_slots_widget.dart';

/// **خطوة الميعاد** — أكتر خطوة فيها حالات في الأبلكيشن.
///
/// كل واحدة من دول تخطيط مختلف: بيحمّل · فيه اقتراحات · مفيش اقتراحات في
/// النوافذ المختارة · مفيش مواعيد خالص · اليوم مليان · ميعاد اتحجز وإحنا
/// بنختار. الاختبارات دي بترسمهم كلهم في الوضعين وعلى مقياسين خط.
///
/// وفيه اختبار مقاس للشيبس: **هدف اللمس ٤٤**. شيبس «إنت فاضي إمتى؟» كانت
/// **٣٧** — تحت الحد بسبع نقط، وهي فلتر بيتداس بالإبهام وسط قايمة.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required Brightness brightness,
    required double textScale,
  }) async {
    AppSemanticColors.apply(brightness);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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
                body: ListView(padding: AppSpacing.page, children: [child]),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  final proposals = MockSlots.proposals();
  final firstDay = MockSlots.firstAvailableDate() ?? DateTime.now();
  final daySlots = MockSlots.slotsFor(date: firstDay);
  final month = DateTime(firstDay.year, firstDay.month);

  Widget proposalsWidget({
    List<SlotUiModel>? items,
    Set<SlotPeriod> periods = const <SlotPeriod>{},
    bool isLoading = false,
  }) => CreateBookingProposalsWidget(
    proposals: items ?? proposals,
    selectedSlot: null,
    periods: periods,
    baselinePrice: 250,
    isLoading: isLoading,
    onPeriodToggle: (_) {},
    onSlotTap: (_) {},
    onBrowseAll: () {},
    onJoinWaitlist: () {},
  );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      group('$brightness عند مقياس خط $scale', () {
        testWidgets('الاقتراحات — فيه مواعيد', (tester) async {
          await pump(
            tester,
            proposalsWidget(),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('الاقتراحات — بتحمّل', (tester) async {
          await pump(
            tester,
            proposalsWidget(isLoading: true),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        /// «مفيش مواعيد في الأوقات دي» — نص مختلف عن «مفيش مواعيد قريبة»،
        /// والفرق بينهم بيغيّر الإجراء المعروض.
        testWidgets('الاقتراحات — فاضية مع نافذة مختارة', (tester) async {
          await pump(
            tester,
            proposalsWidget(
              items: const <SlotUiModel>[],
              periods: {SlotPeriod.morning},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('الاقتراحات — فاضية من غير نافذة', (tester) async {
          await pump(
            tester,
            proposalsWidget(items: const <SlotUiModel>[]),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('شبكة المواعيد الكاملة', (tester) async {
          await pump(
            tester,
            CreateBookingSlotsWidget(
              slots: daySlots,
              selectedSlot: daySlots.isEmpty ? null : daySlots.first,
              takenSlot: null,
              baselinePrice: 250,
              onSlotTap: (_) {},
              onJoinWaitlist: () {},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('شبكة المواعيد — اليوم مليان', (tester) async {
          await pump(
            tester,
            CreateBookingSlotsWidget(
              slots: const <SlotUiModel>[],
              selectedSlot: null,
              takenSlot: null,
              baselinePrice: 250,
              onSlotTap: (_) {},
              onJoinWaitlist: () {},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('شريط التواريخ', (tester) async {
          await pump(
            tester,
            CreateBookingDateStripWidget(
              availableDates: MockSlots.availableDates(month: month),
              selectedDate: firstDay,
              currentMonth: month,
              canGoToPreviousMonth: false,
              onDateTap: (_) {},
              onMonthChange: (_) {},
              onFullDayTap: () {},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      });
    }
  }

  group('شيبس «إنت فاضي إمتى؟»', () {
    Finder chipOf(SlotPeriod period) => find
        .ancestor(
          of: find.text(period.label),
          matching: find.byType(AnimatedContainer),
        )
        .first;

    /// **الحد الأدنى ٤٤.** كانت ٣٧ — أصغر من شيبس المواعيد نفسها (٤٤ من
    /// زمان) من غير أي سبب.
    testWidgets('مش أقل من هدف اللمس', (tester) async {
      await pump(
        tester,
        proposalsWidget(),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      for (final period in SlotPeriod.values) {
        expect(
          tester.getSize(chipOf(period)).height,
          greaterThanOrEqualTo(AppSpacing.touchTarget),
          reason: 'شيب «${period.label}» أصغر من هدف اللمس',
        );
      }
    });

    /// **كل شيب بياخد مقاس نصه — مش عرض الصف.**
    ///
    /// الاختبار ده اتكتب بعد ما `constraints` + `alignment` خلّوا كل شيب
    /// يفرد لعرض الصف كله (`Container` بـ`alignment` بيفرد لأقصى قيد
    /// متاح). الارتفاع كان صح والشكل كان خراب — تلات شيبس بقوا تلات صفوف
    /// كاملة — والاختبار اللي بيقيس الارتفاع بس عدّى عليها.
    ///
    /// **مش بنقيس «سطر واحد»:** `Wrap` بيلف لما مايبقاش فيه مكان، وده
    /// السلوك الصح — على شاشة ضيقة أو مقياس خط عالي اللفّ مطلوب. اللي
    /// **مش** صح هو إن الشيب ياخد الصف كله وهو نصه كلمة.
    testWidgets('كل شيب بمقاس نصه مش بعرض الصف', (tester) async {
      await pump(
        tester,
        proposalsWidget(),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      // العرض المتاح للمحتوى = عرض اللستة ناقص هامش الصفحة على الجنبين.
      // **مش عرض الـ `Wrap`** — الـ `Wrap` بيتقلّص على محتواه، فمقارنة
      // الشيب بيه بتقارن الحاجة بنفسها.
      final contentWidth =
          tester.getSize(find.byType(ListView).first).width -
          AppSpacing.pageGutter * 2;

      for (final period in SlotPeriod.values) {
        expect(
          tester.getSize(chipOf(period)).width,
          lessThan(contentWidth),
          reason: 'شيب «${period.label}» فرد لعرض الصف كله',
        );
      }
    });
  });
}
