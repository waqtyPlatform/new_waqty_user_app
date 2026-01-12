import 'package:waqty_user_application/core/services/local_notification_service.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
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
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      saveLocale: true,
      startLocale: const Locale('en', 'US'),
      path: 'assets/languages',
      fallbackLocale: const Locale('en', 'US'),
      child: MyApp(
        navigateWidget: Routes.registerScreen,
        // isLoggedInUser
        //     ? (userType == 'client'
        //           ? Routes.buttonNavigationBarScreen
        //           : Routes.sponsorButtonNavigationBarSceen)
        //     : Routes.onBoardingScreen,
      ),
    ),
  );
}

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
