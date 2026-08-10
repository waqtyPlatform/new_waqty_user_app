import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/widgets/providers_list_filters_widget.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/widgets/providers_list_search_bar_widget.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/widgets/service_provider_details_hours_widget.dart';

/// **مكوّنات اكتشاف المقدّمين بعد التبنّي.**
///
///  • شريط البحث — كان `InputDecoration` من ٤٥ سطر، بقى
///    [AppSearchFieldWidget].
///  • شيبس التصنيفات — كانت `AppSurfaceWidget` خضرا مصمتة، بقت
///    [AppChipWidget].
///  • مواعيد العمل — كانت `AnimatedRotation` + `AnimatedSize` بحالة في
///    الـcubit، بقت [AppAccordionWidget] بحالتها جواها.
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
              child: Scaffold(body: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('شريط البحث', () {
    testWidgets('الهنت ظاهر وزرار المسح مخفي وهو فاضي', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        ProvidersListSearchBarWidget(
          controller: controller,
          onChanged: () {},
          onClear: () {},
        ),
      );

      expect(find.text('دوّر على صالون أو منطقة'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      // زرار المسح بيظهر لما يبقى فيه نص بس.
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('زرار المسح بيبان مع النص وبينده onClear', (tester) async {
      final controller = TextEditingController(text: 'كابتن');
      addTearDown(controller.dispose);
      var cleared = 0;

      await pump(
        tester,
        ProvidersListSearchBarWidget(
          controller: controller,
          onChanged: () {},
          onClear: () => cleared++,
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(cleared, 1);
    });

    testWidgets('الكتابة بتنده onChanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var changes = 0;

      await pump(
        tester,
        ProvidersListSearchBarWidget(
          controller: controller,
          onChanged: () => changes++,
          onClear: () {},
        ),
      );

      await tester.enterText(find.byType(EditableText), 'معادي');
      await tester.pump();

      expect(changes, greaterThan(0));
      expect(controller.text, 'معادي');
    });
  });

  group('شيبس التصنيفات', () {
    Widget filters(String selected, ValueChanged<String> onTap) =>
        ProvidersListFiltersWidget(
          categories: MockCategories.all,
          selectedCategoryUuid: selected,
          onCategoryTap: onTap,
        );

    /// ⚠ العدد مش `MockCategories.all.length`: الصف `ListView` أفقي
    /// **كسول**، فبيبني الظاهر بس — على عرض ٣٧٥ دول اتنين تقريبًا.
    /// التأكيد على العدد الكامل كان هيبقى بيقيس الـviewport مش الـwidget.
    testWidgets('التصنيفات بتترسم كشيبس', (tester) async {
      await pump(tester, filters('', (_) {}));

      expect(find.byType(AppChipWidget), findsAtLeastNWidgets(1));
      expect(find.text(MockCategories.all.first.name), findsOneWidget);
    });

    testWidgets('الضغط بيبعت uuid التصنيف', (tester) async {
      final taps = <String>[];
      final first = MockCategories.all.first;

      await pump(tester, filters('', taps.add));

      await tester.tap(find.text(first.name));
      await tester.pump();

      expect(taps, [first.uuid]);
    });

    /// الشيبس القديمة كانت ~٢٦ نقطة — تحت الحد الأدنى للمس. الكيت بيفرض
    /// `minHeight: touchTarget` جوّه الشيب نفسه.
    testWidgets('كل شيب فوق الحد الأدنى للمس', (tester) async {
      await pump(tester, filters('', (_) {}));

      for (final size in tester.widgetList<AppChipWidget>(
        find.byType(AppChipWidget),
      )) {
        final box = tester.getSize(find.byWidget(size));
        expect(box.height, greaterThanOrEqualTo(AppSpacing.touchTarget));
      }
    });
  });

  group('مواعيد العمل', () {
    final branch = MockProviders.branchesOf(MockProviders.all.first.uuid).first;

    /// ⚠ **القياس بالارتفاع مش بوجود النص.** `AppAccordionWidget` جوّه
    /// `AnimatedCrossFade`، وده بيسيب **الولدين** في الشجرة عشان يقيس
    /// الحركة — يعني `find.text` بيلاقي اسم اليوم حتى وهو مقفول ومش
    /// مرسوم. الارتفاع هو اللي بيقول الحقيقة.
    testWidgets('مقفول من البداية', (tester) async {
      await pump(tester, ServiceProviderDetailsHoursWidget(branch: branch));

      expect(find.byType(AppAccordionWidget), findsOneWidget);
      expect(find.text(branch.openStatusLabel), findsOneWidget);

      final closed = tester.getSize(find.byType(AppAccordionWidget)).height;
      expect(closed, lessThan(AppSpacing.touchTarget * 2));
    });

    /// الحالة بقت جوّه [AppAccordionWidget] — الـcubit مابقاش شايلها.
    testWidgets('الضغط بيفتح السبع أيام', (tester) async {
      await pump(tester, ServiceProviderDetailsHoursWidget(branch: branch));

      await tester.tap(find.text(branch.openStatusLabel));
      await tester.pumpAndSettle();

      for (final day in branch.workingHours) {
        expect(find.text(day.dayName), findsOneWidget);
      }
      // والارتفاع كبر فعلًا — سبع صفوف مش صفر.
      expect(
        tester.getSize(find.byType(AppAccordionWidget)).height,
        greaterThan(AppSpacing.touchTarget * 3),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('الضغط تاني بيرجّعها لارتفاعها المقفول', (tester) async {
      await pump(tester, ServiceProviderDetailsHoursWidget(branch: branch));

      final closed = tester.getSize(find.byType(AppAccordionWidget)).height;

      await tester.tap(find.text(branch.openStatusLabel));
      await tester.pumpAndSettle();
      final open = tester.getSize(find.byType(AppAccordionWidget)).height;
      expect(open, greaterThan(closed));

      await tester.tap(find.text(branch.openStatusLabel));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(AppAccordionWidget)).height,
        closeTo(closed, 0.5),
      );
    });

    for (final brightness in Brightness.values) {
      testWidgets('مفتوحة بترسم في $brightness عند ١٫٣', (tester) async {
        await pump(
          tester,
          ServiceProviderDetailsHoursWidget(branch: branch),
          brightness: brightness,
          textScale: AppSpacing.maxTextScale,
        );

        await tester.tap(find.text(branch.openStatusLabel));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
