import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';

/// **شريط التبويبات — ٤ تبويبات، من غير زرار وسطاني.**
///
/// الشريط بقى [AppBottomNavWidget] بتاع الكيت. اللي اتغيّر في التبنّي:
///
///  • العناصر بتيجي من بره كـ`AppNavItem` — الشريط مابقاش عارف الـ cubit.
///    التحويل من `NavTab` بيحصل في `ButtonNavigationBarScreen`.
///  • **دايرة `activePill` خلف الأيقونة اتشالت.** الإشارة التانية جنب اللون
///    بقت **أيقونة مختلفة** (`activeIcon`) مش خلفية ملوّنة. لسه إشارتين،
///    فلسه بتبان في الشمس وعلى شاشة رخيصة.
///  • اللون المختار `accentText` (الأخضر عالي التباين) واللي مش مختار
///    `textTertiary`.
///
/// الاختبارات دي بتثبّت التلات حاجات اللي الزرار الوسطاني اتشال بسببهم:
///  • **مكتوب عليه اسم** — مش `+` بلا لابل.
///  • **مش تبويب** — مابيغيّرش الفهرس.
///  • **بيفتح حاجة** — الـ callback بيتنده فعلاً.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));

  /// نفس التحويل اللي في `ButtonNavigationBarScreen` بالظبط — لو الشاشة
  /// غيّرته والاختبار لأ، الاختبار بيبقى بيقيس حاجة مش معروضة.
  final items = [
    for (final tab in ButtonNavigationBarCubit.tabs)
      AppNavItem(label: tab.label, icon: tab.icon, activeIcon: tab.activeIcon),
  ];

  /// **مقاس شاشة الاختبار لازم يبقى مقاس التصميم.**
  ///
  /// سطح الاختبار الافتراضي `800×600` — **عرضه أكبر من طوله**، وده أبلكيشن
  /// موبايل رأسي. `ScreenUtil` بيحسب مقاس الخط من العرض والارتفاعات من
  /// الطول، فعلى ٨٠٠×٦٠٠ الخط بيتضاعف ٢٫١٣× والارتفاعات بتنزل ٠٫٧٤× —
  /// وأي صندوق فيه نص بيفيض.
  ///
  /// ده مش باج في الشريط: على ٣٧٥×٨١٢ (مقاس التصميم) المعاملين واحد.
  /// و`minTextAdapt: true` هنا بيطابق `my_app.dart` بالظبط — من غيره الخط
  /// بيتبع العرض لوحده والحسبة بتفرق على الشاشات القصيرة.
  Future<void> pumpBar(
    WidgetTester tester, {
    int currentIndex = 0,
    ValueChanged<int>? onTap,
  }) {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              bottomNavigationBar: AppBottomNavWidget(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('التركيب', () {
    testWidgets('الأربع تبويبات موجودين', (tester) async {
      await pumpBar(tester);

      for (final tab in ButtonNavigationBarCubit.tabs) {
        expect(find.text(tab.label), findsOneWidget);
      }
    });

    /// **الزرار الوسطاني اتشال.** الاختبار ده بيمنع رجوعه بالغلط: لو حد
    /// ضاف عنصر خامس، عدد اللابلات هيزيد عن عدد التبويبات.
    testWidgets('مفيش زرار وسطاني ولا عنصر خامس', (tester) async {
      await pumpBar(tester);

      expect(find.text('احجز'), findsNothing);
      expect(find.byIcon(Icons.content_cut_rounded), findsNothing);
      expect(
        find.byType(Text),
        findsNWidgets(ButtonNavigationBarCubit.tabs.length),
      );
    });
  });

  group('الحالة المختارة', () {
    testWidgets('التبويب المختار لابله باللمسة والباقي رمادي', (tester) async {
      await pumpBar(tester, currentIndex: 2);

      final tabs = ButtonNavigationBarCubit.tabs;

      final selected = tester.widget<Text>(find.text(tabs[2].label));
      expect(selected.style?.color, AppSemanticColors.accentText);

      final other = tester.widget<Text>(find.text(tabs[0].label));
      expect(other.style?.color, AppSemanticColors.textTertiary);
    });

    /// **الإشارة التانية بقت شكل الأيقونة مش دايرة وراها.**
    ///
    /// الدايرة كانت بتقول «ده المختار» بخلفية ملوّنة؛ الكيت بيقولها
    /// بأيقونة مصمتة بدل المفرّغة. اللي مهم إن الإشارة **اتنين** مش لون
    /// لوحده — لون واحد بيضيع في الشمس وعلى شاشة رخيصة.
    testWidgets('المختار بياخد activeIcon والباقي بياخد icon', (tester) async {
      await pumpBar(tester, currentIndex: 1);

      final tabs = ButtonNavigationBarCubit.tabs;

      expect(find.byIcon(tabs[1].activeIcon), findsOneWidget);
      for (var i = 0; i < tabs.length; i++) {
        if (i == 1) continue;
        expect(find.byIcon(tabs[i].icon), findsOneWidget);
      }
    });

    testWidgets('أيقونة المختار كمان باللمسة', (tester) async {
      await pumpBar(tester, currentIndex: 1);

      final tabs = ButtonNavigationBarCubit.tabs;

      final selected = tester.widget<Icon>(find.byIcon(tabs[1].activeIcon));
      expect(selected.color, AppSemanticColors.accentText);

      final other = tester.widget<Icon>(find.byIcon(tabs[0].icon));
      expect(other.color, AppSemanticColors.textTertiary);
    });
  });

  group('الضغط', () {
    testWidgets('التبويب بيبعت فهرسه', (tester) async {
      final taps = <int>[];
      await pumpBar(tester, onTap: taps.add);

      await tester.tap(find.text(ButtonNavigationBarCubit.tabs[3].label));
      await tester.pump();

      expect(taps, [3]);
    });

    /// الضغط على التبويب المفتوح أصلاً مابيبعتش حاجة — الـ cubit بيقفل
    /// الإعادة، والاختبار ده بيثبّت إن الشريط بيبعت الفهرس الصح مهما كان.
    testWidgets('كل تبويب بيبعت فهرسه هو', (tester) async {
      final taps = <int>[];
      await pumpBar(tester, onTap: taps.add);

      for (var i = 0; i < ButtonNavigationBarCubit.tabs.length; i++) {
        await tester.tap(find.text(ButtonNavigationBarCubit.tabs[i].label));
        await tester.pump();
      }

      expect(taps, [0, 1, 2, 3]);
    });
  });

  group('الوضع الغامق', () {
    testWidgets('الشريط بياخد ألوان الوضع الغامق', (tester) async {
      AppSemanticColors.apply(Brightness.dark);
      addTearDown(() => AppSemanticColors.apply(Brightness.light));

      await pumpBar(tester, currentIndex: 0);

      final selected = tester.widget<Text>(
        find.text(ButtonNavigationBarCubit.tabs.first.label),
      );

      // اللمسة الغامقة `#00CC77` — لو الشريط لسه بيقرا الفاتحة، ده هيبان هنا.
      expect(selected.style?.color, AppSemanticColors.accentText);
      expect(selected.style?.color, const Color(0xff00CC77));
    });
  });
}
