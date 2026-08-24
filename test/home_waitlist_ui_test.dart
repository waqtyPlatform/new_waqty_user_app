import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/waitlist/ui/widgets/waitlist_change_request_sheet.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_search_widget.dart';

/// **الهوم وقايمة الانتظار بعد التبنّي.**
///
///  • بحث الهوم — كان سطح غاطس بيقلّد حقل، بقى [AppSearchFieldWidget]
///    معطّل جوّه زرار.
///  • ورقة «الميعاد مش مناسب» — كانت `Container` باستدارة مكتوبة بالإيد
///    وشيبس محلية، بقت [AppSheetWidget] + [AppChipWidget].
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    // السيناريو الافتراضي مافيهوش أي إدخال في قايمة انتظار — الورقة
    // محتاجة عرض شغّال عشان يبقى فيه `offeredStartAt` تعرضه.
    MockConfig.scenario = MockScenario.waitlistOffered;
    MockWaitlist.reset();
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
    MockWaitlist.reset();
  });

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
              child: Scaffold(body: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('بحث الهوم', () {
    testWidgets('بيرسم حقل بحث معطّل بالهنت الصح', (tester) async {
      await pump(tester, HomeSearchWidget(onTap: () {}));

      expect(find.byType(AppSearchFieldWidget), findsOneWidget);
      expect(find.text('دوّر على صالون أو خدمة'), findsOneWidget);

      // معطّل — مش حقل حقيقي، فمالوش تركيز ولا كيبورد.
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.readOnly || !field.enableInteractiveSelection, isTrue);
    });

    /// **الضغطة لازم توصل للزرار مش للحقل.** من غير `AbsorbPointer` الحقل
    /// بياخد اللمسة وما يحصلش حاجة — وده بالظبط الباج اللي الـwidget
    /// اتكتب عشانه أول مرة.
    testWidgets('الضغط في أي مكان بيفتح شاشة البحث', (tester) async {
      var taps = 0;
      await pump(tester, HomeSearchWidget(onTap: () => taps++));

      await tester.tap(find.byType(HomeSearchWidget));
      await tester.pump();
      expect(taps, 1);

      // `warnIfMissed: false` عن قصد: اللمسة **مش المفروض** توصل للنص —
      // `AbsorbPointer` بيبلعها والـ`GestureDetector` اللي فوق بياخدها.
      // إن الضغطة على الهنت نفسه بتفتح البحث هو اللي بنتأكد منه هنا.
      await tester.tap(
        find.text('دوّر على صالون أو خدمة'),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(taps, 2);
    });
  });

  group('ورقة «الميعاد مش مناسب»', () {
    WaitlistUiModel entry() => MockWaitlist.forUser(DateTime.now()).first;

    testWidgets('العنوان والأسباب السريعة بيبانوا', (tester) async {
      await pump(tester, WaitlistChangeRequestSheet(entry: entry()));

      expect(find.text('الميعاد ده مش مناسب؟'), findsOneWidget);
      expect(find.byType(AppChipWidget), findsNWidgets(4));
      expect(find.text('الميعاد بدري عليّا'), findsOneWidget);
    });

    /// **الزرار مقفول من غير سبب.** السيرفر بيرفض الطلب الفاضي بـ٤٢٢،
    /// وزرار بيدوس ويرجّع خطأ أوحش من زرار مقفول.
    testWidgets('الزرار مقفول لحد ما يبقى فيه سبب', (tester) async {
      await pump(tester, WaitlistChangeRequestSheet(entry: entry()));

      expect(
        tester.widget<AppButtonWidget>(find.byType(AppButtonWidget)).onPressed,
        isNull,
      );

      await tester.tap(find.text('الميعاد بدري عليّا'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AppButtonWidget>(find.byType(AppButtonWidget)).onPressed,
        isNotNull,
      );
    });

    testWidgets('الكتابة بتلغي اختيار الشيب', (tester) async {
      await pump(tester, WaitlistChangeRequestSheet(entry: entry()));

      await tester.tap(find.text('الميعاد بدري عليّا'));
      await tester.pumpAndSettle();

      var selected = tester
          .widgetList<AppChipWidget>(find.byType(AppChipWidget))
          .where((c) => c.isSelected)
          .length;
      expect(selected, 1);

      await tester.enterText(find.byType(EditableText), 'سبب من عندي');
      await tester.pumpAndSettle();

      selected = tester
          .widgetList<AppChipWidget>(find.byType(AppChipWidget))
          .where((c) => c.isSelected)
          .length;
      expect(selected, 0, reason: 'النص المكتوب بيغلب الاختيار السريع');
    });

    for (final brightness in Brightness.values) {
      testWidgets('بترسم في $brightness عند ١٫٣ من غير فيض', (tester) async {
        await pump(
          tester,
          WaitlistChangeRequestSheet(entry: entry()),
          brightness: brightness,
          textScale: AppSpacing.maxTextScale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
