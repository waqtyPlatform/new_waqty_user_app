import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/widgets/offline_alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_routes.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'config/themes/theme_cubit.dart';

import 'core/mock/mock_scenario_switcher_widget.dart';
import 'core/services/biometric_service.dart';

/// TEMP (local run only): skips the biometric gate so the app is reachable on
/// emulators with no screen lock or enrolled fingerprint. Set back to false.
const bool kBypassAppLock = true;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final String navigateWidget;

  const MyApp({required this.navigateWidget, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isAuthenticated = kBypassAppLock;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _listenToNetwork();
    if (!kBypassAppLock) _authenticate();
  }

  /// authenticate using biometric
  Future<void> _authenticate() async {
    bool success = await _biometricService.authenticate();
    if (success) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  void _listenToNetwork() {
    MyConnectivity.myStream.listen((event) {
      if (!MyConnectivity.isOnline()) {
        _showOfflineDialog();
      }
    });
  }

  void _showOfflineDialog() {
    if (navigatorKey.currentContext == null) return;
    OfflineAlertDialog.getDialog();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (kBypassAppLock) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      if (_isAuthenticated) {
        setState(() {
          _isAuthenticated = false;
        });
        await _authenticate();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **الـ ThemeCubit فوق كل حاجة** — شاشة الحساب بتقرا منه وبتكتب فيه،
    // والقفل الحيوي تحته بردو عشان شاشة القفل ماتطلعش بيضا على جهاز غامق.
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            // `platformBrightnessOf` بيسجّل اعتماد على الـ MediaQuery اللي
            // `runApp` بيحطها فوق كل حاجة — يعني تبديل الجهاز لـ dark وقت
            // المغرب بيوصل هنا لوحده من غير `WidgetsBindingObserver`.
            final brightness = ThemeCubit.resolve(
              mode,
              MediaQuery.platformBrightnessOf(context),
            );

            // ⚠ **الترتيب ده مش تفصيلة.** التوكنز بتتقرا من palette عام،
            // فلازم يتظبط **قبل** ما `appTheme()` تتبني وقبل ما أي widget
            // تحت يرسم. الـ builder ده بيتنفّذ قبل الشجرة اللي تحته، فده
            // مضمون.
            AppSemanticColors.apply(brightness);

            return _app(context, brightness);
          },
        ),
      ),
    );
  }

  Widget _app(BuildContext context, Brightness brightness) {
    if (!_isAuthenticated) return _lockScreen(brightness);

    return MaterialApp(
      // ## ليه مفتاح على الإضاءة
      //
      // التوكنز statics مش `InheritedWidget`، يعني الـ widgets اللي متكتوبة
      // `const` مابتتبنيش تاني لما الوضع يقلب — بتفضل بألوان الوضع القديم.
      // المفتاح بيرمي الشجرة كلها ويبنيها من الأول، فمستحيل يفضل فيها لون
      // من الوضع اللي فات.
      //
      // الثمن: مكدس التنقّل بيرجع لأوله عند التبديل. ده مقبول لأنه بيحصل
      // مرتين في اليوم على الأكتر (تبديل يدوي أو مغرب/شروق)، والبديل —
      // `context` في كل استدعاء لون في ٥٥١ موضع — تكلفته أكبر بكتير.
      key: ValueKey(brightness),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: "appName".tr(),
      theme: appTheme(),
      initialRoute: widget.navigateWidget,
      onGenerateRoute: RouteGenerator.generateRoute,
      // **سطر واحد بيحمي كل ارتفاع ثابت في الأبلكيشن مرة واحدة.**
      //
      // أندرويد بيوصّل مقياس الخط لـ ٢× من إعدادات إمكانية الوصول. الأرقام
      // اللي حسبناها اتحسبت لحد ١٫٣، وفوقها الصناديق بتفيض. بنقصّه هنا بدل
      // ما نلاحق ٢٠ صندوق واحد واحد.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: AppSpacing.maxTextScale,
        // MOCK — الشارة والسيناريوهات بيختفوا بالكامل في الـ release.
        child: MockScenarioSwitcherWidget(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// شاشة القفل الحيوي — بتاخد نفس الثيم عشان ماتطلعش بيضا على جهاز غامق.
  Widget _lockScreen(Brightness brightness) {
    return MaterialApp(
      key: ValueKey('lock-$brightness'),
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 72.r,
                  color: AppSemanticColors.textTertiary,
                ),
                SizedBox(height: AppSpacing.s16.h),
                Text('الأبلكيشن مقفول', style: AppTextStyles.titleLg),
                SizedBox(height: AppSpacing.s8.h),
                Text(
                  'افتح ببصمتك عشان تكمّل',
                  style: AppTextStyles.bodyMdMuted,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.s32.h),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: const Text('افتح'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
