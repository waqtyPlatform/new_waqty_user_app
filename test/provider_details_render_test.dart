import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/service_provider_details_screen.dart';

/// **صفحة المحل — الصفحة اللي وقعت.**
///
/// الباج: `outlinedButtonTheme` في الثيم كان بيدي `minimumSize` بعرض
/// `double.infinity`، وزرار «احجز» جنب كل خدمة عايش جوه `Row` — يعني محور
/// أفقي **غير محدود**. النتيجة `BoxConstraints forces an infinite width`
/// و**الصفحة كلها بتقع** بدل ما تترسم.
///
/// `flutter analyze` مابيشوفش النوع ده من الباجات — دي حالة تخطيط بتحصل
/// وقت التشغيل بس. الاختبار ده هو اللي بيمسكها.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pumpDetails(
    WidgetTester tester, {
    required Brightness brightness,
    double textScale = 1.0,
  }) async {
    AppSemanticColors.apply(brightness);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = MockProviders.all.first;

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
              child: BlocProvider(
                create: (_) =>
                    ServiceProviderDetailsCubit(providerUuid: provider.uuid)
                      ..loadDetails(),
                child: const ServiceProviderDetailsScreen(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  for (final brightness in Brightness.values) {
    group('صفحة المحل بترسم في $brightness', () {
      for (final scale in [1.0, AppSpacing.maxTextScale]) {
        testWidgets('من غير استثناءات عند مقياس خط $scale', (tester) async {
          await pumpDetails(tester, brightness: brightness, textScale: scale);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  group('المحتوى الجديد', () {
    /// الاسم اتنقل **فوق الصورة** في الهيدر، وبقى موجود مرتين: مرة في
    /// الكتلة اللي على اللوح ومرة في عنوان الـ AppBar المتجمّع.
    testWidgets('اسم المحل بيتعرض في الهيدر', (tester) async {
      await pumpDetails(tester, brightness: Brightness.light);

      final provider = MockProviders.all.first;
      expect(find.text(provider.name), findsWidgets);
    });

    /// شريط الشارات بدل سطر النص المدموج.
    testWidgets('شارات المواصفات بتتعرض', (tester) async {
      await pumpDetails(tester, brightness: Brightness.light);

      expect(find.textContaining('كم'), findsWidgets);
      // مرتين: شارة المواصفات فوق، وشريط الحجز المثبّت تحت.
      expect(find.textContaining('يبدأ من'), findsWidgets);
    });

    /// **الزرار اللي كان بيوقّع الصفحة.**
    testWidgets('زرار «احجز» جنب الخدمة بيترسم من غير ما يفيض', (tester) async {
      await pumpDetails(tester, brightness: Brightness.light);

      await tester.scrollUntilVisible(
        find.text('احجز').first,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('احجز'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
