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
import 'core/services/services_locator.dart';
import 'core/utils/app_constant.dart';
import 'observer.dart';

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
  await MyConnectivity.initialise();
  // await LocalNotificationService.initializedNotification();
  // PusherService.initPusher();

  Bloc.observer = Observer();

  try {
    await checkIsFirstRunForApp();
    await checkIfLoggedInUser();
    await checkIfIsInBoardingUser();
  } catch (e) {
    isLoggedInUser = false;
  }
  // try {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await FirebaseNotificationService.init();
  // } catch (e) {
  //   print('Firebase initialization error: $e');
  // }
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
