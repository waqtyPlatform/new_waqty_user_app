import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqty_user_application/config/themes/theme_cubit.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_theme_item_widget.dart';

/// **أوراق شاشة الحساب.**
///
/// التلات أوراق (اللغة · المظهر · تأكيد الخروج) كانوا مكتوبين بالإيد:
/// `showModalBottomSheet` + `Padding` + `Column` + `ListTile`، وكل واحد
/// فيهم بينادي `Navigator.pop()` **وبعدين** بينفّذ الفعل — والترتيب ده
/// كان محفوظ بإيد اللي كاتب.
///
/// دلوقتي كلهم `AppSheetWidget.show<T>()`: الورقة بترجّع الاختيار واللي
/// بينده بيتصرّف في `.then`. يعني الترتيب **بنيوي** مش اتفاق — مستحيل
/// تنفّذ قبل ما تقفل.
///
/// الاختبار ده بياخد ورقة «المظهر» كعيّنة للتلاتة: بيفتح، بيختار، وبيتأكد
/// إن الورقة قفلت **و** إن الحالة اتغيّرت.
void main() {
  setUpAll(() async {
    // `ThemeCubit._restore()` بيقرا من `CacheHelper` وقت الإنشاء.
    // `init()` بتاخد `getIt()` لـ`FlutterSecureStorage` كمان وده مش
    // متسجّل في الاختبار — بس `_sharedPreferences` بتتحط في أول سطر
    // فيها، و`getString` مابيمسّش غيرها.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    try {
      await CacheHelper.init();
    } catch (_) {
      // الـ secure storage مش محتاجينه هنا.
    }
  });

  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<ThemeCubit> pumpThemeRow(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final cubit = ThemeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocProvider<ThemeCubit>.value(
              value: cubit,
              child: const Scaffold(
                body: Center(child: AccountThemeItemWidget()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return cubit;
  }

  testWidgets('الصف بيوري الوضع الشغّال كعنوان فرعي', (tester) async {
    final cubit = await pumpThemeRow(tester);

    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text(ThemeCubit.labelOf(cubit.state)), findsOneWidget);
  });

  testWidgets('الضغط بيفتح ورقة فيها التلات أوضاع', (tester) async {
    await pumpThemeRow(tester);

    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();

    // التلاتة موجودين كصفوف اختيار — مش سويتش بحالتين.
    expect(find.byType(AppChoiceRowWidget), findsNWidgets(3));
    for (final mode in ThemeMode.values) {
      expect(find.text(ThemeCubit.labelOf(mode)), findsWidgets);
    }
  });

  /// **الحاجة اللي الاختبار ده موجود عشانها.**
  ///
  /// تغيير الوضع بيرمي شجرة الأبلكيشن (`MaterialApp` عندها مفتاح على
  /// الإضاءة). لو الفعل اتنفّذ **قبل** ما الورقة تقفل، الـ `Navigator`
  /// اللي هي قاعدة فيه بيتحذف من تحتها.
  testWidgets('الاختيار بيقفل الورقة وبعدين بيغيّر الوضع', (tester) async {
    final cubit = await pumpThemeRow(tester);
    final before = cubit.state;
    final target = ThemeMode.values.firstWhere((m) => m != before);

    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(ThemeCubit.labelOf(target)).last);
    await tester.pumpAndSettle();

    // الورقة قفلت.
    expect(find.byType(AppChoiceRowWidget), findsNothing);
    // والوضع اتغيّر.
    expect(cubit.state, target);
    expect(tester.takeException(), isNull);
  });

  testWidgets('القفل من غير اختيار مابيغيّرش حاجة', (tester) async {
    final cubit = await pumpThemeRow(tester);
    final before = cubit.state;

    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();

    // ضغطة على الحاجب — الورقة بترجّع `null`.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(AppChoiceRowWidget), findsNothing);
    expect(cubit.state, before);
    expect(tester.takeException(), isNull);
  });
}
