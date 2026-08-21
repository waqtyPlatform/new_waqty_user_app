import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/account/data/repo/account_repo.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_mock_service.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_mock_service.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/entitlements_screen.dart';

/// **نطاق الـproviders في «باقاتي» كشاشة مدفوعة.**
///
/// ## الباج اللي الملف ده اتكتب بسببه
///
/// `EntitlementsScreen` بتتفتح من صف «حسابي» ومن الشريط في «حجوزاتي» —
/// الاتنين بـ`Navigator.push` على الـnavigator بتاع `MaterialApp`، واللي
/// **فوق** الـproviders بتوع الـshell.
///
/// أول نسخة دفعت `EntitlementsCubit` بس ونسيت `AccountCubit`. النتيجة:
/// `ProviderNotFoundException` **بس لما التبويب المعروض يبقى فاضي** —
/// لأن ده المسار الوحيد اللي بيسأل عن حالة تأكيد الرقم. يعني الشاشة كانت
/// بتشتغل في التجربة العادية (فيه باقات) وبتكسر عند **أكتر حالة متوقعة
/// عند الإطلاق** (مفيش باقات).
///
/// الاختبار ده بيمشي على الحالة الفاضية بالتحديد.
void main() {
  setUp(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.delay = Duration.zero;
  });
  tearDown(() {
    AppSemanticColors.apply(Brightness.light);
    MockConfig.scenario = MockScenario.happyPath;
  });

  Future<void> pumpScreen(WidgetTester tester) async {
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
            // نفس اللي `EntitlementsScreen.open` بتركّبه بالظبط.
            child: MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<EntitlementsCubit>(
                  create: (_) => EntitlementsCubit(
                    EntitlementsRepo(
                      const EntitlementsMockService(),
                      const EntitlementsMockService(),
                    ),
                  )..load(),
                ),
                BlocProvider<AccountCubit>(
                  create: (_) => AccountCubit(
                    AccountRepo(
                      const AccountMockService(),
                      const AccountMockService(),
                    ),
                    SessionStore(),
                  )..getProfile(),
                ),
              ],
              child: const EntitlementsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('الحالة الفاضية بترسم من غير ProviderNotFound', (tester) async {
    MockConfig.scenario = MockScenario.entitlementsEmptyGenuine;
    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('لسه مافيش باقات'), findsOneWidget);
  });

  testWidgets('الفاضي بسبب الرقم بيوري الدعوة للتأكيد', (tester) async {
    MockConfig.scenario = MockScenario.entitlementsEmptyUnlinked;
    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    // الحساب الوهمي في السيناريو ده رقمه مش مأكّد، فالفرع التاني بيترسم.
    expect(find.text('أكّد رقمي'), findsOneWidget);
  });

  testWidgets('القايمة المليانة بترسم برضه', (tester) async {
    MockConfig.scenario = MockScenario.packageMultiSession;
    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('باقاتي ومتابعاتي'), findsOneWidget);
    expect(find.text('باقة قص الشعر'), findsOneWidget);
  });
}
