import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_policies.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/models/policy_ui_model.dart';
import 'package:waqty_user_application/core/widgets/policy_accordion_widget.dart';
import 'package:waqty_user_application/core/widgets/policy_note_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **سياسات الفرع — القاعدة الوحيدة اللي بتتكسر بسهولة: الطي.**
///
/// النهاردة **كل** الفروع مالهاش سياسات (`PublicProviderBranchResource`
/// مابيبعتش `policies`، وBE-B1 لسه). يعني الحالة الافتراضية لكل widget هنا
/// هي **الاختفاء**، مش العرض — ولو واحد فيهم رسم هيدر فاضي، هيرسمه في كل
/// شاشة مزوّد وكل تفاصيل حجز في التطبيق.
///
/// والاختبار التاني: الوعد اللي اتشال. «الإلغاء مجاني ومفيش أي رسوم عليك»
/// كان ضمان مالي بننطق بيه بالنيابة عن المزوّد — والمزوّد هو اللي بيكتب
/// `refund_policy` وفيه ناس بتخصم فعلاً.
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          locale: const Locale('ar', 'EG'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: SingleChildScrollView(child: child)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('الطي', () {
    testWidgets('من غير سياسات — الأكورديون مابيرسمش أي حاجة', (tester) async {
      await pump(
        tester,
        const PolicyAccordionWidget(policies: PolicyUiModel.none),
      );

      expect(find.text('قبل ما تحجز'), findsNothing);
      expect(find.byType(AppAccordionWidget), findsNothing);
    });

    testWidgets('بسياسات — الأكورديون بيرسم وبيفضل مقفول لحد ما تدوس', (
      tester,
    ) async {
      await pump(
        tester,
        const PolicyAccordionWidget(policies: MockPolicies.full),
      );

      expect(find.text('قبل ما تحجز'), findsOneWidget);

      // ⚠ **الطي مش بيشيل الجسم من الشجرة.** `AppAccordionWidget` بيستخدم
      // `AnimatedCrossFade`، واللي بيسيب الولدين الاتنين موجودين ويطوي
      // ارتفاع اللي مش ظاهر لصفر. يعني `find.textContaining` بيلاقي نص
      // السياسة حتى وهو مقفول — فالاختبار الصح على **الارتفاع** مش على
      // الوجود.
      final collapsed = tester
          .getSize(find.byType(PolicyAccordionWidget))
          .height;

      await tester.tap(find.text('قبل ما تحجز'));
      await tester.pumpAndSettle();

      final expanded = tester.getSize(find.byType(PolicyAccordionWidget)).height;
      expect(expanded, greaterThan(collapsed));
    });

    testWidgets('سطر السياسة الفاضي مابياخدش مساحة', (tester) async {
      await pump(
        tester,
        const PolicyNoteWidget(label: 'الإلغاء', text: ''),
      );

      expect(tester.getSize(find.byType(PolicyNoteWidget)), Size.zero);
    });

    testWidgets('column بيلمّ الموجود بس — مافيش فاصل لسطر مش مرسوم', (
      tester,
    ) async {
      await pump(
        tester,
        PolicyNoteWidget.column(const <PolicyNoteWidget>[
          PolicyNoteWidget(label: 'الإلغاء', text: ''),
          PolicyNoteWidget(label: 'الاسترجاع', text: 'الفلوس بترجع في ٣ أيام'),
          PolicyNoteWidget(label: 'لو ما حضرتش', text: ''),
        ]),
      );

      // `PolicyNoteWidget` بيرسم `RichText` مش `Text` — عشان اللابل
      // والنص يبقوا في سطر واحد بوزنين. فالباحث لازم يبص جوه الـspans.
      expect(
        find.textContaining('الاسترجاع', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('الإلغاء', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('column كله فاضي = صفر ارتفاع', (tester) async {
      await pump(
        tester,
        PolicyNoteWidget.column(const <PolicyNoteWidget>[
          PolicyNoteWidget(label: 'الإلغاء', text: ''),
          PolicyNoteWidget(label: 'الاسترجاع', text: ''),
        ]),
      );

      expect(find.byType(PolicyNoteWidget), findsNothing);
    });
  });

  group('بانر ما قبل الزيارة', () {
    final now = DateTime(2026, 8, 21, 12);

    test('بيظهر جوه الـ٢٤ ساعة بس', () {
      expect(
        PreVisitBannerWidget.isWithinWindow(
          now.add(const Duration(hours: 3)),
          now: now,
        ),
        isTrue,
      );
      expect(
        PreVisitBannerWidget.isWithinWindow(
          now.add(const Duration(days: 3)),
          now: now,
        ),
        isFalse,
      );
    });

    test('الميعاد اللي عدّى مابيرجّعش بانر', () {
      expect(
        PreVisitBannerWidget.isWithinWindow(
          now.subtract(const Duration(hours: 1)),
          now: now,
        ),
        isFalse,
      );
    });

    testWidgets('نص فاضي = مافيش بانر حتى جوه النافذة', (tester) async {
      await pump(
        tester,
        PreVisitBannerWidget(
          policies: PolicyUiModel.none,
          startAt: DateTime.now().add(const Duration(hours: 2)),
        ),
      );

      expect(find.text('تعليمات قبل الزيارة'), findsNothing);
    });
  });

  group('الوصل بالسيناريو', () {
    test('الافتراضي مافيش سياسات — زي السيرفر النهاردة', () {
      MockConfig.scenario = MockScenario.happyPath;
      expect(MockPolicies.current.hasAny, isFalse);
      expect(MockProviders.branchesOf('prv-1').first.policies.hasAny, isFalse);
    });

    test('policiesFull بيوصل لفروع المزوّد', () {
      MockConfig.scenario = MockScenario.policiesFull;
      expect(MockProviders.branchesOf('prv-1').first.policies.hasAny, isTrue);
      expect(
        MockProviders.branchesOf('prv-2').first.policies.refundPolicy,
        isNotEmpty,
      );
    });

    test('policiesNone بيفضل فاضي', () {
      MockConfig.scenario = MockScenario.policiesNone;
      expect(MockPolicies.current.hasAny, isFalse);
    });
  });

  group('القراية من JSON', () {
    test('مفتاح ناقص = نص فاضي مش null', () {
      final parsed = PolicyUiModel.fromJson(<String, dynamic>{
        'cancellation_policy': 'الإلغاء قبل ٤ ساعات',
      });

      expect(parsed.cancellationPolicy, 'الإلغاء قبل ٤ ساعات');
      expect(parsed.refundPolicy, isEmpty);
      expect(parsed.hasAny, isTrue);
      expect(parsed.hasPreBooking, isTrue);
    });

    test('null أو فاضي = PolicyUiModel.none', () {
      expect(PolicyUiModel.fromJson(null).hasAny, isFalse);
      expect(PolicyUiModel.fromJson(<String, dynamic>{}).hasAny, isFalse);
    });
  });
}
