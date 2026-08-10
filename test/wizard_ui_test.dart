import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_footer_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_header_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_staff_row_widget.dart';

/// **ويزارد الحجز بعد التبنّي.**
///
///  • الرأس — كان `Row` بدايرة رجوع ولابل و`SizedBox(40.w)` بيوازن،
///    بقى [AppScreenHeaderWidget].
///  • الفوتر — كان `Container` بظل وحد مكتوبين بالإيد، بقى
///    [AppFooterWidget].
///  • ورقة الأخصائيين — كانت `ListTile` بعلامة صح، بقت
///    [AppChoiceRowWidget] راديو.
///
/// ⚠ **مفيش [AppStepperWidget].** الكيت شايل واحد، والويزارد كان فيه
/// `CreateBookingStepperWidget` بتلات نقط **واتشال بقرار موثّق**: تلات
/// نقط بتدّعي تلات وحدات شغل متساوية، وحجز بتلات خدمات ١٢ قرار حداشر
/// منهم جوه النقطة التانية. الاختبار الأخير في الملف بيمنع رجوعه.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
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
              child: Scaffold(body: child),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('رأس الويزارد', () {
    testWidgets('اللابل بيعدّ الشغل مش المراحل', (tester) async {
      await pump(
        tester,
        const CreateBookingHeaderWidget(
          currentStep: BookingStep.dateTime,
          scheduledCount: 1,
          totalCount: 3,
        ),
      );

      // «خدمة ٢ من ٣» — الوحدة اللي العميل شايلها فعلاً.
      expect(find.textContaining('من'), findsOneWidget);
      expect(find.byType(AppScreenHeaderWidget), findsOneWidget);
    });

    /// **مفيش نقط.** لو حد رجّع `AppStepperWidget` بكرة، ده اللي هيمسكه.
    testWidgets('مفيش مؤشر خطوات بالنقط', (tester) async {
      await pump(
        tester,
        const CreateBookingHeaderWidget(
          currentStep: BookingStep.service,
          scheduledCount: 0,
          totalCount: 2,
        ),
      );

      expect(find.byType(AppStepperWidget), findsNothing);
      expect(find.text('اختار الخدمات'), findsOneWidget);
    });

    testWidgets('أول خطوة من غير زرار رجوع', (tester) async {
      await pump(
        tester,
        const CreateBookingHeaderWidget(
          currentStep: BookingStep.service,
          scheduledCount: 0,
          totalCount: 2,
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets('زرار الرجوع بيشتغل لما يتبعت', (tester) async {
      var backs = 0;
      await pump(
        tester,
        CreateBookingHeaderWidget(
          currentStep: BookingStep.confirm,
          scheduledCount: 2,
          totalCount: 2,
          onBack: () => backs++,
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      expect(backs, 1);
    });
  });

  group('فوتر الويزارد', () {
    testWidgets('الزرار مقفول لما مش مسموح', (tester) async {
      await pump(
        tester,
        CreateBookingFooterWidget(
          buttonLabel: 'كمّل',
          isEnabled: false,
          onPressed: () {},
        ),
      );

      expect(find.byType(AppFooterWidget), findsOneWidget);
      expect(
        tester.widget<AppButtonWidget>(find.byType(AppButtonWidget)).onPressed,
        isNull,
      );
    });

    testWidgets('السعر والميتا بيبانوا لما يتبعتوا', (tester) async {
      await pump(
        tester,
        CreateBookingFooterWidget(
          buttonLabel: 'أكّد الحجز',
          isEnabled: true,
          onPressed: () {},
          price: 250,
          metaLabel: 'خدمتين',
        ),
      );

      expect(find.text(AppFormat.money(250)), findsOneWidget);
      expect(find.text('خدمتين'), findsOneWidget);
    });
  });

  group('صف الأخصائي', () {
    List<EmployeeUiModel> staff() => MockEmployees.rosterOf();

    testWidgets('بيوري اسم المختار وزرار تغيير', (tester) async {
      final all = staff();

      await pump(
        tester,
        CreateBookingStaffRowWidget(
          employees: all,
          selectedEmployee: all.first,
          onEmployeeSelected: (_) {},
        ),
      );

      expect(find.text(all.first.name), findsWidgets);
      expect(find.text('تغيير'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets('بيرسم في $brightness عند ١٫٣', (tester) async {
        final all = staff();

        await pump(
          tester,
          CreateBookingStaffRowWidget(
            employees: all,
            selectedEmployee: all.first,
            onEmployeeSelected: (_) {},
          ),
          brightness: brightness,
          textScale: AppSpacing.maxTextScale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
