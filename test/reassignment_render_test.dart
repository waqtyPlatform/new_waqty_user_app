import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_reassignments.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/repo/reassignment_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_mock_service.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_cubit.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/reassignment_screen.dart';

/// **اختبار رسم لشاشة إعادة التوزيع.**
///
/// نفس نمط `home_render_test`: الفيضان (`RenderFlex overflowed`) وأي استثناء
/// وقت الرسم، **في الوضعين وعلى تلات مقاييس خط**.
///
/// الشاشة دي فيها مقارنة رأسية وعدّاد وشارة محاولات وتلات زراير — يعني كل
/// عناصر الفيضان مجتمعة، والارتفاعات محسوبة لحد ١٫٣ زي باقي الأبلكيشن.
void main() {
  setUp(() {
    MockConfig.delay = Duration.zero;
    MockConfig.scenario = MockScenario.happyPath;
    MockReassignments.reset();
  });

  tearDown(() {
    MockConfig.delay = const Duration(milliseconds: 600);
    MockConfig.scenario = MockScenario.happyPath;
    AppSemanticColors.apply(Brightness.light);
  });

  Widget harness() => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (_, __) => MaterialApp(
      theme: appTheme(),
      locale: const Locale('ar', 'EG'),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocProvider(
          create: (_) => ReassignmentCubit(
            ReassignmentRepo(
              const ReassignmentMockService(),
              const ReassignmentMockService(),
            ),
          )..start(),
          child: const ReassignmentScreen(),
        ),
      ),
    ),
  );

  Future<void> pumpScreen(WidgetTester tester, double textScale) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: harness(),
      ),
    );
    // العدّاد بينبض كل ثانية، فـ`pumpAndSettle` عمره ما بيرجع.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    group('بترسم في $brightness', () {
      setUp(() => AppSemanticColors.apply(brightness));

      for (final scale in [1.0, 1.15, 1.3]) {
        testWidgets('من غير استثناءات عند مقياس خط $scale', (tester) async {
          await pumpScreen(tester, scale);
          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  testWidgets('الاقتراح بيبان بالمقارنة والعدّاد', (tester) async {
    AppSemanticColors.apply(Brightness.light);
    await pumpScreen(tester, 1.0);

    expect(find.text('كان'), findsOneWidget);
    expect(find.text('بقى'), findsOneWidget);
    expect(find.text('يناسبني، اقبل'), findsOneWidget);
    expect(find.text('الميعاد ده مش مناسب'), findsOneWidget);
    // ⚠ الإلغاء نص هادي مش زرار — بيلغي الحجز كله.
    expect(find.text('إلغاء الحجز خالص'), findsOneWidget);
  });

  testWidgets('مفيش طلبات = حالة فاضية مش شاشة بيضا', (tester) async {
    MockConfig.scenario = MockScenario.emptyState;
    AppSemanticColors.apply(Brightness.light);

    await pumpScreen(tester, 1.0);

    expect(find.text('مفيش تغييرات على حجوزاتك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
