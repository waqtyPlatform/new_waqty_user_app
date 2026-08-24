import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';

/// **قياس قرار «تبويب خامس ولا تبويب جوه حجوزاتي».**
///
/// §F1 من الـspec بيسيب القرار مفتوح وبيقول: **قيس بار الـ٥ لابلات عند
/// مقياس خط ١٫٣ قبل ما تلتزم**. الملف ده هو القياس — عشان القرار يبقى
/// برقم مش برأي، ويفضل قابل لإعادة الفحص لما حد يقترح التبويب تاني.
///
/// **اللي اتشحن:** تبويب تالت «باقاتي» جوه «حجوزاتي». السبب مش القياس
/// لوحده — الباقة بتتشتري من الفرع وأغلب العملاء مالهمش واحدة عند
/// الإطلاق، وتبويب خامس فاضي لـ٩٠٪ من الناس بيدرّبهم يتجاهلوه.
///
/// الاختبارات دي بتثبّت الاتنين: إن التالت اللي اتشحن **مابيفيضش**، وإن
/// الخامس اللي مااتشحنش **كان هيفيض ولا لأ** — الرقم اللي القرار الجاي
/// هيتبني عليه.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  /// أضيق شاشة بنستهدفها (§9 بند ١١) + أقصى مقياس خط مسموح
  /// (`MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)` في
  /// `my_app.dart`). دي الحالة اللي بتكسر، مش المقاس العادي.
  const worstCase = Size(360, 640);
  const maxScale = 1.3;

  /// ⚠ **الابن بيتبني جوه الـbuilder مش بره.**
  ///
  /// `AppSpacing.pageGutter.w` بينادي `ScreenUtil` — واللي مابيتهيّأش غير
  /// جوه `ScreenUtilInit`. تمرير widget مبني بره بيرمي
  /// `LateInitializationError` قبل ما أي حاجة ترسم.
  Future<void> pump(WidgetTester tester, WidgetBuilder build) async {
    tester.view.physicalSize = worstCase;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          locale: const Locale('ar', 'EG'),
          home: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(maxScale),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(builder: build),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('التبويب التالت اللي اتشحن — «حجوزاتي»', () {
    testWidgets('تلات لابلات مابيفيضوش عند 1.3 على 360', (tester) async {
      await pump(
        tester,
        (context) => Scaffold(
          body: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.pageGutter.w,
            ),
            child: AppTabBarWidget<int>(
              value: 0,
              onChanged: (_) {},
              tabs: const <AppSegment<int>>[
                AppSegment(value: 0, label: 'القادمة'),
                AppSegment(value: 1, label: 'السابقة'),
                AppSegment(value: 2, label: 'باقاتي'),
              ],
            ),
          ),
        ),
      );

      // `tester.takeException()` بيمسك `RenderFlex overflowed` — الفيضان
      // في فلاتر استثناء وقت رسم، مش خطأ تخطيط بيرجع في مقاس.
      expect(tester.takeException(), isNull);
      expect(find.text('باقاتي'), findsOneWidget);
    });
  });

  group('القياس: بار خمس تبويبات — اللي مااتشحنش', () {
    testWidgets('الرقم بيتسجّل هنا عشان القرار الجاي يبقى مبني عليه', (
      tester,
    ) async {
      final five = <AppNavItem>[
        for (final tab in ButtonNavigationBarCubit.tabs)
          AppNavItem(
            label: tab.label,
            icon: tab.icon,
            activeIcon: tab.activeIcon,
          ),
        const AppNavItem(
          label: 'باقاتي',
          icon: Icons.card_giftcard_outlined,
          activeIcon: Icons.card_giftcard_rounded,
        ),
      ];

      // بيتأكد إن التبويبات الحالية أربعة — لو حد زوّد خامس في الشريط
      // بجد، الاختبار ده بيقع وبيجبره يقرا الكلام اللي فوق.
      expect(ButtonNavigationBarCubit.tabs.length, 4);
      expect(five.length, 5);

      await pump(
        tester,
        (context) => Scaffold(
          bottomNavigationBar: AppBottomNavWidget(
            currentIndex: 0,
            onTap: (_) {},
            items: five,
          ),
        ),
      );

      // ⚠ **النتيجة:** الشريط بخمس لابلات عربية على ٣٦٠ عند ١٫٣ بيرسم من
      // غير فيضان — يعني القرار **مش مقيّد بالتخطيط**، وهو قرار منتج
      // بحت (تبويب فاضي لأغلب الناس عند الإطلاق).
      //
      // لو الاختبار ده وقع بكرة، يبقى التخطيط بقى قيد فعلاً والقرار
      // اتحسم لوحده.
      expect(tester.takeException(), isNull);
      expect(find.text('باقاتي'), findsOneWidget);
    });
  });
}
