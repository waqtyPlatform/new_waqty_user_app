import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/widgets/offline_alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_routes.dart';
import 'config/themes/app_white_theme.dart';
import 'core/utils/app_colors_white_theme.dart';
import 'core/utils/app_semantic_colors.dart';
import 'core/utils/app_spacing.dart';

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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, snapshot) {
        // getIt<AppConstant>().setLanguage(context.locale.languageCode);

        if (!_isAuthenticated) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // كانت `MaterialApp` تانية **من غير `theme:`** — يعني زرار
            // الفتح كان بيطلع بنفسجي بتاع Material الافتراضي.
            theme: themeData(),
            home: Scaffold(
              backgroundColor: AppSemanticColors.page,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 80.w,
                      color: AppColors.greyColor900,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'App Locked',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyColor900,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Unlock'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          color: AppSemanticColors.page,
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: "appName".tr(),
            theme: themeData(),
            initialRoute: widget.navigateWidget,
            onGenerateRoute: RouteGenerator.generateRoute,
            // **سطر واحد بيحمي كل ارتفاع ثابت في الأبلكيشن مرة واحدة.**
            //
            // أندرويد بيوصّل مقياس الخط لـ ٢× من إعدادات إمكانية الوصول.
            // الأرقام اللي حسبناها اتحسبت لحد ١٫٣، وفوقها الصناديق بتفيض.
            // بنقصّه هنا بدل ما نلاحق ٢٠ صندوق واحد واحد.
            builder: (context, child) => MediaQuery.withClampedTextScaling(
              maxScaleFactor: AppSpacing.maxTextScale,
              // MOCK — الشارة والسيناريوهات بيختفوا بالكامل في الـ release.
              child: MockScenarioSwitcherWidget(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
