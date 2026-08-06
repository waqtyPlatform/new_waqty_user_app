import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/ui/widgets/app_bottom_nav_widget.dart';

/// **شريط التبويبات — ٤ تبويبات وزرار «احجز» وسطاني.**
///
/// من الـ design DNA: `Bottom tab bar with 5 items … center scissors icon as
/// FAB-style highlight, active state uses amber fill circle behind icon`.
///
/// الاختبارات دي بتثبّت التلات حاجات اللي الزرار الوسطاني القديم اتشال
/// بسببهم:
///  • **مكتوب عليه اسم** — مش `+` بلا لابل.
///  • **مش تبويب** — مابيغيّرش الفهرس، فقارئ الشاشة بيقراه «زر» مش «تبويب
///    ٣ من ٥».
///  • **بيفتح حاجة** — الـ callback بيتنده فعلاً.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));

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
    ValueChanged<int>? onTabTap,
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
                currentIndex: currentIndex,
                onTabTap: onTabTap ?? (_) {},
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
    /// من الـ DNA: `active state uses … fill circle behind icon`. اللون
    /// لوحده مكانش كفاية — إشارة واحدة بتضيع في الشمس.
    testWidgets('التبويب المختار أيقونته ولابله باللمسة', (tester) async {
      await pumpBar(tester, currentIndex: 2);

      final tabs = ButtonNavigationBarCubit.tabs;

      final selected = tester.widget<Text>(find.text(tabs[2].label));
      expect(selected.style?.color, AppSemanticColors.accent);

      final other = tester.widget<Text>(find.text(tabs[0].label));
      expect(other.style?.color, AppSemanticColors.textSecondary);
    });

    testWidgets('الدايرة بتظهر خلف المختار بس', (tester) async {
      await pumpBar(tester, currentIndex: 1);

      final pills = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .toList();

      expect(
        pills.where((c) => c == AppSemanticColors.accentSoft).length,
        1,
        reason: 'المفروض دايرة واحدة بس',
      );
    });
  });

  group('الضغط', () {
    testWidgets('التبويب بيبعت فهرسه', (tester) async {
      final taps = <int>[];
      await pumpBar(tester, onTabTap: taps.add);

      await tester.tap(find.text(ButtonNavigationBarCubit.tabs[3].label));
      await tester.pump();

      expect(taps, [3]);
    });

    /// الضغط على التبويب المفتوح أصلاً مابيبعتش حاجة — الـ cubit بيقفل
    /// الإعادة، والاختبار ده بيثبّت إن الشريط بيبعت الفهرس الصح مهما كان.
    testWidgets('كل تبويب بيبعت فهرسه هو', (tester) async {
      final taps = <int>[];
      await pumpBar(tester, onTabTap: taps.add);

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
      expect(selected.style?.color, AppSemanticColors.accent);
      expect(selected.style?.color, const Color(0xff00CC77));
    });
  });
}
