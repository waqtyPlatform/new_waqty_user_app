import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/core/utils/demo_mode.dart';
import 'package:waqty_user_application/my_app.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/cache_helper.dart';
import 'core/api/session_store.dart';
import 'core/services/services_locator.dart';
import 'core/utils/app_constant.dart';
import 'observer.dart';
import 'dart:async';
import 'core/services/firebase_notification_service.dart';
import 'features/splash/data/repo/app_gate_repo.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.data}");
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  await ServicesLocator.init();
  await CacheHelper.init();
  // لازم **بعد** `CacheHelper.init()` — التوكن بيتقرا من المخزن الآمن،
  // والمخزن مابيتعيّنش قبلها.
  await getIt<SessionStore>().hydrate();

  // ⚠ **مابيتعملوش `await`.** إقلاع الأبلكيشن مايستناش Firebase —
  // ده نداء شبكة وطلب صلاحية، والإشعارات إضافة مش شرط تشغيل.
  //
  // ولو Firebase مش متظبط (`firebase_options.dart` فاضي) النداء بيرجع
  // فورًا من غير ما يعمل حاجة — الأبلكيشن بيشتغل عادي.
  unawaited(FirebaseNotificationService.init(getIt<AppGateRepo>()));
  await MyConnectivity.initialise();

  Bloc.observer = Observer();

  try {
    await checkIsFirstRunForApp();
    await checkIfLoggedInUser();
    await checkIfIsInBoardingUser();
  } catch (e) {
    isLoggedInUser = false;
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      saveLocale: true,
      startLocale: const Locale('ar', 'EG'),
      path: 'assets/languages',
      fallbackLocale: const Locale('ar', 'EG'),
      // من غيرها أي مفتاح ناقص في الإنجليزي بيتعرض نص خام زي
      // `buttonNavBar.homeText` قدام العميل. `fallbackLocale` لوحدها
      // مابتحلهاش — دي بتختار اللغة مش بتدوّر على المفتاح.
      useFallbackTranslations: true,
      // القرار بتاع «أفتح على إيه» بقى في SplashCubit مش hardcoded هنا.
      child: MyApp(navigateWidget: _initialRoute),
    ),
  );
}

/// نقطة البداية — السبلاش دايمًا، إلا في وضع العرض.
///
/// شوف [kDemoMode] للتفاصيل.
const String _initialRoute = kDemoMode
    ? Routes.buttonNavigationBarScreen
    : Routes.splashScreen;

Future<void> checkIsFirstRunForApp() async {
  final isFirstRun = await CacheHelper.getBool(
    ConstantKeys.saveIsFirstRunToShared,
  );

  if (isFirstRun) {
    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
    await CacheHelper.removeSecureData(ConstantKeys.saveUserTypeToShared);
    await CacheHelper.setData(ConstantKeys.saveIsFirstRunToShared, false);
  }
}

Future<void> checkIfLoggedInUser() async {
  String? userToken = await CacheHelper.getSecuredString(
    ConstantKeys.saveTokenToShared,
  );
  isLoggedInUser = !(userToken == null || userToken.isEmpty);
}

Future<void> checkIfIsInBoardingUser() async {
  isOnBoarding = await CacheHelper.getBool(
    ConstantKeys.saveIsShowIsBoardingToShared,
  );
}
