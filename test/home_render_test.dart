import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_cubit.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_mock_service.dart';
import 'package:waqty_user_application/features/home/home/logic/home_cubit.dart';
import 'package:waqty_user_application/features/home/home/ui/home_screen.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/repo/reassignment_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_mock_service.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_cubit.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/repo/waitlist_repo.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_mock_service.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/repo/in_branch_repo.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_mock_service.dart';

/// **اختبار رسم — بديل الـ screenshot.**
///
/// اللي بيمسكه: الفيضان (`RenderFlex overflowed`)، والقسمة على صفر في
/// التخطيط، وأي استثناء بيحصل وقت الرسم. `tester.takeException()` بيرجّع
/// أول واحد منهم.
///
/// وبيتنفّذ **في الوضعين وعلى تلات مقاييس خط** — الأرقام الثابتة في
/// الأبلكيشن محسوبة لحد `AppSpacing.maxTextScale`، والحد ده هو اللي
/// بيتفرض في `my_app.dart`. لو حد كسره، هنا هو المكان اللي هيبان فيه.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pumpHome(
    WidgetTester tester, {
    required Brightness brightness,
    required double textScale,
  }) async {
    AppSemanticColors.apply(brightness);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final upcoming = MockBookings.upcoming;
    final live = upcoming.isEmpty ? null : upcoming.first;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          locale: const Locale('ar', 'EG'),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                // نفس ترتيب `ButtonNavigationBarScreen`: الـ cubits المشتركة
                // بتتعمل **فوق** التبويب مش جواه — البؤرة وشريط «الكرسي
                // جاهز» لازم يقروا من نفس النسخة.
                body: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => WaitlistCubit(
      const WaitlistRepo(
        WaitlistMockService(),
        WaitlistMockService(),
      ),
    )..start()),
                    // البانر بتاع إعادة التوزيع بيقرا منه — فوق التبويبات
                    // في الأبلكيشن، وهنا في الاختبار.
                    BlocProvider(
                      create: (_) => ReassignmentCubit(
                        ReassignmentRepo(
                          const ReassignmentMockService(),
                          const ReassignmentMockService(),
                        ),
                      )..start(),
                    ),
                    if (live != null)
                      BlocProvider(
                        create: (_) => InBranchCubit(InBranchRepo(
                        const InBranchMockService(),
                        const InBranchMockService(),
                      ), booking: live)..start(),
                      ),
                    // ⚠ **الموك في الخانتين.** الاختبار عن الرسم مش عن مصدر
                    // الداتا، فتثبيت المصدر هنا بيشيل اعتماد على حالة عالمية
                    // (`DataSource.mode`) ممكن اختبار تاني يكون غيّرها. المبدّل
                    // نفسه ليه اختباره في `data_source_test.dart`.
                    BlocProvider(
                      create: (_) => HomeCubit(
                        HomeRepo(
                          const HomeMockService(),
                          const HomeMockService(),
                        ),
                      )..loadHome(),
                    ),
                  ],
                  child: const HomeScreen(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // الـ mock بيرجّع بعد تأخير مصطنع — `pumpAndSettle` بيستنى الحركة
    // والتحميل مع بعض.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  for (final brightness in Brightness.values) {
    group('الرئيسية بترسم في $brightness', () {
      // ١٫٠ الطبيعي · ١٫٣ الحد الأقصى اللي `my_app` بيقصّ عنده.
      for (final scale in [1.0, 1.15, AppSpacing.maxTextScale]) {
        testWidgets('من غير استثناءات عند مقياس خط $scale', (tester) async {
          await pumpHome(tester, brightness: brightness, textScale: scale);

          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('اللي فوق الطية بيوصل الشاشة', (tester) async {
        await pumpHome(tester, brightness: brightness, textScale: 1.0);

        expect(find.text('أهلاً بيك'), findsOneWidget);
        expect(find.text('دوّر على صالون أو خدمة'), findsOneWidget);
        expect(find.text('حلاقة رجالي'), findsOneWidget);
      });

      /// `ListView` مابيبنيش اللي بره الشاشة، فالأقسام التحتانية محتاجة
      /// سكرول — والسكرول ده هو اللي بيرسمها لأول مرة، يعني الاختبار بيغطي
      /// الجزء اللي `pumpAndSettle` لوحده مابيلمسوش.
      testWidgets('الأقسام التحتانية بترسم بعد السكرول', (tester) async {
        await pumpHome(tester, brightness: brightness, textScale: 1.0);

        await tester.scrollUntilVisible(
          find.text('قريب منك'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(find.text('قريب منك'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }

  /// التصنيفات بقت أطباق دائرية بحلقة للمختار (من الـ design DNA).
  /// الحسبة الثابتة بتاعة ارتفاع الصف هي أكتر حاجة معرّضة تفيض مع الخط،
  /// فبتتشاف لوحدها.
  testWidgets('صف التصنيفات مابيفيضش عند أقصى مقياس خط', (tester) async {
    await pumpHome(
      tester,
      brightness: Brightness.light,
      textScale: AppSpacing.maxTextScale,
    );

    expect(find.text('حلاقة رجالي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
